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
import '../../features/support/presentation/views/support_screen.dart';
import '../../features/support/presentation/views/faq_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/wishlist/presentation/views/wishlist_screen.dart';
import 'go_router_refresh_stream.dart';
import 'scaffold_with_nav_bar.dart';

// Providers Import
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

// Define a root navigator key for full-screen routes
final _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

/// Route Path Constants
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
  static const String faq = '/faq';
  static const String support = '/support';
  static const String wishlist = '/wishlist';
}

/// Centralized GoRouter Engine Provider
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = GoRouterRefreshStream(
    ref.watch(firebaseAuthProvider).authStateChanges(),
  );

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: true,
    refreshListenable: refreshNotifier,

    /// Security Gatekeeper Redirect Logic
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
        builder: (context, state) => const LoginScreen(),
      ),

      // --- ADMIN ROUTE ---
      GoRoute(
        path: AppRoutes.admin,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Admin Control Panel'))),
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final productId = state.pathParameters['id'] ?? '';
          return ProductDetailsScreen(id: productId);
        },
      ),
      GoRoute(
        path: AppRoutes.checkout,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const CheckoutScreen(),
      ),
      GoRoute(
        path: AppRoutes.faq,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const FAQScreen(),
      ),
      GoRoute(
        path: AppRoutes.support,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SupportScreen(),
      ),
      GoRoute(
        path: AppRoutes.wishlist,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const WishlistScreen(),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Route routing error: ${state.error}')),
    ),
  );
});

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.watch, size: 80, color: Color(0xFFD4AF37)),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFFD4AF37)),
          ],
        ),
      ),
    );
  }
}
