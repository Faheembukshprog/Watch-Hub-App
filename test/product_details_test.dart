import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_watchhub/features/catalog/presentation/screens/product_details_screen.dart';
import 'package:app_watchhub/features/catalog/presentation/providers/reviews_provider.dart';
import 'package:app_watchhub/shared/models/review_model.dart';

void main() {
  testWidgets(
    'ProductDetailsScreen renders product details and responds to interactions',
    (WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            productReviewsProvider('omega_speedmaster').overrideWith(
              (ref) => Stream.value([
                ReviewModel(
                  id: '1',
                  productId: 'omega_speedmaster',
                  userId: 'user-1',
                  userName: 'Alex Mercer',
                  rating: 5.0,
                  comment: 'Incredible details on the dial.',
                  date: DateTime(2026, 7, 20),
                ),
              ]),
            ),
          ],
          child: const MaterialApp(
            home: ProductDetailsScreen(id: 'omega_speedmaster'),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      expect(find.text('OMEGA'), findsOneWidget);
      expect(find.text('Speedmaster Professional Moonwatch'), findsOneWidget);
      expect(find.text('\$6800.00'), findsOneWidget);
      expect(find.text('Specifications'), findsOneWidget);
      expect(find.text('ADD TO CART'), findsOneWidget);
      expect(find.text('Customer Reviews'), findsOneWidget);
      expect(find.text('Write Review'), findsOneWidget);
      expect(find.text('Alex Mercer'), findsOneWidget);

      final favButton = find.byIcon(Icons.favorite_border);
      expect(favButton, findsOneWidget);
      await tester.tap(favButton);
      await tester.pump();

      expect(find.byIcon(Icons.favorite), findsOneWidget);
    },
  );
}
