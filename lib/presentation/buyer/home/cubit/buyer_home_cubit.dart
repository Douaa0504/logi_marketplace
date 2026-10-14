import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../../domain/repositories/product_repository.dart';
import 'buyer_home_state.dart';

class BuyerHomeCubit extends Cubit<BuyerHomeState> {
  final ProductRepository _productRepository;
  List<ProductEntity> _allProducts = [];
  bool _hasLoadedProducts = false;
  String _selectedCategory = 'All';
  String _searchQuery = '';

  BuyerHomeCubit(this._productRepository) : super(BuyerHomeInitial());

  Future<void> loadHomeData({String? category}) async {
    if (category != null) {
      _selectedCategory = category;
    }

    emit(BuyerHomeLoading());
    try {
      _allProducts = await _productRepository.getProducts();
      _hasLoadedProducts = true;
      _emitFilteredProducts();
    } catch (e) {
      emit(BuyerHomeError(e.toString()));
    }
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    if (_hasLoadedProducts) _emitFilteredProducts();
  }

  void searchProducts(String query) {
    _searchQuery = query;
    if (_hasLoadedProducts) _emitFilteredProducts();
  }

  void _emitFilteredProducts() {
    final normalizedQuery = _searchQuery.trim().toLowerCase();
    final filteredProducts = _allProducts.where((product) {
      final matchesCategory =
          _selectedCategory == 'All' || product.category == _selectedCategory;
      final matchesSearch =
          normalizedQuery.isEmpty ||
          product.title.toLowerCase().contains(normalizedQuery) ||
          (product.description?.toLowerCase().contains(normalizedQuery) ??
              false);
      return matchesCategory && matchesSearch;
    }).toList();

    emit(
      BuyerHomeLoaded(
        products: filteredProducts,
        selectedCategory: _selectedCategory,
        searchQuery: _searchQuery,
      ),
    );
  }
}
