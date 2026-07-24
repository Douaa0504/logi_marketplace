class ProductEntity {
  final String id;
  final String sellerId;
  final String title;
  final String? description;
  final double price;
  final String? imageUrl;
  final String category;
  final DateTime createdAt;

  ProductEntity({
    required this.id,
    required this.sellerId,
    required this.title,
    this.description,
    required this.price,
    this.imageUrl,
    required this.category,
    required this.createdAt,
  });
}