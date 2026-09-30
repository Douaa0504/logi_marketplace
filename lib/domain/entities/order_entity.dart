class OrderEntity {
  final String id;
  final String buyerId;
  final String sellerId;
  final String productId;
  final int quantity;
  final double totalPrice;
  final String status;
  final DateTime createdAt;

  OrderEntity({
    required this.id,
    required this.buyerId,
    required this.sellerId,
    required this.productId,
    required this.quantity,
    required this.totalPrice,
    required this.status,
    required this.createdAt,
  });
}