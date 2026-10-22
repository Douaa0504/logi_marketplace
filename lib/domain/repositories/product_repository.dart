import 'dart:io';

import '../entities/product_entity.dart';

abstract class ProductRepository {
  Future<List<ProductEntity>> getProducts();
  Future<void> addProduct(ProductEntity product, [File? imageFile]);
  Future<void> updateProduct(ProductEntity product, [File? imageFile]);
  Future<Map<String, dynamic>> getSellerProductInventory(String productId);
}
