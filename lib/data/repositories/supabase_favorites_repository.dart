import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/repositories/favorites_repository.dart';

/// Persiste les favoris en les associant à l'utilisateur Supabase connecté.
class SupabaseFavoritesRepository implements FavoritesRepository {
  final SupabaseClient supabaseClient;

  SupabaseFavoritesRepository(this.supabaseClient);

  String get _userId {
    // Les opérations de favoris sont exécutées pour la session courante.
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to manage favorites.');
    }
    return user.id;
  }

  @override
  Future<Set<String>> getFavoriteProductIds() async {
    final userId = _userId;
    final rows = await supabaseClient
        .from('favorites')
        .select('product_id')
        .eq('user_id', userId);
    return (rows as List<dynamic>)
        .map((row) => (row as Map<String, dynamic>)['product_id'].toString())
        .toSet();
  }

  @override
  Future<void> addFavorite(String productId) async {
    await supabaseClient.from('favorites').insert({
      'user_id': _userId,
      'product_id': productId,
    });
  }

  @override
  Future<void> removeFavorite(String productId) async {
    final userId = _userId;
    await supabaseClient
        .from('favorites')
        .delete()
        .eq('user_id', userId)
        .eq('product_id', productId);
  }
}
