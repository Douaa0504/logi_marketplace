import 'package:flutter/material.dart';
import 'package:logi_marketplace/data/services/cart_service.dart';
import 'package:logi_marketplace/presentation/auth/pages/cart_page.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../../domain/entities/product_inventory_option_entity.dart';
import '../../../shared/primary_button.dart';
import '../../../shared/favorite_button.dart';

class ProductDetailsPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductInventoryOptionEntity? _selectedOption;

  ProductEntity get product => widget.product;

  bool get _canAddToCart {
    if (product.inventoryMode == 'simple') {
      return product.inventoryOptions.any(
        (option) =>
            option.color == null &&
            option.size == null &&
            option.isAvailable &&
            option.isInStock,
      );
    }
    return product.inventoryMode == 'variants' &&
        _selectedOption != null &&
        _selectedOption!.isAvailable &&
        _selectedOption!.isInStock;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: colors.surface,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildProductHeader(context),
                      const SizedBox(height: 24),
                      _buildInventorySelector(context),
                      const SizedBox(height: 24),
                      _buildSectionTitle(context, 'Description'),
                      const SizedBox(height: 12),
                      Text(
                        product.description ?? 'No description provided.',
                        style: TextStyle(
                          fontSize: 15,
                          color: colors.onSurfaceVariant,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 120), // Bottom bar spacing
                    ],
                  ),
                ),
              ),
            ],
          ),
          _buildStickyBottomBar(context),
        ],
      ),
    );
  }

  Widget _buildInventorySelector(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    if (product.inventoryMode == 'unconfigured') {
      return Text(
        'This product is not available for purchase yet.',
        style: TextStyle(color: colors.error),
      );
    }
    if (product.inventoryMode == 'simple') {
      return Text(
        _canAddToCart ? 'In stock' : 'Out of stock',
        style: TextStyle(color: colors.onSurfaceVariant),
      );
    }

    if (product.inventoryOptions.isEmpty) {
      return Text(
        'No variants are currently available.',
        style: TextStyle(color: colors.onSurfaceVariant),
      );
    }

    return DropdownButtonFormField<String>(
      initialValue: _selectedOption?.id,
      decoration: const InputDecoration(
        labelText: 'Choose a color or size',
        border: OutlineInputBorder(),
      ),
      items: product.inventoryOptions.map((option) {
        final available = option.isAvailable && option.isInStock;
        final label = !option.isAvailable
            ? '${option.label} (Unavailable)'
            : option.isInStock
            ? option.label
            : '${option.label} (Out of stock)';
        return DropdownMenuItem<String>(
          value: option.id,
          enabled: available,
          child: Text(label),
        );
      }).toList(),
      onChanged: (id) {
        final matchingOptions = product.inventoryOptions.where(
          (option) => option.id == id,
        );
        setState(() {
          _selectedOption = matchingOptions.isEmpty
              ? null
              : matchingOptions.first;
        });
      },
    );
  }

  Widget _buildAppBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SliverAppBar(
      expandedHeight: 400,
      pinned: true,
      elevation: 0,
      backgroundColor: colors.surface,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: CircleAvatar(
          backgroundColor: colors.surface,
          child: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: colors.onSurface,
            size: 18,
          ),
        ),
      ),
      actions: [
        FavoriteButton(
          product: product,
          backgroundColor: colors.surface.withValues(alpha: 0.9),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Hero(
          tag: 'product_${product.id}',
          child: ColoredBox(
            color: colors.surfaceContainerHighest,
            child: product.remoteImageUrl != null
                ? Image.network(
                    product.remoteImageUrl!,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    errorBuilder: (context, error, stackTrace) {
                      return Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 64,
                          color: colors.onSurfaceVariant,
                        ),
                      );
                    },
                  )
                : Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      size: 64,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: colors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(100),
          ),
          child: Text(
            product.category.toUpperCase(),
            style: TextStyle(
              color: colors.primary,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          product.title,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: colors.onSurface,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Reviews are not available yet.',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  Widget _buildStickyBottomBar(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colors.surface,
          boxShadow: [
            BoxShadow(
                color: colors.shadow.withValues(alpha: 0.05),
              blurRadius: 20,
              offset: const Offset(0, -10),
            ),
          ],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SafeArea(
          child: Row(
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Price',
                    style: TextStyle(
                      color: colors.onSurfaceVariant,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: colors.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Expanded(
                child: PrimaryButton(
                  label:
                      product.inventoryMode == 'variants' &&
                          _selectedOption == null
                      ? 'Select an option'
                      : 'Add to Cart',
                  onPressed: _canAddToCart ? () => _addToCart(context) : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _addToCart(BuildContext context) {
    try {
      CartService().addToCart(product, option: _selectedOption);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${product.title} added to cart.'),
          action: SnackBarAction(
            label: 'View Cart',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CartPage()),
              );
            },
          ),
        ),
      );
    } catch (error) {
      debugPrint('Unable to add product to cart: $error');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not add this product to your cart.'),
        ),
      );
    }
  }
}
