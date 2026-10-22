import 'product_entity.dart';
import 'product_inventory_option_entity.dart';

class CartItemEntity {
  final ProductEntity product;
  final ProductInventoryOptionEntity inventoryOption;
  int quantity;

  CartItemEntity({
    required this.product,
    required this.inventoryOption,
    this.quantity = 1,
  });

  double get totalPrice => product.price * quantity;
}
