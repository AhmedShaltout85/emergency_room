// lib/screens/manage_system/control/complaint_live_updates.dart
//
// Listens to the server's complaint WebSocket and calls [onChanged] whenever
// any complaint is created / updated / finished / deleted — by ANY user.
// Reconnects by itself (1s, 2s, 4s … max 30s) and re-syncs after reconnecting
// so events missed while offline are not lost.
//
// pubspec.yaml:  web_socket_channel: ^3.0.1

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class ComplaintLiveUpdates {
  ComplaintLiveUpdates({String? url}) : _url = url ?? defaultUrl;

  /// Same host / port / context path as ComplaintRepo.baseUrl, but ws://
  /// (use wss:// when the API is served over https).
  static const String defaultUrl =
      'ws://localhost:9999/pick-location/ws/complaints';

  final String _url;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _sub;
  Timer? _reconnectTimer;
  Timer? _debounce;
  VoidCallback? _onChanged;
  bool _stopped = true;
  int _attempt = 0;

  bool get isRunning => !_stopped;

  void start(VoidCallback onChanged) {
    _onChanged = onChanged;
    _stopped = false;
    _connect();
  }

  void stop() {
    _stopped = true;
    _reconnectTimer?.cancel();
    _debounce?.cancel();
    _sub?.cancel();
    _channel?.sink.close();
    _sub = null;
    _channel = null;
  }

  void _connect() {
    if (_stopped) return;
    try {
      final channel = WebSocketChannel.connect(Uri.parse(_url));
      _channel = channel;

      channel.ready.then((_) {
        if (_stopped) return;
        _attempt = 0;
        // (re)connected → resync once, in case something changed meanwhile
        _notify();
      }).catchError((_) {
        // the stream's onError / onDone below schedules the reconnect
      });

      _sub = channel.stream.listen(
        (_) => _notify(), // any message = "complaints changed"
        onError: (_) => _scheduleReconnect(),
        onDone: _scheduleReconnect,
        cancelOnError: true,
      );
    } catch (e) {
      debugPrint('ComplaintLiveUpdates connect error: $e');
      _scheduleReconnect();
    }
  }

  void _scheduleReconnect() {
    if (_stopped) return;
    _sub?.cancel();
    _sub = null;
    _channel = null;
    _reconnectTimer?.cancel();

    final seconds = (1 << _attempt).clamp(1, 30);
    if (_attempt < 5) _attempt++;
    _reconnectTimer = Timer(Duration(seconds: seconds), _connect);
  }

  /// Several events in a row (e.g. a batch of updates) → one refresh.
  void _notify() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!_stopped) _onChanged?.call();
    });
  }
}
