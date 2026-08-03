import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:app_watchhub/shared/models/review_model.dart';
import '../../data/repositories/review_repository.dart';

part 'reviews_provider.g.dart';

@riverpod
Stream<List<ReviewModel>> productReviews(Ref ref, String productId) {
  return ref.watch(reviewRepositoryProvider).watchReviewsForProduct(productId);
}
