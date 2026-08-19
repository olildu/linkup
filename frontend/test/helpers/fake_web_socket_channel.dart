// Minimal fake WebSocketChannel for BaseSocketService tests: incoming data
// is driven through [incoming]; outgoing frames are captured in [sentFrames].
import 'dart:async';

import 'package:mocktail/mocktail.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class FakeWebSocketSink extends Fake implements WebSocketSink {
  final FakeWebSocketChannel channel;
  final sentFrames = <dynamic>[];
  bool throwOnAdd = false;

  FakeWebSocketSink(this.channel);

  @override
  void add(dynamic data) {
    if (throwOnAdd) throw StateError('sink closed');
    sentFrames.add(data);
  }

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    channel._closeCode = closeCode;
    channel._closeReason = closeReason;
    await channel.incoming.close();
  }
}

class FakeWebSocketChannel extends Fake implements WebSocketChannel {
  final incoming = StreamController<dynamic>();
  late final FakeWebSocketSink fakeSink = FakeWebSocketSink(this);
  int? _closeCode;
  String? _closeReason;

  @override
  Stream<dynamic> get stream => incoming.stream;

  @override
  WebSocketSink get sink => fakeSink;

  @override
  int? get closeCode => _closeCode;

  @override
  String? get closeReason => _closeReason;

  List<dynamic> get sentFrames => fakeSink.sentFrames;
}
