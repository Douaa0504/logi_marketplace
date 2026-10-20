import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';

class CartService extends ChangeNotifier {
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemEntity> _items = [];

  List<CartItemEntity> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(ProductEntity product) {
    final index = _items.indexWhere((item) => item.product.id == product.id);
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(CartItemEntity(product: product));
    }
    notifyListeners();
  }

  void removeFromCart(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);
    if (index >= 0) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        _items[index].quantity = quantity;
      }
      notifyListeners();
    }
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }

  Future<void> checkout() async {
    final client = Supabase.instance.client;
    final buyerId = client.auth.currentUser?.id;

    if (buyerId == null) {
      throw Exception('User must be logged in to checkout');
    }

    if (_items.isEmpty) {
      throw Exception('Cart is empty');
    }

    final List<Map<String, dynamic>> orderRows = _items.map((item) {
      return {
        'buyer_id': buyerId,
        'seller_id': item.product.sellerId,
        'product_id': item.product.id,
        'quantity': item.quantity,
        'total_price': item.totalPrice,
        'status': 'pending',
      };
    }).toList();

    await client.from('orders').insert(orderRows);
    clearCart();
  }
}
