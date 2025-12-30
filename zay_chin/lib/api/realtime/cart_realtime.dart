import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import '../config.dart';
import '../models/cart.dart';
import '../services/cart_service.dart';

class CartRealtime {
  final CartService _service;
  WebSocketChannel? _channel;
  final _controller = StreamController<List<CartItem>>.broadcast();
  String? _currentGroupId;

  CartRealtime(this._service);

  Stream<List<CartItem>> get stream => _controller.stream;

  Future<void> connect(String groupId) async {
    await disconnect();
    _currentGroupId = groupId;

    // Initial fetch
    final initial = await _service.getCart(groupId);
    if (!_controller.isClosed) {
      _controller.add(initial);
    }

    // Build ws URL from baseUrl (http -> ws, https -> wss)
    final base = ApiConfig.baseUrl;
    final wsBase = base.startsWith('https')
        ? base.replaceFirst('https', 'wss')
        : base.replaceFirst('http', 'ws');

    final uri = Uri.parse('$wsBase/cart/ws?groupId=$groupId');
    _channel = WebSocketChannel.connect(uri);

    _channel!.stream.listen(
      (message) async {
        try {
          final data = jsonDecode(message as String) as Map<String, dynamic>;
          if (data['type'] == 'cart_updated' &&
              data['groupId'] == groupId) {
            final items = await _service.getCart(groupId);
            if (!_controller.isClosed) {
              _controller.add(items);
            }
          }
        } catch (_) {
          // Ignore malformed messages
        }
      },
      onError: (_) {},
      onDone: () {},
    );
  }

  Future<void> refresh() async {
    if (_currentGroupId != null) {
      await connect(_currentGroupId!);
    }
  }

  Future<void> disconnect() async {
    await _channel?.sink.close();
    _channel = null;
  }

  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
  }
}


