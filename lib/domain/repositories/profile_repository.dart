import 'dart:io';

import '../entities/shop_profile_entity.dart';

abstract class ProfileRepository {
  Future<ShopProfileEntity> getCurrentSellerProfile();
  Future<ShopProfileEntity> getSellerProfile(String sellerId);
  Future<ShopProfileEntity> updateSellerShopProfile({
    required String? shopName,
    required String? shopDescription,
    required String? shopLogoUrl,
  });
  Future<String> uploadSellerShopLogo(File imageFile);
}
