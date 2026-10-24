import 'dart:io';

import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/repositories/profile_repository.dart';
import '../datasources/profile_remote_datasource.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource remoteDataSource;

  ProfileRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ShopProfileEntity> getCurrentSellerProfile() async {
    final response = await remoteDataSource.getCurrentProfile();
    return ShopProfileEntity.fromJson(response);
  }

  @override
  Future<ShopProfileEntity> getSellerProfile(String sellerId) async {
    final response = await remoteDataSource.getProfileById(sellerId);
    return ShopProfileEntity.fromJson(response);
  }

  @override
  Future<ShopProfileEntity> updateSellerShopProfile({
    required String? shopName,
    required String? shopDescription,
    required String? shopLogoUrl,
  }) async {
    final response = await remoteDataSource.updateCurrentProfile(
      shopName: shopName,
      shopDescription: shopDescription,
      shopLogoUrl: shopLogoUrl,
    );
    return ShopProfileEntity.fromJson(response);
  }

  @override
  Future<String> uploadSellerShopLogo(File imageFile) async {
    return remoteDataSource.uploadCurrentShopLogo(imageFile);
  }
}
