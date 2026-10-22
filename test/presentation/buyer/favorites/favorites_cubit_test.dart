import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logi_marketplace/domain/entities/product_entity.dart';
import 'package:logi_marketplace/domain/repositories/favorites_repository.dart';
import 'package:logi_marketplace/domain/repositories/product_repository.dart';
import 'package:logi_marketplace/presentation/buyer/favorites/favorites_cubit.dart';

void main() {
  group('FavoritesCubit', () {
    late _FakeFavoritesRepository favoritesRepository;
    late _FakeProductRepository productRepository;
    late ProductEntity product;
    late FavoritesCubit cubit;

    setUp(() {
      product = ProductEntity(
        id: 'product-id',
        sellerId: 'seller-id',
        title: 'Saved product',
        price: 12,
        category: 'Home',
        createdAt: DateTime(2025, 1, 1),
      );
      favoritesRepository = _FakeFavoritesRepository();
      productRepository = _FakeProductRepository([product]);
      cubit = FavoritesCubit(favoritesRepository, productRepository);
    });

    tearDown(() async {
      await cubit.close();
    });

    test('loads persisted IDs and their products', () async {
      favoritesRepository.productIds.add(product.id);

      await cubit.loadFavorites();

      expect(cubit.state.productIds, contains(product.id));
      expect(cubit.state.products, [product]);
    });

    test('persists a toggle and reloads it from the repository', () async {
      await cubit.toggleFavorite(product);

      expect(favoritesRepository.productIds, contains(product.id));
      expect(cubit.state.productIds, contains(product.id));
      expect(cubit.state.products, [product]);

      await cubit.loadFavorites();

      expect(cubit.state.productIds, contains(product.id));
      expect(cubit.state.products, [product]);
    });

    test('loads before toggling an existing saved product', () async {
      favoritesRepository.productIds.add(product.id);

      await cubit.toggleFavorite(product);

      expect(favoritesRepository.productIds, isNot(contains(product.id)));
      expect(cubit.state.productIds, isNot(contains(product.id)));
      expect(cubit.state.products, isEmpty);
    });
  });
}

class _FakeFavoritesRepository implements FavoritesRepository {
  final Set<String> productIds = {};

  @override
  Future<Set<String>> getFavoriteProductIds() async => Set.of(productIds);

  @override
  Future<void> addFavorite(String productId) async {
    productIds.add(productId);
  }

  @override
  Future<void> removeFavorite(String productId) async {
    productIds.remove(productId);
  }
}

class _FakeProductRepository implements ProductRepository {
  final List<ProductEntity> products;

  _FakeProductRepository(this.products);

  @override
  Future<List<ProductEntity>> getProducts() async => products;

  @override
  Future<Map<String, dynamic>> getSellerProductInventory(
    String productId,
  ) async => {};

  @override
  Future<void> addProduct(ProductEntity product, [File? imageFile]) async {}

  @override
  Future<void> updateProduct(ProductEntity product, [File? imageFile]) async {}
}
