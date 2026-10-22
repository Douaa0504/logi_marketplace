import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../buyer/favorites/favorites_cubit.dart';
import '../../domain/entities/product_entity.dart';

class FavoriteButton extends StatelessWidget {
  final ProductEntity product;
  final Color? backgroundColor;

  const FavoriteButton({
    super.key,
    required this.product,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FavoritesCubit, FavoritesState>(
      builder: (context, state) {
        final isFavorite = state.productIds.contains(product.id);
        final isPending = state.pendingProductIds.contains(product.id);
        return IconButton(
          tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
          onPressed: isPending
              ? null
              : () async {
                  try {
                    await context.read<FavoritesCubit>().toggleFavorite(product);
                  } catch (error) {
                    debugPrint('Unable to update favorite: $error');
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Could not update favorites. Try again.'),
                      ),
                    );
                  }
                },
          style: IconButton.styleFrom(
            backgroundColor: backgroundColor,
            foregroundColor: isFavorite
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurface,
          ),
          icon: isPending
              ? const SizedBox.square(
                  dimension: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : Icon(isFavorite ? Icons.favorite : Icons.favorite_border),
        );
      },
    );
  }
}
