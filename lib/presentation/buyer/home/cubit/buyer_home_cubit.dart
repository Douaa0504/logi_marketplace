import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/repositories/product_repository.dart';
import 'buyer_home_state.dart';

class BuyerHomeCubit extends Cubit<BuyerHomeState> {
  final ProductRepository _productRepository;

  BuyerHomeCubit(this._productRepository) : super(BuyerHomeInitial());

  Future<void> loadHomeData({String category = 'All'}) async {
    emit(BuyerHomeLoading());
    try {
      final allProducts = await _productRepository.getProducts();
      final filteredProducts = category == 'All'
          ? allProducts
          : allProducts.where((p) => p.category == category).toList();
      
      emit(BuyerHomeLoaded(
        products: filteredProducts,
        selectedCategory: category,
      ));
    } catch (e) {
      emit(BuyerHomeError(e.toString()));
    }
  }

  void selectCategory(String category) {
    loadHomeData(category: category);
  }
}
