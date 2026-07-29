import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_watchhub/features/catalog/presentation/screens/product_details_screen.dart';

void main() {
  testWidgets(
    'ProductDetailsScreen renders product details and responds to interactions',
    (WidgetTester tester) async {
      // 1. Build the widget wrapped in ProviderScope & MaterialApp
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: ProductDetailsScreen(id: 'omega_speedmaster'),
          ),
        ),
      );

      // 2. Verify all key elements are presented on screen
      expect(find.byType(ProductDetailsScreen), findsOneWidget);
      expect(find.text('OMEGA'), findsOneWidget);
      expect(find.text('Speedmaster Professional Moonwatch'), findsOneWidget);
      expect(find.text('\$6800.00'), findsOneWidget);
      expect(find.text('Specifications'), findsOneWidget);
      expect(find.text('ADD TO CART'), findsOneWidget);

      // 3. Verify reviews section is present
      expect(find.text('Customer Reviews'), findsOneWidget);
      expect(find.text('Write Review'), findsOneWidget);

      // 4. Tap the Favorite (wishlist) button and verify response
      final favButton = find.byIcon(Icons.favorite_border);
      expect(favButton, findsOneWidget);
      await tester.tap(favButton);
      await tester.pump();

      // The icon should toggle to favorite
      expect(find.byIcon(Icons.favorite), findsOneWidget);
    },
  );
}
