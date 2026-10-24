import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';
import '../models/product_model.dart';

/// Traduit les opérations produit du domaine vers le datasource distant.
class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required SupabaseClient supabaseClient,
    ProductRemoteDataSource? remoteDataSource,
  }) : remoteDataSource =
           remoteDataSource ??
           ProductRemoteDataSourceImpl(supabaseClient: supabaseClient);

  @override
  Future<void> addProduct(ProductEntity product, [File? imageFile]) async {
    // Le Model adapte l'Entity du domaine au format attendu par le datasource.
    final model = ProductModel(
      id: product.id,
      sellerId: product.sellerId,
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      createdAt: product.createdAt,
      inventoryMode: product.inventoryMode,
      inventoryOptions: product.inventoryOptions,
    );
    await remoteDataSource.addProduct(model, imageFile);
  }

  @override
  Future<void> updateProduct(ProductEntity product, [File? imageFile]) async {
    final model = ProductModel(
      id: product.id,
      sellerId: product.sellerId,
      title: product.title,
      description: product.description,
      price: product.price,
      imageUrl: product.imageUrl,
      category: product.category,
      createdAt: product.createdAt,
      inventoryMode: product.inventoryMode,
      inventoryOptions: product.inventoryOptions,
    );
    await remoteDataSource.updateProduct(model, imageFile);
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    return remoteDataSource.getProducts();
  }

  @override
  Future<List<ProductEntity>> getProductsBySeller(String sellerId) async {
    return remoteDataSource.getProductsBySeller(sellerId);
  }

  @override
  Future<Map<String, dynamic>> getSellerProductInventory(
    String productId,
  ) {
    return remoteDataSource.getSellerProductInventory(productId);
  }

  @override
  Future<String?> deleteProduct(String productId) {
    return remoteDataSource.deleteProduct(productId);
  }

  @override
  Future<Map<String, dynamic>> getSellerFavoriteCounts() {
    return remoteDataSource.getSellerFavoriteCounts();
  }
}
