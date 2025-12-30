import 'package:dio/dio.dart';
import '../client.dart';
import '../config.dart';
import '../models/cart.dart';

class CartService {
  final ApiClient _client = ApiClient();

  Future<List<CartItem>> getCart(String groupId) async {
    try {
      final response = await _client.dio.get('${ApiConfig.cartPrefix}/$groupId');
      final List<dynamic> data = response.data;
      return data.map((json) => CartItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<CartItem>> addItem({
    required String groupId,
    required String name,
    required String category,
    required int price,
    required int quantity,
    double? locationLat,
    double? locationLng,
    String? locationName,
  }) async {
    try {
      final response = await _client.dio.post(
        '${ApiConfig.cartPrefix}/$groupId',
        data: {
          'item_name': name,
          'category': category,
          'price': price,
          'quantity': quantity,
          if (locationLat != null) 'location_lat': locationLat,
          if (locationLng != null) 'location_lng': locationLng,
          if (locationName != null) 'location_name': locationName,
        },
      );
      final List<dynamic> data = response.data;
      return data.map((json) => CartItem.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> updateItem({
    required String groupId,
    required String id,
    int? quantity,
    int? current,
    String? name,
    String? category,
    int? price,
    double? locationLat,
    double? locationLng,
    String? locationName,
  }) async {
    try {
      await _client.dio.patch(
        '${ApiConfig.cartPrefix}/$groupId/$id',
        data: {
          if (name != null) 'item_name': name,
          if (category != null) 'category': category,
          if (price != null) 'price': price,
          if (quantity != null) 'quantity': quantity,
          if (current != null) 'current': current,
          if (locationLat != null) 'location_lat': locationLat,
          if (locationLng != null) 'location_lng': locationLng,
          if (locationName != null) 'location_name': locationName,
        },
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> removeItem({
    required String groupId,
    required String id,
  }) async {
    try {
      await _client.dio.delete('${ApiConfig.cartPrefix}/$groupId', data: {
        'id': id
      });
    } on DioException catch (primary) {
      final status = primary.response?.statusCode;
      if (status == 404 || status == 405) {
        try {
          await _client.dio.delete(
            '${ApiConfig.cartPrefix}/$groupId',
            data: {'id': id},
          );
          return;
        } on DioException catch (fallback) {
          throw _handleError(fallback);
        }
      }
      throw _handleError(primary);
    }
  }

  String _handleError(DioException error) {
    if (error.response != null) {
      final data = error.response!.data;
      if (data is Map && data.containsKey('message')) {
        return data['message'] as String;
      }
      return 'An error occurred: ${error.response!.statusCode}';
    }
    return error.message ?? 'An unexpected error occurred';
  }
}
