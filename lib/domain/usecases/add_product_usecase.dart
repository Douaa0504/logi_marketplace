import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<void> call(ProductEntity product) async {
    return await repository.addProduct(product);
  }
}