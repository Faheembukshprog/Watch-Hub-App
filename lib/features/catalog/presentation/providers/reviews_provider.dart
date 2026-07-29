import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/shared/models/review_model.dart';

part 'reviews_provider.g.dart';

@riverpod
class ProductReviews extends _$ProductReviews {
  @override
  Map<String, List<ReviewModel>> build() {
    // Seed default reviews for any product ID
    return {
      'omega_speedmaster': [
        ReviewModel(
          id: '1',
          userName: 'Alex Mercer',
          rating: 5.0,
          comment:
              'The Speedmaster is an absolute masterpiece. The history, the craftsmanship, and the wrist presence are unmatched. Highly recommended!',
          date: DateTime.now().subtract(const Duration(days: 3)),
        ),
        ReviewModel(
          id: '2',
          userName: 'Sophia Laurent',
          rating: 4.5,
          comment:
              'Incredible details on the dial. The hand-wound movement is tactile and satisfying. A must-have in any luxury watch collection.',
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ],
    };
  }

  void addReview(
    String productId,
    String userName,
    double rating,
    String comment,
  ) {
    final newReview = ReviewModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userName: userName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );

    final currentReviews = state[productId] ?? [];
    state = {
      ...state,
      productId: [...currentReviews, newReview],
    };
  }
}
