import '../../../domain/entities/product_entity.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  ProductLoaded(this.products);
}

class ProductAddedSuccess extends ProductState {}

class ProductError extends ProductState {
  final String message;
  ProductError(this.message);
}
