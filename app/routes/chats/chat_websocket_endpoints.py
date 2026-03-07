import json
from fastapi import APIRouter, WebSocket, WebSocketDisconnect, status
from typing import Dict, Union
from pydantic import TypeAdapter

from app.models.messages.event_models import SeenEvent, TypingEvent
from app.models.messages.message_model import ChatMessage
from app.utilities.chat.chat_utilities import add_to_unseen_and_last_message, insert_message_to_db
from app.utilities.token.token_utilities import decode_token


chatsocket_router = APIRouter(prefix="/ws")
active_connections_chats: Dict[int, WebSocket] = {}

ChatEvent = Union[ChatMessage, TypingEvent, SeenEvent]
chat_event_adapter = TypeAdapter(ChatEvent)


async def send_event_to_user_chat(event: ChatEvent):
    websocket = active_connections_chats.get(event.to)
    if websocket:
        try:
            data_json = event.model_dump_json()
            await websocket.send_text(data_json)
            if isinstance(event, ChatMessage):
                add_to_unseen_and_last_message(
                    receiver_id=event.to,
                    chat_room_id = event.chat_room_id,
                    message_id = event.message_id
                )

        except Exception as e:
            print(f"Error sending event to user {event.to}: {e}")
    else:
        if isinstance(event, ChatMessage):
            add_to_unseen_and_last_message(
                receiver_id=event.to,
                chat_room_id = event.chat_room_id,
                message_id = event.message_id
            )
        print(f"No active connection for user {event.to}.")


@chatsocket_router.websocket("/chat")
async def websocket_endpoint(websocket: WebSocket):
    auth_header = websocket.headers.get("authorization")
    token = None
    if auth_header and auth_header.lower().startswith("bearer "):
        token = auth_header[7:].strip()
    else:
        token = websocket.query_params.get("token")

    if not token:
        await websocket.close(code=status.WS_1008_POLICY_VIOLATION)
        print("Invalid Token")
        return

    user_id = decode_token(token)
    await websocket.accept()
    active_connections_chats[user_id] = websocket
    print(f"User {user_id} ({websocket.client.host}) connected.")

    await websocket.send_text(json.dumps({"message": "Connected to chat websocket."}))

    try:
        while True:
            raw_data = await websocket.receive_text()
            data = json.loads(raw_data)

            try:
                event = chat_event_adapter.validate_python(data)
            except Exception as e:
                print(f"Failed to parse event: {data}")
                print(f"Failed to parse event: {e}")
                continue

            if isinstance(event, ChatMessage):
                print(f"Received message from {user_id} to {event.to}: {event.message}")
                inserted_id = insert_message_to_db(event)
                event.message_id = inserted_id  # assign the DB id to the event
                await send_event_to_user_chat(event)

            elif isinstance(event, TypingEvent):
                print(f"User {user_id} is typing.")
                await send_event_to_user_chat(event) 

            elif isinstance(event, SeenEvent):
                print(f"User {user_id} has seen message {event.message_id}.")
                await send_event_to_user_chat(event) 

    except WebSocketDisconnect:
        print(f"User {user_id} disconnected.")
        active_connections_chats.pop(user_id, None)