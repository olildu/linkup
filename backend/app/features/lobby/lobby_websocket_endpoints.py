# Imports
import asyncio
from datetime import datetime, timedelta
import json
import random
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status
from typing import Dict, List, Tuple

# Internal module imports
from app.core.controllers.db_controller import db_pool
from app.features.connections.models.connection_user_model import ConnectionMatchModel
from app.core.token_utilities import decode_token
from app.core.controllers.logger_controller import logger_controller 

# Event tracking flags 
event_active = False
event_end_time: datetime | None = None
 
# WebSocket router and connection store
lobbysocket_router = APIRouter(prefix="/ws")
active_connections: Dict[int, WebSocket] = {}

# Retrieves users currently in the lobby and attempts matchmaking
async def get_lobby_users() -> Dict:
    conn = db_pool.getconn()
    try:
        cursor = conn.cursor()

        # List of user IDs currently connected
        lobby_users: List[int] = list(active_connections.keys())
        if not lobby_users:
            logger_controller.info("No users connected to lobby websocket.")
            return {}

        # Query to get gender and interested_gender of lobby users
        query: str = '''
            SELECT u.id, u.gender, up.key, up.value
            FROM user_preferences up
            JOIN users u on up.user_id = u.id
            WHERE key = 'interested_gender' 
            AND user_id = ANY(%s)
        '''
        cursor.execute(query, (lobby_users,))
        rows: List[Tuple[int, str, str, str]] = cursor.fetchall()

        # Build dictionary of user preferences
        users: Dict[int, Dict[str, str]] = {}
        for user in rows:
            user_id, gender, key, interested_gender = user
            if key == 'interested_gender':
                users[user_id] = {
                    'id': user_id,
                    'gender': gender,
                    'interested_gender': interested_gender
                }

        # Shuffle user list for randomized matching
        user_ids: List[int] = list(users.keys())
        random.shuffle(user_ids)

        matched: set[int] = set()
        matches: List[Tuple[int, int]] = []

        # Perform mutual gender preference match and ensure no previous chat/match
        for uid_1 in user_ids:
            if uid_1 in matched:
                continue
            user_1 = users[uid_1]
            for uid_2 in user_ids:
                if uid_1 == uid_2 or uid_2 in matched:
                    continue
                user_2 = users[uid_2]

                # Check for existing chat or match history
                cursor.execute('''
                    SELECT EXISTS (
                        SELECT chat_id FROM chat_participants WHERE user_id = %s
                        INTERSECT
                        SELECT chat_id FROM chat_participants WHERE user_id = %s
                    )
                    OR EXISTS (
                        SELECT 1 FROM matches WHERE (user1_id = %s AND user2_id = %s) OR (user1_id = %s AND user2_id = %s)
                    ) AS already_connected;
                ''', (uid_1, uid_2, uid_1, uid_2, uid_2, uid_1))
                prev_connection: bool = cursor.fetchone()[0]

                # Check mutual interest and no previous connection
                if (user_1['gender'] == user_2['interested_gender'] and
                    user_2['gender'] == user_1['interested_gender'] and
                    not prev_connection):

                    matches.append((uid_1, uid_2))
                    matched.update([uid_1, uid_2])
                    logger_controller.info(f"Matched users: {uid_1} and {uid_2}")
                    break

        # Identify users who were not matched
        not_matched: set[int] = set(users.keys()) - matched

        # Send appropriate responses to users
        await send_event_to_user(
            conn=conn,
            cursor=cursor,
            matched=matched,
            matches=matches,
            not_matched=not_matched,
        )
        return {}
        
    finally:
        if 'cursor' in locals():
            cursor.close()
        db_pool.putconn(conn)

# Send event messages (matched/not-matched) to relevant WebSocket connections
async def send_event_to_user(
    conn,
    cursor,
    matched: set[int],
    matches: List[Tuple[int, int]],
    not_matched: set[int]
) -> None:
    # Fetch matched user details for messaging
    query: str = '''
        SELECT id, username, profile_picture 
        FROM USERS 
        WHERE ID = ANY(%s);
    '''
    cursor.execute(query, (list(matched),))
    result_rows: List[Tuple[int, str, str]] = cursor.fetchall()

    user_details: Dict[int, ConnectionMatchModel] = {}

    # Notify users who were not matched
    for uid in not_matched:
        ws = active_connections.get(uid)
        if ws:
            await ws.send_text(json.dumps({
                "type": "lobby",
                "event": "match-event",
                "matched": False,
            }))
            logger_controller.info(f"Sent not-matched event to user: {uid}")

    # Construct user detail model for matched users
    for id, username, profile_picture in result_rows:
        user_details[id] = ConnectionMatchModel(
            id=id,
            username=username,
            profile_picture=profile_picture
        )

    # Notify matched users and save match in DB
    for uid_1, uid_2 in matches:
        uid1_ws: WebSocket = active_connections.get(user_details[uid_1].id)
        uid2_ws: WebSocket = active_connections.get(user_details[uid_2].id)

        if uid1_ws and uid2_ws:
            # Insert new match record
            cursor.execute("""
                INSERT INTO matches (user1_id, user2_id)
                VALUES (%s, %s); 
            """, (uid_1, uid_2))
            conn.commit()

            logger_controller.info(f"Match inserted to table for : {uid_1}, {uid_2}")

            # Send each user the other's details
            data_1 = {
                "type": "lobby",
                "event": "match-event",
                "matched": True,
                "candidate": json.loads(user_details[uid_2].model_dump_json())
            }

            data_2 = {
                "type": "lobby",
                "event": "match-event",
                "matched": True,
                "candidate": json.loads(user_details[uid_1].model_dump_json())
            }

            await uid1_ws.send_text(json.dumps(data_1))
            await uid2_ws.send_text(json.dumps(data_2))

            logger_controller.info(f"Sent matched event to users: {uid_1}, {uid_2}")

# Starts the matching event, waits, and then triggers matchmaking
async def start_waiting_period():
    global event_active, event_end_time

    logger_controller.info("Starting meet at 8")
    event_active = True
    event_end_time = datetime.now() + timedelta(minutes=5)

    # Notify all users that event has started
    for _, ws in active_connections.items():
        await ws.send_json({
            "type": "lobby",
            "event": "event-start"
        })

    # Simulated wait period before matchmaking [5 minutes]
    await asyncio.sleep(60 * 5)

    logger_controller.info("5-minute wait over. Running matchmaking.")
    event_active = False
    event_end_time = None
    await get_lobby_users()

# WebSocket endpoint for lobby communication
@lobbysocket_router.websocket("/lobby")
async def websocket_endpoint(websocket: WebSocket) -> None:
    # Extract token from headers or query parameters
    auth_header: str = websocket.headers.get("authorization")
    token: str = None
    if auth_header and auth_header.lower().startswith("bearer "):
        token = auth_header[7:].strip()
    else:
        token = websocket.query_params.get("token")

    if not token:
        logger_controller.warning("WebSocket connection rejected due to missing token")
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    user_id: int = decode_token(token)

    await websocket.accept()
    active_connections[user_id] = websocket

    logger_controller.info(f"User {user_id} ({websocket.client.host}) connected to lobby websocket.")

    await websocket.send_text(json.dumps({"message": "Connected to lobby websocket."}))

    # Send current event status
    await websocket.send_json({
        "type": "lobby",
        "event": "event-start" if event_active else "event-end"
    })

    # Keep listening for messages (no-op currently)
    try:
        while True:
            raw_data: str = await websocket.receive_text()
            data: Dict = json.loads(raw_data)
    except WebSocketDisconnect:
        active_connections.pop(user_id, None)
        logger_controller.info(f"User {user_id} disconnected from lobby websocket.")