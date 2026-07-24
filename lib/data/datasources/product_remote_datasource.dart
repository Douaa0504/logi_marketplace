import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/product_model.dart';

class ProductRemoteDataSource {
  final SupabaseClient _supabaseClient;

  ProductRemoteDataSource(this._supabaseClient);

  Future<List<ProductModel>> fetchProducts() async {
    final response = await _supabaseClient
        .from('products')
        .select()
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => ProductModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}