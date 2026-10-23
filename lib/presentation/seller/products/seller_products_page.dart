import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../domain/entities/product_entity.dart';
import '../../auth/cubit/product_cubit.dart';
import '../../auth/cubit/product_state.dart';
import '../../auth/pages/add_product_page.dart';

class SellerProductsPage extends StatefulWidget {
  const SellerProductsPage({super.key});

  @override
  State<SellerProductsPage> createState() => _SellerProductsPageState();
}

class _SellerProductsPageState extends State<SellerProductsPage> {
  final Set<String> _deletingProductIds = {};
  Map<String, int> _favoriteCounts = {};
  bool _isLoadingFavoriteCounts = true;
  String? _favoriteCountsError;

  @override
  void initState() {
    super.initState();
    _fetchProducts();
    _fetchFavoriteCounts();
  }

  void _fetchProducts() {
    context.read<ProductCubit>().loadProducts();
  }

  Future<void> _fetchFavoriteCounts() async {
    setState(() {
      _isLoadingFavoriteCounts = true;
      _favoriteCountsError = null;
    });
    try {
      final response = await context
          .read<ProductCubit>()
          .getSellerFavoriteCounts();
      final rawCounts = Map<String, dynamic>.from(
        response['products'] as Map? ?? const {},
      );
      if (!mounted) return;
      setState(() {
        _favoriteCounts = rawCounts.map(
          (productId, count) =>
              MapEntry(productId, (count as num).toInt()),
        );
        _isLoadingFavoriteCounts = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _favoriteCountsError = error.toString();
        _isLoadingFavoriteCounts = false;
      });
    }
  }

  Future<void> _editProduct(BuildContext context, ProductEntity product) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddProductPage(product: product)),
    );
    if (result == true && mounted) {
      _fetchProducts();
    }
  }

  Future<void> _deleteProduct(ProductEntity product) async {
    if (_deletingProductIds.contains(product.id)) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete product permanently?'),
        content: Text(
          '“${product.title}” will be removed from your shop and favorites. '
          'This cannot be undone. Historical orders will remain; products with '
          'pending or accepted reserved orders cannot be deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            child: const Text('Confirm Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _deletingProductIds.add(product.id));
    try {
      final cleanupWarning = await context
          .read<ProductCubit>()
          .deleteProduct(product.id);
      if (!mounted) return;
      setState(() => _deletingProductIds.remove(product.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            cleanupWarning ?? 'Product deleted successfully.',
          ),
        ),
      );
      _fetchProducts();
      _fetchFavoriteCounts();
    } catch (error) {
      if (!mounted) return;
      setState(() => _deletingProductIds.remove(product.id));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete product: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUserId = Supabase.instance.client.auth.currentUser?.id;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Products'),
        actions: [
          IconButton(
            tooltip: 'Refresh products and favorite counts',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _fetchProducts();
              _fetchFavoriteCounts();
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddProductPage()),
          );
          if (result == true) {
            _fetchProducts();
            _fetchFavoriteCounts();
          }
        },
        child: const Icon(Icons.add),
      ),
      body: BlocBuilder<ProductCubit, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProductError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Error: ${state.message}'),
                  const SizedBox(height: 12),
                  ElevatedButton(
                    onPressed: _fetchProducts,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state is ProductLoaded) {
            
            final sellerProducts = state.products
                .where((p) => p.sellerId == currentUserId)
                .toList();

            if (sellerProducts.isEmpty) {
              return const Center(
                child: Text('No products added yet. Click + to add one!'),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sellerProducts.length,
              itemBuilder: (context, index) {
                final product = sellerProducts[index];
                final deleting = _deletingProductIds.contains(product.id);
                final favoriteCount = _favoriteCounts[product.id];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Theme.of(context).colorScheme.surface,
                  child: ListTile(
                    leading: product.remoteImageUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              product.remoteImageUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              errorBuilder: (_, _, _) =>
                                  const Icon(Icons.image_not_supported),
                            ),
                          )
                        : const Icon(Icons.shopping_bag, size: 40),
                    title: Text(
                      product.title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${product.category} • \$${product.price.toStringAsFixed(2)}\n'
                      '${product.createdAt.toString().split(' ')[0]}\n'
                      '${_favoriteCountsError != null ? 'Favorites unavailable' : _isLoadingFavoriteCounts ? 'Loading favorites…' : '${favoriteCount ?? 0} favorites'}',
                    ),
                    isThreeLine: true,
                    trailing: deleting
                        ? const SizedBox.square(
                            dimension: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Wrap(
                            spacing: 0,
                            children: [
                              IconButton(
                                tooltip: 'Edit product',
                                icon: const Icon(Icons.edit_outlined),
                                onPressed: () => _editProduct(context, product),
                              ),
                              IconButton(
                                tooltip: 'Delete product',
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: Theme.of(context).colorScheme.error,
                                ),
                                onPressed: () => _deleteProduct(product),
                              ),
                            ],
                          ),
                  ),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
