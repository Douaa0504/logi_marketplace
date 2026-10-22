abstract class FavoritesRepository {
  Future<Set<String>> getFavoriteProductIds();
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
}
