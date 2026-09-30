import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../../../domain/entities/product_entity.dart';

@immutable
abstract class BuyerHomeState extends Equatable {
  const BuyerHomeState();

  @override
  List<Object?> get props => [];
}

class BuyerHomeInitial extends BuyerHomeState {}

class BuyerHomeLoading extends BuyerHomeState {}

class BuyerHomeLoaded extends BuyerHomeState {
  final List<ProductEntity> products;
  final String selectedCategory;

  const BuyerHomeLoaded({
    required this.products,
    required this.selectedCategory,
  });

  @override
  List<Object?> get props => [products, selectedCategory];
}

class BuyerHomeError extends BuyerHomeState {
  final String message;
  const BuyerHomeError(this.message);

  @override
  List<Object?> get props => [message];
}
