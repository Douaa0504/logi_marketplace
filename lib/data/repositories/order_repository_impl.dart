import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/order_entity.dart';

class OrderRepositoryImpl {
  final SupabaseClient supabaseClient;

  OrderRepositoryImpl({required this.supabaseClient});

  Future<List<OrderEntity>> getSellerOrders(String sellerId) async {
    final response = await supabaseClient
        .from('orders')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    final data = response as List<dynamic>;
    if (data.isEmpty) return [];

    final productIds = data
        .map((json) => json['product_id'].toString())
        .toSet()
        .toList();
    final productRows = await supabaseClient
        .from('products')
        .select('id, title, image_url')
        .inFilter('id', productIds);
    final productsById = {
      for (final row in productRows as List<dynamic>)
        row['id'].toString(): row,
    };

    return data.map((json) {
      final product = productsById[json['product_id'].toString()];
      return OrderEntity(
        id: json['id'].toString(),
        buyerId: json['buyer_id'] ?? '',
        sellerId: json['seller_id'] ?? '',
        productId: json['product_id'] ?? '',
        quantity: json['quantity'] ?? 1,
        totalPrice: (json['total_price'] as num).toDouble(),
        status: json['status'] ?? 'pending',
        createdAt: DateTime.parse(json['created_at']),
        productTitle:
            json['product_title_snapshot'] as String? ??
            product?['title'] as String? ??
            'Product no longer available',
        productImageUrl:
            json['product_image_url_snapshot'] as String? ??
            product?['image_url'] as String?,
        variantColor: json['variant_color'] as String?,
        variantSize: json['variant_size'] as String?,
      );
    }).toList();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await supabaseClient.rpc(
      'seller_update_order_status',
      params: {'p_order_id': orderId, 'p_new_status': newStatus},
    );
  }
}
