import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:logi_marketplace/domain/entities/product_entity.dart';
import 'package:logi_marketplace/domain/repositories/product_repository.dart';
import 'package:logi_marketplace/domain/usecases/add_product_usecase.dart';
import 'package:logi_marketplace/domain/usecases/update_product_usecase.dart';
import 'package:logi_marketplace/presentation/auth/cubit/product_cubit.dart';
import 'package:logi_marketplace/presentation/auth/cubit/product_state.dart';

void main() {
  group('ProductCubit', () {
    test(
      'updates editable fields and preserves existing product identity',
      () async {
        final repository = _FakeProductRepository();
        final cubit = ProductCubit(
          productRepository: repository,
          addProductUseCase: AddProductUseCase(repository),
          updateProductUseCase: UpdateProductUseCase(repository),
        );
        final createdAt = DateTime(2025, 1, 2);
        final product = ProductEntity(
          id: 'product-id',
          sellerId: 'seller-id',
          title: 'Original title',
          description: 'Original description',
          price: 4.5,
          imageUrl: 'https://example.com/image.jpg',
          category: 'Electronics',
          createdAt: createdAt,
        );

        await cubit.updateProduct(
          product: product,
          title: 'Updated title',
          description: 'Updated description',
          price: 9.5,
          category: 'Home',
          inventoryMode: 'simple',
          inventoryOptions: const [],
        );

        expect(cubit.state, isA<ProductSuccess>());
        expect(repository.updatedProduct?.id, product.id);
        expect(repository.updatedProduct?.sellerId, product.sellerId);
        expect(repository.updatedProduct?.createdAt, createdAt);
        expect(repository.updatedProduct?.imageUrl, product.imageUrl);
        expect(repository.updatedProduct?.title, 'Updated title');
        expect(repository.updatedProduct?.description, 'Updated description');
        expect(repository.updatedProduct?.price, 9.5);
        expect(repository.updatedProduct?.category, 'Home');

        await cubit.close();
      },
    );

    test('deleteProduct delegates the requested product ID', () async {
      final repository = _FakeProductRepository();
      final cubit = ProductCubit(
        productRepository: repository,
        addProductUseCase: AddProductUseCase(repository),
        updateProductUseCase: UpdateProductUseCase(repository),
      );

      final warning = await cubit.deleteProduct('product-id');

      expect(repository.deletedProductId, 'product-id');
      expect(warning, 'image cleanup warning');
      await cubit.close();
    });
  });
}

class _FakeProductRepository implements ProductRepository {
  ProductEntity? updatedProduct;
  String? deletedProductId;

  @override
  Future<List<ProductEntity>> getProducts() async => [];

  @override
  Future<Map<String, dynamic>> getSellerProductInventory(
    String productId,
  ) async => {};

  @override
  Future<String?> deleteProduct(String productId) async {
    deletedProductId = productId;
    return 'image cleanup warning';
  }

  @override
  Future<Map<String, dynamic>> getSellerFavoriteCounts() async => {};

  @override
  Future<void> addProduct(ProductEntity product, [File? imageFile]) async {}

  @override
  Future<void> updateProduct(ProductEntity product, [File? imageFile]) async {
    updatedProduct = product;
  }
}
