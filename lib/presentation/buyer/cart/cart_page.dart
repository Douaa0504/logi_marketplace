import 'package:flutter/material.dart';
import '../../auth/pages/cart_page.dart' as active_cart;

/// Conserve l'ancien point d'entrée tout en déléguant au panier actif.
class CartPage extends StatelessWidget {
  const CartPage({super.key});

  @override
  Widget build(BuildContext context) => const active_cart.CartPage();
}
