import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/cart_item_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/entities/product_inventory_option_entity.dart';

class CartService extends ChangeNotifier {
  // Le panier partagé conserve son état lors du passage entre les onglets.
  static final CartService _instance = CartService._internal();
  factory CartService() => _instance;
  CartService._internal();

  final List<CartItemEntity> _items = [];
  String? _pendingCheckoutRequestId;
  String? _pendingCheckoutPayload;

  List<CartItemEntity> get items => List.unmodifiable(_items);

  double get totalAmount =>
      _items.fold(0.0, (sum, item) => sum + item.totalPrice);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  void addToCart(
    ProductEntity product, {
    ProductInventoryOptionEntity? option,
  }) {
    if (product.inventoryMode == 'unconfigured') {
      throw StateError('The seller has not configured inventory for this product.');
    }

    final ProductInventoryOptionEntity selectedOption;
    if (product.inventoryMode == 'simple') {
      selectedOption = product.inventoryOptions.firstWhere(
        (item) => item.color == null && item.size == null,
        orElse: () => throw StateError('Inventory is not available for this product.'),
      );
    } else if (product.inventoryMode == 'variants' && option != null) {
      selectedOption = product.inventoryOptions.firstWhere(
        (item) => item.id == option.id,
        orElse: () => throw StateError('Select a valid product option.'),
      );
    } else {
      throw StateError('Select a valid product option.');
    }

    if (!selectedOption.isAvailable || !selectedOption.isInStock) {
      throw StateError('This product option is out of stock.');
    }

    final index = _items.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.inventoryOption.id == selectedOption.id,
    );
    if (index >= 0) {
      _items[index].quantity++;
    } else {
      _items.add(
        CartItemEntity(product: product, inventoryOption: selectedOption),
      );
    }
    notifyListeners();
  }

  void removeFromCart(String productId, {String? inventoryOptionId}) {
    _items.removeWhere(
      (item) =>
          item.product.id == productId &&
          (inventoryOptionId == null ||
              item.inventoryOption.id == inventoryOptionId),
    );
    notifyListeners();
  }

  void updateQuantity(
    String productId,
    int quantity, {
    String? inventoryOptionId,
  }) {
    final index = _items.indexWhere(
      (item) =>
          item.product.id == productId &&
          (inventoryOptionId == null ||
              item.inventoryOption.id == inventoryOptionId),
    );
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
    _pendingCheckoutRequestId = null;
    _pendingCheckoutPayload = null;
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

    final orderItems = _items.map((item) {
      return {
        'product_id': item.product.id,
        'variant_id': item.product.inventoryMode == 'variants'
            ? item.inventoryOption.id
            : null,
        'quantity': item.quantity,
      };
    }).toList();
    final requestPayload = jsonEncode(orderItems);
    // Un nouvel identifiant est créé seulement si le contenu du panier a changé.
    if (_pendingCheckoutPayload != requestPayload) {
      _pendingCheckoutRequestId = _newRequestId();
      _pendingCheckoutPayload = requestPayload;
    }

    await client.rpc(
      'checkout',
      params: {
        'p_request_id': _pendingCheckoutRequestId,
        'p_items': orderItems,
      },
    );
    clearCart();
  }

  String _newRequestId() {
    final bytes = List<int>.generate(16, (_) => Random.secure().nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }
}
