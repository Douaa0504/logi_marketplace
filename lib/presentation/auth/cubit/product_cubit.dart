import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/entities/product_entity.dart';
import '../../../domain/repositories/product_repository.dart';
import '../../../domain/usecases/add_product_usecase.dart';
import 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final AddProductUseCase addProductUseCase;
  final ProductRepository productRepository;

  ProductCubit({
    required this.addProductUseCase,
    required this.productRepository,
  }) : super(ProductInitial());

  Future<void> addProduct(ProductEntity product) async {
    emit(ProductLoading());
    try {
      await addProductUseCase(product);
      emit(ProductAddedSuccess());
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> loadProducts() async {
    emit(ProductLoading());
    try {
      final products = await productRepository.getProducts();
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }
}
