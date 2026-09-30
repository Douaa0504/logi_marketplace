import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> fetchProducts(); // تم إضافتها لإنهاء الخطأ
  Future<List<ProductModel>> getProductsBySeller(String sellerId);
  Future<ProductModel> addProduct(ProductModel product, File? imageFile);
}

class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await supabaseClient
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<List<ProductModel>> fetchProducts() async {
    return await getProducts(); // تقوم باستدعاء getProducts مباشرة
  }

  @override
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    final response = await supabaseClient
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    return (response as List).map((json) => ProductModel.fromJson(json)).toList();
  }

  @override
  Future<ProductModel> addProduct(ProductModel product, File? imageFile) async {
    String? imageUrl = product.imageUrl;

    if (imageFile != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${product.title.replaceAll(' ', '_')}.jpg';
      final path = 'products/$fileName';

      await supabaseClient.storage.from('product-images').upload(path, imageFile);
      imageUrl = supabaseClient.storage.from('product-images').getPublicUrl(path);
    }

    final productData = product.toJson();
    productData['image_url'] = imageUrl;

    final response = await supabaseClient
        .from('products')
        .insert(productData)
        .select()
        .single();

    return ProductModel.fromJson(response);
  }
}