import 'package:flutter/material.dart';
import '../../auth/pages/cart_page.dart';
import '../../shared/settings_page.dart';
import '../favorites/favorites_page.dart';
import '../home/view/buyer_home_page.dart';

class BuyerNavigationPage extends StatefulWidget {
  const BuyerNavigationPage({super.key});

  @override
  State<BuyerNavigationPage> createState() => _BuyerNavigationPageState();
}

class _BuyerNavigationPageState extends State<BuyerNavigationPage> {
  int _selectedIndex = 0;

  late final List<Widget> _pages = [
    const BuyerHomePage(),
    const CartPage(popOnCheckout: false),
    const FavoritesPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _selectedIndex != 0) {
          setState(() => _selectedIndex = 0);
        }
      },
      child: Scaffold(
        body: IndexedStack(index: _selectedIndex, children: _pages),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (index) =>
              setState(() => _selectedIndex = index),
          backgroundColor: colors.surface,
          indicatorColor: colors.secondaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Home',
            ),
            NavigationDestination(
              icon: Icon(Icons.shopping_cart_outlined),
              selectedIcon: Icon(Icons.shopping_cart),
              label: 'My Cart',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_border),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
