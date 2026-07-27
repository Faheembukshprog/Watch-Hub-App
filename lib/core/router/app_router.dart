import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Feature Imports
import '../../features/cart/presentation/views/cart_screen.dart';
import '../../features/catalog/presentation/screens/catalog_screen.dart';
import '../../features/catalog/presentation/screens/product_details_screen.dart';
import '../../features/checkout/presentation/views/checkout_screen.dart';
import '../../features/orders/presentation/views/order_history_screen.dart';
import '../../features/profile/presentation/views/profile_screen.dart';

import 'scaffold_with_nav_bar.dart';

// FIXED: Define a root navigator key for full-screen routes
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// 0. Converts a Stream into a Listenable for GoRouter.
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Sync initial state
    _subscription = stream.asBroadcastStream().listen(
      (_) => notifyListeners(),
      // FIXED: Changed '__' to '_' for modern Dart unused variable lint
      onError: (Object _, StackTrace _) {}, 
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

/// 1. Route Path Constants
class AppRoutes {
  AppRoutes._();
  static const String splash = '/';
  static const String login = '/login';
  static const String catalog = '/catalog'; 
  static const String productDetails = '/product/:id';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';
  static const String checkout = '/checkout';
  static const String admin = '/admin';
}

/// 2. Stream Provider for Auth Changes
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// 3. Centralized GoRouter Engine Provider
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshStream(
    FirebaseAuth.instance.authStateChanges(),
  );

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: _rootNavigatorKey, // FIXED: Added root key to GoRouter
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,

    /// 4. Security Gatekeeper Redirect Logic
    redirect: (context, state) {
      final authState = ref.read(authStateProvider);

      if (authState.isLoading || authState.hasError) {
        return state.matchedLocation == AppRoutes.splash
            ? null
            : AppRoutes.splash;
      }

      final user = authState.value;
      final isLoggedIn = user != null;

      final isGoingToSplash = state.matchedLocation == AppRoutes.splash;
      final isGoingToLogin = state.matchedLocation == AppRoutes.login;
      final isGoingToAdmin = state.matchedLocation.startsWith(AppRoutes.admin);

      if (!isLoggedIn) {
        if (!isGoingToLogin && !isGoingToSplash) {
          return AppRoutes.login;
        }
        return null;
      }

      // If logged in, don't let them go to splash/login, send to catalog
      if (isGoingToLogin || isGoingToSplash) {
        return AppRoutes.catalog; 
      }

      if (isGoingToAdmin && isLoggedIn) {
        // Reserved for admin access claims
      }

      return null;
    },

    routes: [
      // --- AUTH FLOW ROUTES ---
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreenPlaceholder(),
      ),
      
      // --- ADMIN ROUTE ---
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) => const Scaffold(
          body: Center(child: Text('Admin Control Panel')),
        ),
      ),

      // --- MAIN APP WITH BOTTOM NAVIGATION (StatefulShellRoute) ---
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return ScaffoldWithNavBar(navigationShell: navigationShell);
        },
        branches: [
          // Tab 1: Catalog (Home)
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.catalog,
                builder: (context, state) => const CatalogScreen(),
              ),
            ],
          ),

          // Tab 2: Cart
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.cart,
                builder: (context, state) => const CartScreen(),
              ),
            ],
          ),

          // Tab 3: Orders
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.orders,
                builder: (context, state) => const OrderHistoryScreen(),
              ),
            ],
          ),

          // Tab 4: Profile
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: AppRoutes.profile,
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),

      // --- PUSHED FULL-SCREEN ROUTES (Covers Bottom Nav) ---
      GoRoute(
        path: AppRoutes.productDetails,
        parentNavigatorKey: _rootNavigatorKey, // FIXED: Uses the global key
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailsScreen(id: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        parentNavigatorKey: _rootNavigatorKey, // FIXED: Uses the global key
        builder: (context, state) => const CheckoutScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route routing error: ${state.error}')),
    ),
  );
});

// --- TEMPORARY UI PLACEHOLDERS ---

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch, size: 80, color: Color(0xFF1A237E)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFF1A237E)),
          ],
        ),
      ),
    );
  }
}

class LoginScreenPlaceholder extends StatelessWidget {
  const LoginScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => FirebaseAuth.instance.signInAnonymously(),
          child: const Text('Simulate Firebase Anonymous Sign-In'),
        ),
      ),
    );
  }
}