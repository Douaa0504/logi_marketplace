import 'dart:io';

import '../entities/shop_profile_entity.dart';

abstract class ProfileRepository {
  /// Charge le profil privé de la boutique de l'utilisateur connecté.
  Future<ShopProfileEntity> getCurrentSellerProfile();
  /// Charge les champs de profil exposés sur la vitrine publique.
  Future<ShopProfileEntity> getSellerProfile(String sellerId);
  Future<ShopProfileEntity> updateSellerShopProfile({
    required String? shopName,
    required String? shopDescription,
    required String? shopLogoUrl,
  });
  Future<String> uploadSellerShopLogo(File imageFile);
}
