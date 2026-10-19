import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

/// Storage bucket for product photos. Confirm this exact name exists in
/// the Supabase project (Storage), is public, and allows authenticated uploads.
const String productImagesStorageBucket = 'products';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> fetchProducts();
  Future<List<ProductModel>> getProductsBySeller(String sellerId);
  Future<ProductModel> addProduct(ProductModel product, File? imageFile);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  String _sanitizeStorageFileName(String rawValue) {
    final sanitized = rawValue
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^[._]+|[._]+$'), '');

    return sanitized.isEmpty ? 'product' : sanitized;
  }

  String? _remoteImageUrlOrNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return value.trim();
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await supabaseClient
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<ProductModel>> fetchProducts() async {
    return getProducts();
  }

  @override
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    final response = await supabaseClient
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product, File? imageFile) async {
    String? imageUrl;

    if (imageFile != null) {
      final safeTitle = _sanitizeStorageFileName(product.title);
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_$safeTitle.jpg';
      final path = 'products/$fileName';

      await supabaseClient.storage
          .from(productImagesStorageBucket)
          .upload(
            path,
            imageFile,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );
      imageUrl = supabaseClient.storage
          .from(productImagesStorageBucket)
          .getPublicUrl(path);
    } else {
      imageUrl = _remoteImageUrlOrNull(product.imageUrl);
    }

    final productData = Map<String, dynamic>.from(product.toJson());
    final id = productData['id'];
    if (id == null || id.toString().trim().isEmpty) {
      productData.remove('id');
    }
    productData['image_url'] = imageUrl;

    final response = await supabaseClient
        .from('products')
        .insert(productData)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }
}
