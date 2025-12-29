import 'dart:async';

import '../models/cart.dart';
import '../realtime/cart_realtime.dart';
import '../services/cart_service.dart';

class CartController {
  final String groupId;
  final CartService _service;
  late final CartRealtime _realtime;

  CartController(this.groupId, this._service) {
    _realtime = CartRealtime(_service);
  }

  Stream<List<CartItem>> get stream => _realtime.stream;

  Future<void> init() async {
    await _realtime.connect(groupId);
  }

  Future<void> refresh() async {
    await _realtime.connect(groupId);
  }

  Future<void> addItem({
    required String name,
    required String category,
    required int price,
    required int quantity,
  }) async {
    await _service.addItem(
      groupId: groupId,
      name: name,
      category: category,
      price: price,
      quantity: quantity,
    );
  }

  Future<void> updateItem({
    required String id,
    int? quantity,
    int? current,
    String? name,
    String? category,
    int? price,
  }) async {
    await _service.updateItem(
      groupId: groupId,
      id: id,
      quantity: quantity,
      current: current,
      name: name,
      category: category,
      price: price,
    );
  }

  Future<void> removeItem(String id) async {
    await _service.removeItem(groupId: groupId, id: id);
  }

  Future<void> dispose() async {
    await _realtime.dispose();
  }
}


