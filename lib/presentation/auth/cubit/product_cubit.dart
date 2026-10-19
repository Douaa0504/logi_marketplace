import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/add_product_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository productRepository;
  final AddProductUseCase addProductUseCase;

  ProductCubit({
    required this.productRepository,
    required this.addProductUseCase,
  }) : super(ProductInitial());

  Future<void> addProduct({
    required String title,
    required String description,
    required double price,
    required String category,
    required String sellerId,
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
      );

      await addProductUseCase(newProduct, imageFile);
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
}
