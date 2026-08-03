import 'package:flutter_test/flutter_test.dart';
import 'package:app_watchhub/shared/models/review_model.dart';

void main() {
  group('ReviewModel', () {
    test('fromJson maps Firestore review fields', () {
      final review = ReviewModel.fromJson({
        'id': 'review-1',
        'productId': 'omega_speedmaster',
        'userId': 'user-123',
        'userName': 'Alex Mercer',
        'rating': 4.5,
        'comment': 'Excellent craftsmanship.',
        'date': '2026-07-28T10:15:00.000',
      });

      expect(review.id, 'review-1');
      expect(review.productId, 'omega_speedmaster');
      expect(review.userId, 'user-123');
      expect(review.userName, 'Alex Mercer');
      expect(review.rating, 4.5);
      expect(review.comment, 'Excellent craftsmanship.');
    });

    test('toJson includes fields required by Firestore rules', () {
      final review = ReviewModel(
        id: 'review-1',
        productId: 'omega_speedmaster',
        userId: 'user-123',
        userName: 'Alex Mercer',
        rating: 5,
        comment: 'Great watch.',
        date: DateTime.utc(2026, 7, 28),
      );

      final json = review.toJson();

      expect(json['productId'], 'omega_speedmaster');
      expect(json['userId'], 'user-123');
      expect(json['userName'], 'Alex Mercer');
      expect(json['rating'], 5);
      expect(json['comment'], 'Great watch.');
    });
  });
}
