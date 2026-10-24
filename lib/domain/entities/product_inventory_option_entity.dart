/// Variante de stock sélectionnable pour un produit.
class ProductInventoryOptionEntity {
  final String id;
  final String? color;
  final String? size;
  final bool isAvailable;
  final bool isInStock;
  final int? stockQuantity;

  const ProductInventoryOptionEntity({
    required this.id,
    this.color,
    this.size,
    required this.isAvailable,
    required this.isInStock,
    this.stockQuantity,
  });

  String get label {
    final attributes = [color, size].whereType<String>().toList();
    return attributes.isEmpty ? 'Standard' : attributes.join(' · ');
  }

  factory ProductInventoryOptionEntity.fromJson(Map<String, dynamic> json) {
    final quantity = json['stock_quantity'] as int?;
    return ProductInventoryOptionEntity(
      id: json['id']?.toString() ?? '',
      color: json['color'] as String?,
      size: json['size'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
      isInStock: json['in_stock'] as bool? ?? (quantity != null && quantity > 0),
      stockQuantity: quantity,
    );
  }
}
