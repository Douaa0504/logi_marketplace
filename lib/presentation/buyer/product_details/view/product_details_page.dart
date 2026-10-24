import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:logi_marketplace/data/services/cart_service.dart';
import 'package:logi_marketplace/domain/entities/review_entity.dart';
import 'package:logi_marketplace/domain/repositories/review_repository.dart';
import 'package:logi_marketplace/presentation/auth/pages/cart_page.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../../domain/entities/product_inventory_option_entity.dart';
import '../../../shared/primary_button.dart';
import '../../../shared/favorite_button.dart';
import '../../../shared/public_shop_page.dart';

/// Présente un produit, ses options d'inventaire, ses avis et l'action d'achat.
class ProductDetailsPage extends StatefulWidget {
  final ProductEntity product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  State<ProductDetailsPage> createState() => _ProductDetailsPageState();
}

class _ProductDetailsPageState extends State<ProductDetailsPage> {
  ProductInventoryOptionEntity? _selectedOption;
  final TextEditingController _reviewController = TextEditingController();
  final List<ReviewEntity> _reviews = [];
  int _selectedRating = 5;
  bool _isLoadingReviews = false;
  bool _isSubmittingReview = false;
  bool _isDeletingReview = false;
  String? _reviewLoadError;

  ProductEntity get product => widget.product;
  double get _averageRating => _reviews.isEmpty
      ? 0
      : _reviews.fold<int>(0, (sum, review) => sum + review.rating) /
            _reviews.length;

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
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    // Le repository renvoie tous les avis visibles pour ce produit, pas seulement le nôtre.
    final repo = context.read<ReviewRepository>();
    setState(() => _isLoadingReviews = true);
    try {
      final reviews = await repo.getProductReviews(product.id);
      if (!mounted) return;
      setState(() {
        _reviews
          ..clear()
          ..addAll(reviews);
        _reviewLoadError = null;
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _reviewLoadError = error.toString();
        });
      }
    } finally {
      if (mounted) setState(() => _isLoadingReviews = false);
    }
  }

  Future<void> _submitReview() async {
    final text = _reviewController.text.trim();
    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Write a review before submitting.')),
      );
      return;
    }
    if (text.length > 2000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Reviews must be 2,000 characters or fewer.')),
      );
      return;
    }

    // La contrainte d'un avis par acheteur et produit est aussi appliquée par la base.
    if (_reviews.any((review) => review.isMine)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You have already reviewed this product.')),
      );
      return;
    }

    final repo = context.read<ReviewRepository>();
    setState(() => _isSubmittingReview = true);
    try {
      await repo.submitReview(
        productId: product.id,
        rating: _selectedRating,
        reviewText: text,
      );
      _reviewController.clear();
      await _loadReviews();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Review submitted.')),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) setState(() => _isSubmittingReview = false);
    }
  }

  Future<void> _deleteReview(ReviewEntity review) async {
    // L'action n'est proposée que pour son propre avis ; la RLS vérifie aussi le propriétaire.
    if (!review.isMine || _isDeletingReview) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete your review?'),
        content: const Text('This review will be permanently removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _isDeletingReview = true);
    try {
      await context.read<ReviewRepository>().deleteReview(review.id);
      if (!mounted) return;
      // Recharge la liste pour recalculer la moyenne et le nombre d'avis.
      setState(() {
        _reviews.removeWhere((item) => item.id == review.id);
      });
      await _loadReviews();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _reviewLoadError == null
                ? 'Review deleted.'
                : 'Review deleted, but the reviews could not be refreshed.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete review: $error')),
      );
    } finally {
      if (mounted) setState(() => _isDeletingReview = false);
    }
  }

  @override
  void dispose() {
    _reviewController.dispose();
    super.dispose();
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
                      const SizedBox(height: 24),
                      _buildReviewsSection(context),
                      const SizedBox(height: 120),
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
          _reviews.isEmpty
              ? 'No reviews yet.'
              : '${_averageRating.toStringAsFixed(1)}/5 • '
                    '${_reviews.length} review${_reviews.length == 1 ? '' : 's'}',
          style: TextStyle(color: colors.onSurfaceVariant, fontSize: 13),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PublicShopPage(
                sellerId: product.sellerId,
                onProductTap: (shopProduct) => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        ProductDetailsPage(product: shopProduct),
                  ),
                ),
              ),
            ),
          ),
          icon: const Icon(Icons.storefront_outlined),
          label: const Text('Visit Shop'),
        ),
      ],
    );
  }

  Widget _buildReviewsSection(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(context, 'Customer Reviews'),
        const SizedBox(height: 12),
        if (_isLoadingReviews)
          const Center(child: CircularProgressIndicator())
        else if (_reviewLoadError != null)
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Reviews could not be loaded.',
                style: TextStyle(color: colors.error),
              ),
              TextButton.icon(
                onPressed: _loadReviews,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          )
        else if (_reviews.isEmpty)
          const Text('No reviews yet. Be the first to leave feedback.')
        else ...[
          ..._reviews.map(
            (review) => Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        review.buyerDisplayName ?? 'Buyer',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      Text(
                        '${review.rating}/5',
                        style: TextStyle(color: colors.primary),
                      ),
                      if (review.isMine)
                        IconButton(
                          tooltip: 'Delete your review',
                          onPressed: _isDeletingReview
                              ? null
                              : () => _deleteReview(review),
                          icon: const Icon(Icons.delete_outline),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(review.reviewText),
                  const SizedBox(height: 6),
                  Text(
                    review.createdAt.toLocal().toString().split('.').first,
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 18),
        if (_reviews.any((review) => review.isMine))
          Text(
            'You have already reviewed this product.',
            style: TextStyle(color: colors.onSurfaceVariant),
          )
        else ...[
          Text(
            'Write a review',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: colors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              final value = index + 1;
              return IconButton(
                onPressed: () => setState(() => _selectedRating = value),
                icon: Icon(
                  value <= _selectedRating ? Icons.star : Icons.star_border,
                  color: colors.primary,
                ),
              );
            }),
          ),
          TextFormField(
            controller: _reviewController,
            maxLines: 4,
            maxLength: 2000,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Share your feedback about this product',
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isSubmittingReview ? null : _submitReview,
              child: _isSubmittingReview
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Submit Review'),
            ),
          ),
        ],
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
