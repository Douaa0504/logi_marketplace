import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/entities/shop_profile_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../../domain/repositories/profile_repository.dart';
import 'product_card.dart';

class PublicShopPage extends StatefulWidget {
  final String sellerId;
  final ValueChanged<ProductEntity> onProductTap;

  const PublicShopPage({
    super.key,
    required this.sellerId,
    required this.onProductTap,
  });

  @override
  State<PublicShopPage> createState() => _PublicShopPageState();
}

class _PublicShopPageState extends State<PublicShopPage> {
  ShopProfileEntity? _profile;
  List<ProductEntity> _products = const [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadShop();
  }

  Future<void> _loadShop() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final profile = await context
          .read<ProfileRepository>()
          .getSellerProfile(widget.sellerId);
      // ignore: use_build_context_synchronously
      final products = await context
          .read<ProductRepository>()
          .getProductsBySeller(widget.sellerId);
      if (!mounted) return;
      setState(() {
        _profile = profile;
        _products = products;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _error = error.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Shop')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.store_outlined, size: 44),
                    const SizedBox(height: 12),
                    const Text('This shop could not be loaded.'),
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: colors.onSurfaceVariant),
                    ),
                    const SizedBox(height: 12),
                    FilledButton.icon(
                      onPressed: _loadShop,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Try again'),
                    ),
                  ],
                ),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadShop,
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildShopHeader(context, _profile!),
                  const SizedBox(height: 28),
                  Text(
                    'Products',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (_products.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 36),
                      child: Column(
                        children: [
                          Icon(
                            Icons.inventory_2_outlined,
                            size: 42,
                            color: colors.onSurfaceVariant,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'No products listed yet.',
                            style: TextStyle(color: colors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final crossAxisCount = constraints.maxWidth >= 760
                            ? 4
                            : constraints.maxWidth >= 520
                            ? 3
                            : 2;
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: _products.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: crossAxisCount,
                                mainAxisSpacing: 14,
                                crossAxisSpacing: 14,
                                childAspectRatio: 0.72,
                              ),
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              product: product,
                              onTap: () => widget.onProductTap(product),
                            );
                          },
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildShopHeader(BuildContext context, ShopProfileEntity profile) {
    final colors = Theme.of(context).colorScheme;
    final logoUrl = profile.publicShopLogoUrl;

    return Card(
      elevation: 0,
      color: colors.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: colors.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CircleAvatar(
              radius: 48,
              backgroundColor: colors.primaryContainer,
              child: logoUrl == null
                  ? Icon(
                      Icons.storefront_outlined,
                      size: 42,
                      color: colors.onPrimaryContainer,
                    )
                  : ClipOval(
                      child: Image.network(
                        logoUrl,
                        width: 96,
                        height: 96,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => Icon(
                          Icons.storefront_outlined,
                          size: 42,
                          color: colors.onPrimaryContainer,
                        ),
                      ),
                    ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.publicShopName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              profile.publicShopDescription,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colors.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
