import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/favorites_repository.dart';
import '../../../domain/repositories/product_repository.dart';

class FavoritesState {
  final Set<String> productIds;
  final List<ProductEntity> products;
  final Set<String> pendingProductIds;
  final bool isLoading;
  final bool hasLoaded;
  final String? error;

  const FavoritesState({
    this.productIds = const {},
    this.products = const [],
    this.pendingProductIds = const {},
    this.isLoading = false,
    this.hasLoaded = false,
    this.error,
  });

  FavoritesState copyWith({
    Set<String>? productIds,
    List<ProductEntity>? products,
    Set<String>? pendingProductIds,
    bool? isLoading,
    bool? hasLoaded,
    String? error,
    bool clearError = false,
  }) {
    return FavoritesState(
      productIds: productIds ?? this.productIds,
      products: products ?? this.products,
      pendingProductIds: pendingProductIds ?? this.pendingProductIds,
      isLoading: isLoading ?? this.isLoading,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      error: clearError ? null : error ?? this.error,
    );
  }
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _favoritesRepository;
  final ProductRepository _productRepository;

  FavoritesCubit(this._favoritesRepository, this._productRepository)
    : super(const FavoritesState());

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      final productIds = await _favoritesRepository.getFavoriteProductIds();
      final allProducts = await _productRepository.getProducts();
      final products = allProducts
          .where((product) => productIds.contains(product.id))
          .toList();
      emit(
        state.copyWith(
          productIds: Set.unmodifiable(productIds),
          products: List.unmodifiable(products),
          isLoading: false,
          hasLoaded: true,
          clearError: true,
        ),
      );
    } catch (error) {
      emit(state.copyWith(isLoading: false, error: error.toString()));
    }
  }

  Future<void> toggleFavorite(ProductEntity product) async {
    final productId = product.id;
    if (!state.hasLoaded) {
      await loadFavorites();
      if (!state.hasLoaded) {
        throw StateError(state.error ?? 'Could not load saved favorites.');
      }
    }
    if (state.pendingProductIds.contains(productId)) return;

    final pending = Set<String>.from(state.pendingProductIds)..add(productId);
    emit(state.copyWith(pendingProductIds: Set.unmodifiable(pending)));
    try {
      final productIds = Set<String>.from(state.productIds);
      if (productIds.remove(productId)) {
        await _favoritesRepository.removeFavorite(productId);
      } else {
        await _favoritesRepository.addFavorite(productId);
        productIds.add(productId);
      }

      final products = state.products
          .where((savedProduct) => savedProduct.id != productId)
          .toList();
      if (productIds.contains(productId)) products.add(product);

      emit(
        state.copyWith(
          productIds: Set.unmodifiable(productIds),
          products: List.unmodifiable(products),
          pendingProductIds: Set.unmodifiable(
            Set<String>.from(state.pendingProductIds)..remove(productId),
          ),
          clearError: true,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          pendingProductIds: Set.unmodifiable(
            Set<String>.from(state.pendingProductIds)..remove(productId),
          ),
          error: error.toString(),
        ),
      );
      rethrow;
    }
  }
}
