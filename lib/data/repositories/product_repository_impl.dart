import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/product_repository.dart';
import '../datasources/product_remote_datasource.dart';

class ProductRepositoryImpl implements ProductRepository {
  final ProductRemoteDataSource _remoteDataSource;

  ProductRepositoryImpl(this._remoteDataSource);

  @override
  Future<List<ProductEntity>> getProducts() async {
    try {
      return await _remoteDataSource.fetchProducts();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> addProduct(ProductEntity product) {
    // TODO: implement addProduct
    throw UnimplementedError();
  }
  
}