from datetime import datetime

from app.features.connections.models.connection_user_model import ConnectionChatModel


def get_last_message_timestamp(chat : ConnectionChatModel, chat_last_message : dict):
    chat_id = chat.chat_room_id
    message_info = chat_last_message.get(chat_id)
    if message_info and message_info["timestamp"]:
        return message_info["timestamp"]
    else:
        return datetime.min
