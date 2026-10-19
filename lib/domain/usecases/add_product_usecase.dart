import 'dart:io';

import '../entities/product_entity.dart';
import '../repositories/product_repository.dart';

class AddProductUseCase {
  final ProductRepository repository;

  AddProductUseCase(this.repository);

  Future<void> call(ProductEntity product, [File? imageFile]) async {
    return repository.addProduct(product, imageFile);
  }
}
