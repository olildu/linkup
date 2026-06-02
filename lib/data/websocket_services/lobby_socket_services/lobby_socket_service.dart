import 'dart:async';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;

import 'package:linkup/core/constants/app_constants.dart';

class LobbySocketService {
  static final FlutterSecureStorage _secureStorage = FlutterSecureStorage();
  static WebSocketChannel? _lobbyChannel;
  static String? _authToken;

  static final StreamController<String> _lobbyMessageController = StreamController<String>.broadcast();
  static Stream<String> get lobbyMessageStream => _lobbyMessageController.stream;

  static final StreamController<String?> _lobbyDisconnectController = StreamController<String?>.broadcast();
  static Stream<String?> get lobbyDisconnectStream => _lobbyDisconnectController.stream;

  static Timer? _reconnectTimer;
  static int _reconnectAttemptCount = 0;
  static const Duration _reconnectDelay = Duration(seconds: 5);

  static bool _manualDisconnect = false;
  static bool _isConnecting = false;

  static bool get isConnected => _lobbyChannel != null && _lobbyChannel?.closeCode == null && !_isConnecting;

  static Future<void> connect({bool isRetry = false}) async {
    if (_isConnecting && !isRetry) {
      log("Lobby WebSocket connection attempt already in progress.");
      return;
    }
    if (isConnected && !isRetry) {
      log("Lobby WebSocket already connected.");
      return;
    }

    _isConnecting = true;
    if (!isRetry) {
      _manualDisconnect = false;
    }

    _authToken = await _secureStorage.read(key: 'access_token');
    if (_authToken == null) {
      log("No auth token found. Lobby WebSocket connection aborted.");
      _lobbyDisconnectController.add("No token, connection aborted.");
      _isConnecting = false;
      return;
    }

    final uri = Uri.parse("$WS_BASE_URL/lobby");

    log("Attempting to connect to Lobby WebSocket: $uri (Attempt: ${_reconnectAttemptCount + 1})");

    try {
      _lobbyChannel = IOWebSocketChannel.connect(
        uri,
        headers: {'Authorization': 'Bearer $_authToken'},
        pingInterval: const Duration(seconds: 1),
        connectTimeout: const Duration(seconds: 5),
      );

      _isConnecting = false;
      _lobbyChannel!.stream.listen(
        (data) {
          _lobbyMessageController.add(data);

          if (_reconnectAttemptCount > 0) {
            log("Lobby WebSocket reconnected successfully.");
          }
          _reconnectAttemptCount = 0;
        },
        onDone: () {
          _isConnecting = false;
          final closeCode = _lobbyChannel?.closeCode;
          final closeReason = _lobbyChannel?.closeReason;
          log("Lobby WebSocket closed. Code: $closeCode, Reason: $closeReason, Manually disconnected: $_manualDisconnect");
          _lobbyChannel = null;
          if (!_manualDisconnect) {
            _lobbyDisconnectController.add("Closed (Done): Code $closeCode");
            _scheduleReconnect();
          } else {
            _lobbyDisconnectController.add("Manually disconnected (Done)");
          }
        },
        onError: (error) {
          _isConnecting = false;
          log("Lobby WebSocket error: $error. Manually disconnected: $_manualDisconnect");
          _lobbyChannel = null;
          if (!_manualDisconnect) {
            _lobbyDisconnectController.add("Error: $error");
            _scheduleReconnect();
          } else {
            _lobbyDisconnectController.add("Error during manual disconnect: $error");
          }
        },
        cancelOnError: true,
      );

      log("Lobby WebSocket connected to $uri and listener is active.");
    } catch (e) {
      _isConnecting = false;
      log("Failed to connect to Lobby WebSocket (exception): $e");
      _lobbyChannel = null;
      if (!_manualDisconnect) {
        _lobbyDisconnectController.add("Connection failed: $e");
        _scheduleReconnect();
      } else {
        _lobbyDisconnectController.add("Connection failed during manual disconnect attempt: $e");
      }
    }
  }

  static void _scheduleReconnect() {
    if (_reconnectTimer != null && _reconnectTimer!.isActive) {
      return;
    }
    if (_manualDisconnect) {
      log("Manual disconnect in progress. No reconnect scheduled.");
      return;
    }

    _reconnectAttemptCount++;
    log("Scheduling Lobby WebSocket reconnect attempt $_reconnectAttemptCount in ${_reconnectDelay.inSeconds} seconds...");

    _reconnectTimer = Timer(_reconnectDelay, () {
      log("Retrying Lobby WebSocket connection (attempt $_reconnectAttemptCount)...");
      connect(isRetry: true);
    });
  }

  static void sendMessage({required Map<String, dynamic> message}) {
    if (!isConnected) {
      log("Lobby WebSocket not connected. Cannot send message. Channel: $_lobbyChannel, isConnecting: $_isConnecting");
      return;
    }

    final payload = jsonEncode(message);

    try {
      _lobbyChannel!.sink.add(payload);
    } catch (e) {
      log("Failed to send message on Lobby WebSocket: $e. Disconnecting and trying reconnect.");
      _lobbyChannel = null;
      _isConnecting = false;
      if (!_manualDisconnect) {
        _lobbyDisconnectController.add("Send failed: $e");
        _scheduleReconnect();
      }
    }
  }

  static void disconnect() {
    log("Manual Lobby WebSocket disconnection initiated.");
    _manualDisconnect = true;
    _reconnectTimer?.cancel();
    _reconnectAttemptCount = 0;

    if (_lobbyChannel != null) {
      _lobbyChannel!.sink.close(status.normalClosure);
      _lobbyChannel = null;
      log("Lobby WebSocket connection closed by client.");
    } else {
      log("No active Lobby WebSocket connection to close.");
    }
    _isConnecting = false;
    _lobbyDisconnectController.add("Manually disconnected by client");
  }

  static void dispose() {
    log("Disposing LobbySocketService.");
    disconnect();
    _lobbyMessageController.close();
    _lobbyDisconnectController.close();
  }
}
