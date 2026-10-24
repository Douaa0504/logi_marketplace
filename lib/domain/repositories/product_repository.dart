import 'dart:io';

import '../entities/product_entity.dart';

/// Contrat d'accès aux produits et à l'inventaire pour les couches métier.
abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<List<ProductEntity>> getProductsBySeller(String sellerId);
  Future<void> addProduct(ProductEntity product, [File? imageFile]);
  Future<void> updateProduct(ProductEntity product, [File? imageFile]);
  Future<String?> deleteProduct(String productId);
  Future<Map<String, dynamic>> getSellerProductInventory(String productId);
  Future<Map<String, dynamic>> getSellerFavoriteCounts();
}
