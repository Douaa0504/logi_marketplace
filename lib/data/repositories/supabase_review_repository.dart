import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/review_entity.dart';
import '../../domain/repositories/review_repository.dart';

class SupabaseReviewRepository implements ReviewRepository {
  final SupabaseClient supabaseClient;

  SupabaseReviewRepository(this.supabaseClient);

  @override
  Future<List<ReviewEntity>> getProductReviews(String productId) async {
    final response = await supabaseClient
        .from('product_reviews_public')
        .select()
        .eq('product_id', productId)
        .order('created_at', ascending: false);

    return (response as List<dynamic>).map((row) {
      final item = Map<String, dynamic>.from(row as Map);
      return ReviewEntity.fromJson(item);
    }).toList();
  }

  @override
  Future<ReviewEntity> submitReview({
    required String productId,
    required int rating,
    required String reviewText,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Only authenticated buyers can submit reviews.');
    }

    if (rating < 1 || rating > 5) {
      throw StateError('Rating must be between 1 and 5.');
    }
    final trimmedComment = reviewText.trim();
    if (trimmedComment.isEmpty || trimmedComment.length > 2000) {
      throw StateError('Review text must be between 1 and 2,000 characters.');
    }

    await supabaseClient
        .from('product_reviews')
        .insert({
          'product_id': productId,
          'buyer_id': user.id,
          'rating': rating,
          'review_text': trimmedComment,
        });

    final row = await supabaseClient
        .from('product_reviews_public')
        .select()
        .eq('product_id', productId)
        .eq('is_mine', true)
        .single();
    return ReviewEntity.fromJson(Map<String, dynamic>.from(row));
  }

  @override
  Future<void> updateReview({
    required String reviewId,
    required int rating,
    required String reviewText,
  }) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to update your review.');
    }
    if (rating < 1 || rating > 5) {
      throw StateError('Rating must be between 1 and 5.');
    }
    final trimmedComment = reviewText.trim();
    if (trimmedComment.isEmpty || trimmedComment.length > 2000) {
      throw StateError('Review text must be between 1 and 2,000 characters.');
    }

    await supabaseClient
        .from('product_reviews')
        .update({
          'rating': rating,
          'review_text': trimmedComment,
        })
        .eq('id', reviewId);
  }

  @override
  Future<void> deleteReview(String reviewId) async {
    final user = supabaseClient.auth.currentUser;
    if (user == null) {
      throw StateError('Sign in to delete your review.');
    }

    final ownReview = await supabaseClient
        .from('product_reviews_public')
        .select('id')
        .eq('id', reviewId)
        .eq('is_mine', true)
        .maybeSingle();
    if (ownReview == null) {
      throw StateError('You can only delete your own review.');
    }

    await supabaseClient
        .from('product_reviews')
        .delete()
        .eq('id', reviewId);

    final remainingReview = await supabaseClient
        .from('product_reviews_public')
        .select('id')
        .eq('id', reviewId)
        .maybeSingle();
    if (remainingReview != null) {
      throw StateError('Your review could not be deleted.');
    }
  }
}
