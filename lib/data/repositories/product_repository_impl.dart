import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';

class ProductRepositoryImpl implements ProductRepository {
  final SupabaseClient supabaseClient;

  ProductRepositoryImpl({required this.supabaseClient});

  @override
  Future<void> addProduct(ProductEntity product, [File? imageFile]) async {
    String? imageUrl;

    if (imageFile != null) {
      final fileName = '${DateTime.now().millisecondsSinceEpoch}_${product.sellerId}.jpg';
      final path = 'products/$fileName';

      await supabaseClient.storage.from('products').upload(
        path,
        imageFile,
        fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
      );

      imageUrl = supabaseClient.storage.from('products').getPublicUrl(path);
    }

    await supabaseClient.from('products').insert({
      'title': product.title,
      'description': product.description,
      'price': product.price,
      'category': product.category,
      'seller_id': product.sellerId,
      'image_url': imageUrl ?? product.imageUrl,
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<ProductEntity>> getProducts() async {
    final response = await supabaseClient
        .from('products')
        .select()
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;

    return data.map((json) {
      return ProductEntity(
        id: json['id'].toString(),
        sellerId: json['seller_id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'],
        price: (json['price'] as num).toDouble(),
        category: json['category'] ?? 'Other',
        imageUrl: json['image_url'],
        createdAt: DateTime.parse(json['created_at']),
      );
    }).toList();
  }
}