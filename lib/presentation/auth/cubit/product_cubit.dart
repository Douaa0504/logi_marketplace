import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/entities/product_inventory_option_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/add_product_usecase.dart';
import '../../../domain/usecases/update_product_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;
  final AddProductUseCase addProductUseCase;
  final UpdateProductUseCase updateProductUseCase;

  ProductCubit({
    required this.productRepository,
    required this.addProductUseCase,
    required this.updateProductUseCase,
  }) : super(ProductInitial());

  Future<void> addProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required String sellerId,
    required String inventoryMode,
    required List<ProductInventoryOptionEntity> inventoryOptions,
    File? imageFile,
  }) async {
    emit(ProductLoading());
    try {
      final newProduct = ProductEntity(
        id: '',
        sellerId: sellerId,
        title: title,
        description: description,
        price: price,
        category: category,
        imageUrl: null,
        createdAt: DateTime.now(),
        inventoryMode: inventoryMode,
        inventoryOptions: inventoryOptions,
      );

      await addProductUseCase(newProduct, imageFile);
      emit(ProductSuccess());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> updateProduct({
    required ProductEntity product,
    required String title,
    required String description,
    required double price,
    required String category,
    required String inventoryMode,
    required List<ProductInventoryOptionEntity> inventoryOptions,
    File? imageFile,
  }) async {
    emit(ProductLoading());
    try {
      final updatedProduct = ProductEntity(
        id: product.id,
        sellerId: product.sellerId,
        title: title,
        description: description,
        price: price,
        category: category,
        imageUrl: product.imageUrl,
        createdAt: product.createdAt,
        inventoryMode: inventoryMode,
        inventoryOptions: inventoryOptions,
      );

      await updateProductUseCase(updatedProduct, imageFile);
      emit(ProductSuccess());
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await productRepository.getProducts();
      emit(ProductLoaded(products: products));
    } catch (e) {
      emit(ProductError(message: e.toString()));
    }
  }

  Future<Map<String, dynamic>> getSellerProductInventory(String productId) {
    return productRepository.getSellerProductInventory(productId);
  }

  Future<String?> deleteProduct(String productId) {
    return productRepository.deleteProduct(productId);
  }

  Future<Map<String, dynamic>> getSellerFavoriteCounts() {
    return productRepository.getSellerFavoriteCounts();
  }
}
