import 'dart:io';

import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class UpdateProductUseCase {
  final ProductRepository repository;

  UpdateProductUseCase(this.repository);

  Future<void> call(ProductEntity product, [File? imageFile]) async {
    return repository.updateProduct(product, imageFile);
  }
}
