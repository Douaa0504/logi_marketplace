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
    return data
        .map(
          (json) => OrderEntity(
            id: json['id'].toString(),
            buyerId: json['buyer_id'] ?? '',
            sellerId: json['seller_id'] ?? '',
            productId: json['product_id'] ?? '',
            quantity: json['quantity'] ?? 1,
            totalPrice: (json['total_price'] as num).toDouble(),
            status: json['status'] ?? 'pending',
            createdAt: DateTime.parse(json['created_at']),
          ),
        )
        .toList();
  }

  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    await supabaseClient.rpc(
      'seller_update_order_status',
      params: {'p_order_id': orderId, 'p_new_status': newStatus},
    );
  }
}
