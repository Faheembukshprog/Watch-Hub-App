// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:app_watchhub/main.dart';
import 'package:app_watchhub/core/router/app_router.dart';

void main() {
  testWidgets('App bootstrap initialization smoke test', (WidgetTester tester) async {
    // 1. Create a minimal mock router for testing bootstrap
    final mockRouter = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const Scaffold(body: Text('Mock UI')),
        ),
      ],
    );

    // 2. Build our app and trigger a frame inside the Riverpod Provider Scope
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Override the real routerProvider which depends on Firebase
          routerProvider.overrideWithValue(mockRouter),
        ],
        child: const AppWatchHub(),
      ),
    );

    // Verify that the foundational MaterialApp configuration loaded cleanly
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}