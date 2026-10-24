import '../entities/review_entity.dart';

abstract class ReviewRepository {
  /// Retourne les avis visibles pour ce produit selon les règles du backend.
  Future<List<ReviewEntity>> getProductReviews(String productId);
  Future<ReviewEntity> submitReview({
    required String productId,
    required int rating,
    required String reviewText,
  });
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  });
  /// Supprime l'avis après vérification de son propriétaire par l'implémentation.
  Future<void> deleteReview(String reviewId);
}
