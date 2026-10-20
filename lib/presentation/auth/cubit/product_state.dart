import '../../../domain/entities/product_entity.dart';

abstract class ProductState {}

class ProductInitial extends ProductState {}

class ProductLoading extends ProductState {}

class ProductSuccess extends ProductState {}

class ProductLoaded extends ProductState {
  final List<ProductEntity> products;
  ProductLoaded({required this.products});
}

// الكلاس الأصلي الذي تنتظره باقي الواجهات القديمة
class ProductError extends ProductState {
  final String message;
  ProductError({required this.message});
}

// للرغبة في التوافق المزدوج
typedef ProductFailure = ProductError;
