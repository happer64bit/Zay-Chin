class CartItem {
  final String id;
  final String groupId;
  final String itemName;
  final int quantity;
  final int current;
  final String category;
  final int price;
  final double? locationLat;
  final double? locationLng;
  final String? locationName;

  CartItem({
    required this.id,
    required this.groupId,
    required this.itemName,
    required this.quantity,
    required this.current,
    required this.category,
    required this.price,
    this.locationLat,
    this.locationLng,
    this.locationName,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse numbers that might come as string, num, or null
    int safeParseInt(dynamic value) {
      if (value == null) return 0;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        return parsed ?? 0;
      }
      return 0;
    }

    // Handle location coordinates - they might come as string, num, or null
    double? parseLocation(dynamic value) {
      if (value == null) return null;
      if (value is num) return value.toDouble();
      if (value is String) {
        // Handle empty strings
        if (value.trim().isEmpty) return null;
        final parsed = double.tryParse(value);
        return parsed;
      }
      return null;
    }

    return CartItem(
      id: json['id'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      itemName: json['item_name'] as String? ?? '',
      quantity: safeParseInt(json['quantity']),
      current: safeParseInt(json['current']),
      category: json['category'] as String? ?? '',
      price: safeParseInt(json['price']),
      locationLat: parseLocation(json['location_lat']),
      locationLng: parseLocation(json['location_lng']),
      locationName: json['location_name'] as String?,
    );
  }
}

