import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_watchhub/shared/models/review_model.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

final reviewRepositoryProvider = Provider<ReviewRepository>((ref) {
  return ReviewRepository(ref.watch(firebaseFirestoreProvider));
});

class ReviewRepository {
  ReviewRepository(this._firestore);

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _reviews =>
      _firestore.collection('reviews');

  Stream<List<ReviewModel>> watchReviewsForProduct(String productId) {
    return _reviews
        .where('productId', isEqualTo: productId)
        .snapshots()
        .map((snapshot) {
          final reviews = snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ReviewModel.fromJson(data);
          }).toList();

          reviews.sort((a, b) => b.date.compareTo(a.date));
          return reviews;
        });
  }

  Future<void> submitReview({
    required String productId,
    required String userId,
    required String userName,
    required double rating,
    required String comment,
  }) async {
    final docRef = _reviews.doc();
    final review = ReviewModel(
      id: docRef.id,
      productId: productId,
      userId: userId,
      userName: userName,
      rating: rating,
      comment: comment,
      date: DateTime.now(),
    );

    await docRef.set(review.toJson());
  }
}
