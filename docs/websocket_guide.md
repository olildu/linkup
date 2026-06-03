# WebSocket / Real-time Guide

> How the three live connections work — chat, connections, and lobby — and how to add a new one.

---

## Overview

The app has three persistent WebSocket connections. Each one runs for the lifetime of the user session.

| Socket | URL | Purpose |
|---|---|---|
| `ChatSocketServices` | `wss://.../ws/chat` | Send and receive chat messages |
| `ConnectionsSocketServices` | `wss://.../ws/connections` | Real-time connection events (new matches, etc.) |
| `LobbySocketService` | `wss://.../ws/lobby` | Meet-at-8 lobby events |

All three share the same base class: `BaseSocketService`.

---

## The base class

`lib/data/websocket_services/base_socket_service.dart`

Think of `BaseSocketService` as the engine that every socket service uses. It handles:

- **Connecting** with a JWT token (reads from secure storage)
- **Auto-reconnect** if the connection drops (every 5 seconds by default)
- **Token refresh** if the server rejects the handshake with 401/403
- **Three broadcast streams** that callers listen to:
  - `messageStream` — raw JSON strings arriving from the server
  - `disconnectStream` — emitted when the connection drops
  - `connectionStatusStream` — `true` when connected, `false` when not
- **Ping interval** (6 seconds) to keep the connection alive through firewalls

The connection state machine:

```
Disconnected
    │ connect()
    ▼
Connecting (isConnecting = true)
    │ handshake OK
    ▼
Connected (isConnected = true)
    │ server closes / error
    ▼
Reconnecting (scheduleReconnect → connect again in 5s)

    OR

    │ disconnect() called manually
    ▼
Disconnected (manualDisconnect = true, no retry)
```

---

## The concrete services

Each service is a singleton that extends `BaseSocketService` with a hardcoded URI:

```dart
// lib/data/websocket_services/chat_socket_services/chat_socket_service.dart
class ChatSocketServices extends BaseSocketService {
  static final ChatSocketServices _instance = ChatSocketServices();
  factory ChatSocketServices.instance() => _instance;

  ChatSocketServices()
      : super(uri: Uri.parse("$WS_BASE_URL/chat"), logTag: 'ChatSocketServices');

  // Static convenience accessors
  static Stream<String> get chatsMessageStream => _instance.messageStream;
  static Stream<bool> get chatsConnectionStatusStream => _instance.connectionStatusStream;
  static bool get chatsIsConnected => _instance.isConnected;
}
```

The `_instance` field makes it a Dart singleton — only one `ChatSocketServices` exists in the process. Every part of the app talks to the same connection.

---

## The BLoC layer

Raw socket data (JSON strings) arrives on `messageStream`. A bloc subscribes to that stream, parses the JSON into typed models, and emits states that the UI can react to.

Example: `ChatSocketsBloc`

```dart
class ChatSocketsBloc extends Bloc<ChatSocketsEvent, ChatSocketsState> {
  StreamSubscription<bool>? _statusSubscription;

  ChatSocketsBloc(...) : super(ChatSocketsInitial()) {
    on<LoadChatSocketsEvent>((event, emit) async {
      emit(ChatSocketsConnecting());

      await ChatSocketServices.instance().connect();   // 1. open the connection

      // 2. listen to connection status changes
      _statusSubscription = ChatSocketServices.chatsConnectionStatusStream.listen(
        (connected) async {
          if (!connected) return;

          // 3. when reconnected, flush queued (unsent) messages
          final unsent = await _getUnsent();
          for (final entity in unsent) {
            ChatSocketServices.instance().sendMessage(entity.toJson());
            await _deleteUnsentByMsgId(entity.id);
          }
        },
      );

      emit(ChatSocketsConnected());
    });
  }

  @override
  Future<void> close() {
    _statusSubscription?.cancel();
    return super.close();
  }
}
```

Notice that the bloc:
1. Connects the socket on demand (not at app start)
2. Watches `connectionStatusStream` to know when it's safe to send queued messages
3. Cancels the stream subscription on `close()` — important to prevent memory leaks

---

## Sending a message

```dart
// From anywhere that has access to the service
ChatSocketServices.instance().sendMessage({
  'type': 'message',
  'to': recipientId,
  'message': text,
  'chat_room_id': roomId,
});
```

`sendMessage` encodes the map to JSON and drops it on the WebSocket sink. If the socket is not connected, it logs a warning and returns without throwing — the message should be saved as "unsent" in Isar before calling this, so it can be retried when the connection restores.

---

## The unsent message queue

If the user sends a message while offline, the flow is:

1. Widget dispatches a chat send event
2. Bloc saves the message to Isar (`unsent_messages_table`) via `SaveUnsentMessageUseCase`
3. Bloc tries to send via the socket — fails silently if disconnected
4. When `connectionStatusStream` emits `true` (reconnected), `ChatSocketsBloc` loads all unsent messages and retransmits them
5. On successful send, the message is deleted from the unsent queue via `DeleteUnsentByMessageIdUseCase`

This means no messages are lost if the app goes offline mid-conversation.

---

## How to add a new socket endpoint

**Step 1** — Create the service:

```dart
// lib/data/websocket_services/notifications_socket_services/notifications_socket_service.dart
class NotificationsSocketService extends BaseSocketService {
  static final NotificationsSocketService _instance = NotificationsSocketService();
  factory NotificationsSocketService.instance() => _instance;

  NotificationsSocketService()
      : super(uri: Uri.parse("$WS_BASE_URL/notifications"), logTag: 'NotificationsSocket');

  static Stream<String> get messageStream => _instance.messageStream;
  static Stream<bool> get connectionStatusStream => _instance.connectionStatusStream;
}
```

**Step 2** — Create the datasource that parses incoming messages:

```dart
// lib/data/datasources/socket/notifications_socket_datasource.dart
class NotificationsSocketDatasource {
  Stream<NotificationModel> get notifications =>
      NotificationsSocketService.messageStream
          .map((raw) => NotificationModel.fromJson(jsonDecode(raw)));
}
```

**Step 3** — Create the bloc that connects and listens. Follow the `ChatSocketsBloc` pattern: connect on a load event, listen to `connectionStatusStream`, cancel subscriptions on `close`.

**Step 4** — Register the datasource and bloc in `injection_container.dart`.

---

## Debugging sockets

The `logTag` in each service is passed to `dart:developer`'s `log()` function. In debug mode, filter the console by the tag:

- `ChatSocketServices` — chat messages
- `ConnectionsSocketServices` — connection events
- `LobbySocketServices` — lobby events

Common issues:

**Stuck in reconnect loop** — usually a bad token or the server is down. Check if `refreshToken()` is failing.

**Messages arriving out of order** — the stream is async; if you process messages in parallel, sequencing is not guaranteed. Process them sequentially.

**Connection dropped immediately** — if the server sends a 401 or 403 during the WebSocket handshake, the base class catches it, triggers token refresh, and reschedules reconnect. Check logs for "Token expired/invalid (403/401) during handshake."
