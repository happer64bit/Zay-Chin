class CartItem {
  final String id;
  final String groupId;
  final String itemName;
  final int quantity;
  final int current;
  final String category;
  final int price;

  CartItem({
    required this.id,
    required this.groupId,
    required this.itemName,
    required this.quantity,
    required this.current,
    required this.category,
    required this.price,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'] as String,
      groupId: json['group_id'] as String,
      itemName: json['item_name'] as String,
      quantity: (json['quantity'] as num).toInt(),
      current: (json['current'] as num).toInt(),
      category: json['category'] as String,
      price: (json['price'] as num).toInt(),
    );
  }
}


