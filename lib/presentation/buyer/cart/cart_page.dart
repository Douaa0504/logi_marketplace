import 'package:flutter/material.dart';
import '../../shared/primary_button.dart';

class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  State<CartPage> createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  // Dummy data for demonstration
  final List<Map<String, dynamic>> _cartItems = [
    {
      'id': '1',
      'title': 'Premium Wireless Headphones',
      'price': 199.99,
      'quantity': 1,
      'image': 'https://images.unsplash.com/photo-1505740420928-5e560c06d30e?q=80&w=500',
      'category': 'Electronics'
    },
    {
      'id': '2',
      'title': 'Minimalist Leather Watch',
      'price': 125.50,
      'quantity': 2,
      'image': 'https://images.unsplash.com/photo-1523275335684-37898b6baf30?q=80&w=500',
      'category': 'Fashion'
    },
  ];

  double get _subtotal => _cartItems.fold(0, (sum, item) => sum + (item['price'] * item['quantity']));
  double get _shipping => 15.00;
  double get _discount => 20.00;
  double get _total => _subtotal + _shipping - _discount;

  void _updateQuantity(int index, int delta) {
    setState(() {
      final newQty = _cartItems[index]['quantity'] + delta;
      if (newQty > 0) {
        _cartItems[index]['quantity'] = newQty;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Cart',
          style: TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: _cartItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _cartItems.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildCartItem(index);
                    },
                  ),
          ),
          _buildCheckoutSection(),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('Your cart is empty', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Go Shopping', style: TextStyle(color: Color(0xFF2563EB))),
          ),
        ],
      ),
    );
  }

  Widget _buildCartItem(int index) {
    final item = _cartItems[index];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 90,
            width: 90,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              image: DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'],
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF0F172A)),
                ),
                Text(
                  item['category'],
                  style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '\$${item['price'].toStringAsFixed(2)}',
                      style: const TextStyle(color: Color(0xFF2563EB), fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    _buildQuantityControl(index),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantityControl(int index) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _qtyButton(Icons.remove, () => _updateQuantity(index, -1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              '${_cartItems[index]['quantity']}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
          _qtyButton(Icons.add, () => _updateQuantity(index, 1)),
        ],
      ),
    );
  }

  Widget _qtyButton(IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Icon(icon, size: 16, color: const Color(0xFF0F172A)),
      ),
    );
  }

  Widget _buildCheckoutSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -10)),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _summaryRow('Subtotal', _subtotal),
            const SizedBox(height: 12),
            _summaryRow('Shipping', _shipping),
            const SizedBox(height: 12),
            _summaryRow('Discount', _discount, isNegative: true),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Divider(color: Color(0xFFF1F5F9), thickness: 2),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                Text(
                  '\$${_total.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2563EB)),
                ),
              ],
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Proceed to Checkout',
              onPressed: () {
                // Checkout logic
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(String label, double value, {bool isNegative = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF64748B), fontSize: 14, fontWeight: FontWeight.w500)),
        Text(
          '${isNegative ? "- " : ""}\$${value.toStringAsFixed(2)}',
          style: TextStyle(
            color: isNegative ? Colors.redAccent : const Color(0xFF0F172A),
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
