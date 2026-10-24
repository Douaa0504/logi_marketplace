import '../entities/review_entity.dart';

abstract class ReviewRepository {
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
  Future<void> deleteReview(String reviewId);
}
