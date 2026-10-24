import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/product_inventory_option_entity.dart';
import '../models/product_model.dart';

/// Storage bucket for product photos. Confirm this exact name exists in
/// the Supabase project (Storage), is public, and allows authenticated uploads.
const String productImagesStorageBucket = 'products';

abstract class ProductRemoteDataSource {
  Future<List<ProductModel>> getProducts();
  Future<List<ProductModel>> fetchProducts();
  Future<List<ProductModel>> getProductsBySeller(String sellerId);
  Future<ProductModel> addProduct(ProductModel product, File? imageFile);
  Future<ProductModel> updateProduct(ProductModel product, File? imageFile);
  Future<String?> deleteProduct(String productId);
  Future<Map<String, dynamic>> getSellerProductInventory(String productId);
  Future<Map<String, dynamic>> getSellerFavoriteCounts();
}

/// Gère les lectures et écritures Supabase liées aux produits et à leur inventaire.
class ProductRemoteDataSourceImpl implements ProductRemoteDataSource {
  final SupabaseClient supabaseClient;

  ProductRemoteDataSourceImpl({required this.supabaseClient});

  String _sanitizeStorageFileName(String rawValue) {
    final sanitized = rawValue
        .trim()
        .replaceAll(RegExp(r'[\\/:*?"<>|]+'), '_')
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'_+'), '_')
        .replaceAll(RegExp(r'^[._]+|[._]+$'), '');

    return sanitized.isEmpty ? 'product' : sanitized;
  }

  String? _remoteImageUrlOrNull(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final uri = Uri.tryParse(value.trim());
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return value.trim();
  }

  Future<String> _uploadProductImage(File imageFile, String title) async {
    final safeTitle = _sanitizeStorageFileName(title);
    final fileName = '${DateTime.now().millisecondsSinceEpoch}_$safeTitle.jpg';
    final path = 'products/$fileName';

    await supabaseClient.storage
        .from(productImagesStorageBucket)
        .upload(
          path,
          imageFile,
          fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
        );
    return supabaseClient.storage
        .from(productImagesStorageBucket)
        .getPublicUrl(path);
  }

  @override
  Future<List<ProductModel>> getProducts() async {
    final response = await supabaseClient
        .from('products')
        .select()
        .order('created_at', ascending: false);

    final products = (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
    return _loadPublicInventoryOptions(products);
  }

  @override
  Future<List<ProductModel>> fetchProducts() async {
    return getProducts();
  }

  @override
  Future<List<ProductModel>> getProductsBySeller(String sellerId) async {
    final response = await supabaseClient
        .from('products')
        .select()
        .eq('seller_id', sellerId)
        .order('created_at', ascending: false);

    final products = (response as List)
        .map((json) => ProductModel.fromJson(json))
        .toList();
    return _loadPublicInventoryOptions(products);
  }

  @override
  Future<ProductModel> addProduct(ProductModel product, File? imageFile) async {
    final imageUrl = imageFile != null
        ? await _uploadProductImage(imageFile, product.title)
        : _remoteImageUrlOrNull(product.imageUrl);

    final productData = Map<String, dynamic>.from(product.toJson());
    final id = productData['id'];
    if (id == null || id.toString().trim().isEmpty) {
      productData.remove('id');
    }
    productData['image_url'] = imageUrl;

    final response = await supabaseClient
        .from('products')
        .insert(productData)
        .select()
        .single();

    final createdProduct = ProductModel.fromJson(response);
    await _saveSellerInventory(createdProduct.id, product);
    return createdProduct.withInventoryOptions(
      product.inventoryOptions,
      inventoryMode: product.inventoryMode,
    );
  }

  @override
  Future<ProductModel> updateProduct(
    ProductModel product,
    File? imageFile,
  ) async {
    final imageUrl = imageFile != null
        ? await _uploadProductImage(imageFile, product.title)
        : product.imageUrl;
    final productData = Map<String, dynamic>.from(product.toJson())
      ..remove('id')
      ..remove('seller_id')
      ..remove('created_at')
      ..['image_url'] = imageUrl;

    final response = await supabaseClient
        .from('products')
        .update(productData)
        .eq('id', product.id)
        .eq('seller_id', product.sellerId)
        .select()
        .single();

    await _saveSellerInventory(product.id, product);
    return ProductModel.fromJson(response).withInventoryOptions(
      product.inventoryOptions,
      inventoryMode: product.inventoryMode,
    );
  }

  @override
  Future<Map<String, dynamic>> getSellerProductInventory(
    String productId,
  ) async {
    final response = await supabaseClient.rpc(
      'get_seller_product_inventory',
      params: {'p_product_id': productId},
    );
    return Map<String, dynamic>.from(response as Map);
  }

  @override
  Future<String?> deleteProduct(String productId) async {
    final userId = supabaseClient.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('Sign in as the product owner to delete it.');
    }
    final product = await supabaseClient
        .from('products')
        .select('image_url')
        .eq('id', productId)
        .eq('seller_id', userId)
        .single();
    // Les images référencées par une commande ou un autre produit sont conservées.
    final orderReferences = await supabaseClient
        .from('orders')
        .select('id')
        .eq('product_id', productId)
        .limit(1);
    await supabaseClient
        .from('products')
        .delete()
        .eq('id', productId)
        .eq('seller_id', userId)
        .select('id')
        .single();

    final imageUrl = product['image_url'] as String?;
    final imagePath = _ownedProductImagePath(imageUrl);
    if (imagePath == null ||
        imageUrl == null ||
        (orderReferences as List).isNotEmpty) {
      return null;
    }
    try {
      final otherProductReferences = await supabaseClient
          .from('products')
          .select('id')
          .eq('image_url', imageUrl)
          .limit(1);
      if ((otherProductReferences as List).isNotEmpty) return null;
      await supabaseClient.storage.from(productImagesStorageBucket).remove([
        imagePath,
      ]);
      return null;
    } catch (error) {
      debugPrint('Product was deleted but its image cleanup failed: $error');
      return 'Product was deleted, but its image could not be removed.';
    }
  }

  String? _ownedProductImagePath(String? imageUrl) {
    if (imageUrl == null || imageUrl.trim().isEmpty) return null;
    final uri = Uri.tryParse(imageUrl.trim());
    if (uri == null || (uri.scheme != 'http' && uri.scheme != 'https')) {
      return null;
    }
    final segments = uri.pathSegments;
    if (segments.length != 7 ||
        segments[0] != 'storage' ||
        segments[1] != 'v1' ||
        segments[2] != 'object' ||
        segments[3] != 'public' ||
        segments[4] != productImagesStorageBucket ||
        segments[5] != 'products' ||
        segments[6].isEmpty) {
      return null;
    }

    final path = segments.skip(5).join('/');
    final expectedUri = Uri.parse(
      supabaseClient.storage
          .from(productImagesStorageBucket)
          .getPublicUrl(path),
    );
    if (uri.origin != expectedUri.origin || uri.path != expectedUri.path) {
      return null;
    }
    return path;
  }

  @override
  Future<Map<String, dynamic>> getSellerFavoriteCounts() async {
    final response = await supabaseClient.rpc('get_seller_favorite_counts');
    return Map<String, dynamic>.from(response as Map);
  }

  Future<void> _saveSellerInventory(
    String productId,
    ProductModel product,
  ) async {
    final options = product.inventoryOptions;
    if (product.inventoryMode == 'simple') {
      final simpleOption = options.where(
        (option) => option.color == null && option.size == null,
      );
      if (simpleOption.length != 1 ||
          simpleOption.single.stockQuantity == null) {
        throw StateError('A simple product requires one stock quantity.');
      }
      await supabaseClient.rpc(
        'save_seller_product_inventory',
        params: {
          'p_product_id': productId,
          'p_mode': 'simple',
          'p_simple_stock': simpleOption.single.stockQuantity,
          'p_options': [],
        },
      );
      return;
    }

    if (product.inventoryMode != 'variants' || options.isEmpty) {
      throw StateError(
        'Configure simple stock or at least one product variant.',
      );
    }
    await supabaseClient.rpc(
      'save_seller_product_inventory',
      params: {
        'p_product_id': productId,
        'p_mode': 'variants',
        'p_simple_stock': null,
        'p_options': options
            .map(
              (option) => {
                'color': option.color,
                'size': option.size,
                'stock_quantity': option.stockQuantity,
              },
            )
            .toList(),
      },
    );
  }

  Future<List<ProductModel>> _loadPublicInventoryOptions(
    List<ProductModel> products,
  ) async {
    if (products.isEmpty) return products;

    // Charge en une requête les variantes de tous les produits affichés.
    final productIds = products.map((product) => product.id).toList();
    final response = await supabaseClient
        .from('product_inventory_options')
        .select()
        .inFilter('product_id', productIds);
    final optionsByProduct = <String, List<ProductInventoryOptionEntity>>{};
    for (final row in response as List<dynamic>) {
      final option = ProductInventoryOptionEntity.fromJson(
        Map<String, dynamic>.from(row as Map),
      );
      final productId = row['product_id'].toString();
      optionsByProduct.putIfAbsent(productId, () => []).add(option);
    }

    return products
        .map(
          (product) => product.withInventoryOptions(
            optionsByProduct[product.id] ?? const [],
          ),
        )
        .toList();
  }
}
