import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:logi_marketplace/core/theme/theme_cubit.dart';
import 'package:logi_marketplace/data/services/cart_service.dart';
import 'package:logi_marketplace/domain/entities/product_entity.dart';
import 'package:logi_marketplace/domain/entities/product_inventory_option_entity.dart';
import 'package:logi_marketplace/domain/repositories/favorites_repository.dart';
import 'package:logi_marketplace/domain/repositories/product_repository.dart';
import 'package:logi_marketplace/domain/repositories/review_repository.dart';
import 'package:logi_marketplace/domain/entities/review_entity.dart';
import 'package:logi_marketplace/presentation/auth/pages/cart_page.dart';
import 'package:logi_marketplace/presentation/buyer/favorites/favorites_cubit.dart';
import 'package:logi_marketplace/presentation/buyer/navigation/buyer_navigation_page.dart';

void main() {
  late ProductEntity product;
  late _FakeProductRepository productRepository;
  late _FakeFavoritesRepository favoritesRepository;
  late FavoritesCubit favoritesCubit;
  late ThemeCubit themeCubit;

  setUp(() {
    product = ProductEntity(
      id: 'product-id',
      sellerId: 'seller-id',
      title: 'Saved Product',
      price: 10,
      category: 'Home',
      createdAt: DateTime(2025, 1, 1),
      inventoryMode: 'simple',
      inventoryOptions: const [
        ProductInventoryOptionEntity(
          id: 'simple-option',
          isAvailable: true,
          isInStock: true,
          stockQuantity: 3,
        ),
      ],
    );
    productRepository = _FakeProductRepository(product);
    favoritesRepository = _FakeFavoritesRepository();
    favoritesCubit = FavoritesCubit(favoritesRepository, productRepository);
    themeCubit = ThemeCubit(
      initialThemeMode: ThemeMode.light,
      saveThemeMode: (_) async {},
    );
    CartService().clearCart();
  });

  tearDown(() async {
    CartService().clearCart();
    await favoritesCubit.close();
    await themeCubit.close();
  });

  testWidgets(
    'tabs preserve cart and favorite state and settings toggle theme',
    (tester) async {
      // Le passage entre onglets ne doit pas réinitialiser les états partagés.
      favoritesRepository.productIds.add(product.id);
      CartService().addToCart(product);

      await tester.pumpWidget(
        _buildApp(productRepository, favoritesCubit, themeCubit),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);

      await tester.tap(find.text('My Cart').last);
      await tester.pumpAndSettle();
      expect(find.text('Saved Product'), findsOneWidget);

      await tester.tap(find.text('Favorites').last);
      await tester.pumpAndSettle();
      expect(find.text('Saved Product'), findsOneWidget);
      expect(favoritesCubit.state.productIds, contains(product.id));

      await tester.tap(find.text('Settings').last);
      await tester.pumpAndSettle();
      expect(find.byType(SwitchListTile), findsOneWidget);
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(themeCubit.state, ThemeMode.dark);

      await tester.tap(find.text('My Cart').last);
      await tester.pumpAndSettle();
      expect(find.text('Saved Product'), findsOneWidget);
      expect(find.byType(NavigationBar), findsOneWidget);
      final cartPage = find.byType(CartPage);
      expect(Theme.of(tester.element(cartPage)).brightness, Brightness.dark);
      final cartScaffold = find.descendant(
        of: cartPage,
        matching: find.byType(Scaffold),
      );
      expect(
        tester.widget<Scaffold>(cartScaffold).backgroundColor,
        isNot(Colors.white),
      );
    },
  );

  testWidgets(
    'product details returns to Home without duplicating navigation',
    (tester) async {
      await tester.pumpWidget(
        _buildApp(productRepository, favoritesCubit, themeCubit),
      );
      await tester.pumpAndSettle();

      final productTitle = find.text('Saved Product').first;
      await tester.ensureVisible(productTitle);
      await tester.pumpAndSettle();
      await tester.tap(productTitle);
      await tester.pumpAndSettle();
      expect(find.text('Description'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
      await tester.pumpAndSettle();
      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.text('Popular Products'), findsOneWidget);
    },
  );
}

Widget _buildApp(
  ProductRepository productRepository,
  FavoritesCubit favoritesCubit,
  ThemeCubit themeCubit,
) {
  return RepositoryProvider<ProductRepository>.value(
    value: productRepository,
    child: RepositoryProvider<ReviewRepository>.value(
      value: _FakeReviewRepository(),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<FavoritesCubit>.value(value: favoritesCubit),
          BlocProvider<ThemeCubit>.value(value: themeCubit),
        ],
        child: BlocBuilder<ThemeCubit, ThemeMode>(
          builder: (context, themeMode) => MaterialApp(
            themeMode: themeMode,
            theme: ThemeData.light(),
            darkTheme: ThemeData.dark(),
            home: const BuyerNavigationPage(),
          ),
        ),
      ),
    ),
  );
}

class _FakeProductRepository implements ProductRepository {
  final ProductEntity product;

  _FakeProductRepository(this.product);

  @override
  Future<List<ProductEntity>> getProducts() async => [product];

  @override
  Future<List<ProductEntity>> getProductsBySeller(String sellerId) async =>
      [product].where((item) => item.sellerId == sellerId).toList();

  @override
  Future<Map<String, dynamic>> getSellerProductInventory(
    String productId,
  ) async => {};

  @override
  Future<String?> deleteProduct(String productId) async => null;

  @override
  Future<Map<String, dynamic>> getSellerFavoriteCounts() async => {};

  @override
  Future<void> addProduct(ProductEntity product, [File? imageFile]) async {}

  @override
  Future<void> updateProduct(ProductEntity product, [File? imageFile]) async {}
}

class _FakeReviewRepository implements ReviewRepository {
  @override
  Future<List<ReviewEntity>> getProductReviews(String productId) async => [];

  @override
  Future<ReviewEntity> submitReview({
    required String productId,
    required int rating,
    required String reviewText,
  }) async => throw UnimplementedError();

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  }) async {}

  @override
  Future<void> deleteReview(String reviewId) async {}
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
