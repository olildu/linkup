import json
from typing import Dict, Optional
from pydantic import BaseModel
from app.core.constants.global_constants import oauth2_scheme
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status

from app.core.token_utilities import decode_token
from app.core.controllers.logger_controller import logger_controller

# Step 1: Create the router with /ws prefix
connectionsocket_router = APIRouter(prefix="/ws")

# Step 2: Maintain active WebSocket connections by user ID
active_connections_connections: Dict[int, WebSocket] = {}

# Step 3: Define the data model for sending messages to users
class DataModel(BaseModel):
    from_: int
    to: int
    type: str
    sub_type: str
    data: Optional[dict] = None

# Step 4: Function to push events to a specific user's active socket
async def send_event_to_user_connection(event: DataModel):
    websocket = active_connections_connections.get(event.to)
    if websocket:
        try:
            data_json = event.model_dump_json()
            await websocket.send_text(data_json)
            logger_controller.info(f"Sent event to user {event.to}: {data_json}")
        except Exception as e:
            print(f"Error sending event to user {event.to}: {e}")
    else:
        print(f"No active connection for user {event.to}.")


# Step 5: WebSocket endpoint to accept and handle connections
@connectionsocket_router.websocket("/connections")
async def websocket_endpoint(websocket: WebSocket) -> None:
    # Step 5.1: Get token from Authorization header or query param
    auth_header: str = websocket.headers.get("authorization")
    token: str = None
    if auth_header and auth_header.lower().startswith("bearer "):
        token = auth_header[7:].strip()
    else:
        token = websocket.query_params.get("token")

    if not token:
        # Step 5.2: Reject if no token
        logger_controller.warning("WebSocket connection rejected due to missing token")
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        return

    # Step 5.3: Decode token to get user ID
    user_id: int = decode_token(token)

    # Step 5.4: Accept the WebSocket connection
    await websocket.accept()
    active_connections_connections[user_id] = websocket

    logger_controller.info(f"User {user_id} ({websocket.client.host}) connected to connections websocket.")

    # Step 5.5: Notify the client that connection is established
    await websocket.send_text(json.dumps({"message": "Connected to connections websocket."}))

    try:
        # Step 5.6: Listen for messages in a loop
        while True:
            raw_data: str = await websocket.receive_text()
            data: Dict = json.loads(raw_data)
    except WebSocketDisconnect:
        # Step 5.7: Handle disconnection
        active_connections_connections.pop(user_id, None)
        logger_controller.info(f"User {user_id} disconnected from connections websocket.")
