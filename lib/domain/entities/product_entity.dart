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

  /// Public HTTP(S) URL only. Local device paths are treated as missing.
  String? get remoteImageUrl {
    final url = imageUrl;
    if (url == null || url.trim().isEmpty) return null;
    final uri = Uri.tryParse(url.trim());
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return url.trim();
  }
}
