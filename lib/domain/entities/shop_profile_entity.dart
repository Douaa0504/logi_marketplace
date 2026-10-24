class ShopProfileEntity {
  final String id;
  final String? fullName;
  final String? shopName;
  final String? shopDescription;
  final String? shopLogoUrl;
  final String? role;

  const ShopProfileEntity({
    required this.id,
    this.fullName,
    this.shopName,
    this.shopDescription,
    this.shopLogoUrl,
    this.role,
  });

  factory ShopProfileEntity.fromJson(Map<String, dynamic> json) {
    final fullName = json['full_name'] as String?;
    final shopName = json['shop_name'] as String?;
    final shopDescription = json['shop_description'] as String?;
    final logoUrl = json['shop_logo_url'] as String?;
    final role = json['role'] as String?;

    return ShopProfileEntity(
      id: (json['id'] ?? '').toString(),
      fullName: fullName,
      shopName: shopName,
      shopDescription: shopDescription,
      shopLogoUrl: logoUrl,
      role: role,
    );
  }

  String get publicShopName {
    final value = (shopName ?? '').trim();
    return value.isEmpty ? 'Seller Shop' : value;
  }

  String get publicShopDescription {
    final value = (shopDescription ?? '').trim();
    return value.isEmpty
        ? 'Curated finds and quality essentials for everyday living.'
        : value;
  }

  String? get publicShopLogoUrl {
    final value = shopLogoUrl?.trim();
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    return (uri != null && (uri.scheme == 'http' || uri.scheme == 'https'))
        ? value
        : null;
  }
}
