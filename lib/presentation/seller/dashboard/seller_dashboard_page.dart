import 'package:flutter/material.dart';
import '../analytics/seller_analytics_page.dart';
import '../orders/seller_orders_page.dart';
import '../products/seller_products_page.dart';
import '../profile/seller_profile_page.dart';

class SellerDashboardPage extends StatefulWidget {
  const SellerDashboardPage({super.key});

  @override
  State<SellerDashboardPage> createState() => _SellerDashboardPageState();
}

class _SellerDashboardPageState extends State<SellerDashboardPage> {
  // IndexedStack conserve l'état de chaque onglet lors de la navigation.
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const SellerAnalyticsPage(),
    const SellerOrdersPage(),
    const SellerProductsPage(),
    const SellerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withValues(alpha: 0.08),
              blurRadius: 10,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          selectedItemColor: colors.primary,
          unselectedItemColor: colors.onSurfaceVariant,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          backgroundColor: colors.surface,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.analytics_outlined),
              activeIcon: Icon(Icons.analytics),
              label: 'Analytics',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.receipt_long_outlined),
              activeIcon: Icon(Icons.receipt_long),
              label: 'Orders',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined),
              activeIcon: Icon(Icons.inventory_2),
              label: 'Products',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.storefront_outlined),
              activeIcon: Icon(Icons.storefront),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
