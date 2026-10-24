class ReviewEntity {
  final String id;
  final String productId;
  final int rating;
  final String reviewText;
  final DateTime createdAt;
  final String? buyerDisplayName;
  final bool isVerifiedPurchase;
  final bool isMine;

  const ReviewEntity({
    required this.id,
    required this.productId,
    required this.rating,
    required this.reviewText,
    required this.createdAt,
    this.buyerDisplayName,
    this.isVerifiedPurchase = false,
    this.isMine = false,
  });

  factory ReviewEntity.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['created_at'];
    return ReviewEntity(
      id: (json['id'] ?? '').toString(),
      productId: (json['product_id'] ?? '').toString(),
      rating: (json['rating'] as num?)?.round() ?? 0,
      reviewText: (json['review_text'] ?? json['comment'] ?? '').toString(),
      createdAt: createdAtRaw is String
          ? DateTime.tryParse(createdAtRaw) ?? DateTime.now()
          : DateTime.now(),
      buyerDisplayName: (json['buyer_display_name'] ??
              json['profiles']?['full_name'] ??
              json['profiles']?['shop_name'])
          as String?,
      isVerifiedPurchase: json['verified_purchase'] == true,
      isMine: json['is_mine'] == true,
    );
  }
}
