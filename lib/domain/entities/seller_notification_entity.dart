/// Représente une notification de la boutique du vendeur concerné.
class SellerNotificationEntity {
  final String id;
  final String sellerId;
  final String type;
  final String message;
  final String? productId;
  final String? productTitle;
  final bool isRead;
  final DateTime createdAt;

  const SellerNotificationEntity({
    required this.id,
    required this.sellerId,
    required this.type,
    required this.message,
    this.productId,
    this.productTitle,
    required this.isRead,
    required this.createdAt,
  });

  factory SellerNotificationEntity.fromJson(Map<String, dynamic> json) {
    return SellerNotificationEntity(
      id: (json['id'] ?? '').toString(),
      sellerId: (json['seller_id'] ?? '').toString(),
      type: (json['notification_type'] ?? 'info').toString(),
      message: (json['message'] ?? '').toString(),
      productId: json['product_id']?.toString(),
      productTitle: json['product_title']?.toString(),
      isRead: json['is_read'] == true,
      createdAt: json['created_at'] is String
          ? DateTime.tryParse(json['created_at'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }
}
