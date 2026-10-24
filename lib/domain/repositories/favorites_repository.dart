/// Contrat de lecture et de modification des favoris de l'utilisateur.
abstract class FavoritesRepository {
  Future<Set<String>> getFavoriteProductIds();
  Future<void> addFavorite(String productId);
  Future<void> removeFavorite(String productId);
}
