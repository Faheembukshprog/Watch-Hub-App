import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
import '../../features/admin/presentation/views/admin_screen.dart';

import 'scaffold_with_nav_bar.dart';

// Providers Import
import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import 'package:app_watchhub/features/profile/presentation/providers/profile_provider.dart';

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

  static String productDetailsPath(String id) => '/product/$id';
}

bool isProtectedRoute(String location) {
  return location.startsWith(AppRoutes.checkout) ||
      location.startsWith(AppRoutes.orders) ||
      location.startsWith(AppRoutes.profile) ||
      location.startsWith(AppRoutes.admin);
}

bool isAllowedRedirect(String redirect) {
  return redirect.startsWith('/') && !redirect.startsWith('//');
}

/// Pure redirect resolver used by GoRouter and unit tests.
String? resolveAuthRedirect({
  required bool isLoading,
  required bool hasError,
  required bool isLoggedIn,
  required bool isAdmin,
  required String location,
  required String? redirectParam,
}) {
  if (isLoading) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (hasError) {
    return location == AppRoutes.splash ? null : AppRoutes.splash;
  }

  if (!isLoggedIn) {
    if (location == AppRoutes.login) return null;
    if (location == AppRoutes.catalog) return null;
    if (location == AppRoutes.splash) return AppRoutes.catalog;

    if (isProtectedRoute(location)) {
      return '${AppRoutes.login}?redirect=${Uri.encodeComponent(location)}';
    }

    return AppRoutes.login;
  }

  // Admin Redirection Logic - Force to Admin Panel ONLY on login/splash
  if (isAdmin) {
    if (location == AppRoutes.login || location == AppRoutes.splash) {
      return AppRoutes.admin;
    }
    return null;
  }

  if (location == AppRoutes.login || location == AppRoutes.splash || location == AppRoutes.admin) {
    if (redirectParam != null &&
        redirectParam.isNotEmpty &&
        isAllowedRedirect(redirectParam)) {
      return redirectParam;
    }
    return AppRoutes.catalog;
  }

  return null;
}

/// Custom notifier class to publicly expose notifyListeners for GoRouter
class RouterRefreshNotifier extends ChangeNotifier {
  void notify() => notifyListeners();
}

/// Centralized GoRouter Engine Provider
final routerProvider = Provider<GoRouter>((ref) {
  final refreshNotifier = RouterRefreshNotifier();

  // Listen reactively to authStateProvider changes
  ref.listen<AsyncValue<dynamic>>(
    authStateProvider,
    (_, _) => refreshNotifier.notify(),
  );

  // Also listen to profile changes for isAdmin updates
  ref.listen<AsyncValue<dynamic>>(
    userProfileProvider,
    (_, _) => refreshNotifier.notify(),
  );

  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    navigatorKey: _rootNavigatorKey,
    debugLogDiagnostics: kDebugMode,
    refreshListenable: refreshNotifier,

    redirect: (context, state) {
      final authState = ref.read(authStateProvider);
      final profileState = ref.read(userProfileProvider);
      
      final isAdmin = profileState.value?['isAdmin'] == true;

      return resolveAuthRedirect(
        isLoading: authState.isLoading,
        hasError: authState.hasError,
        isLoggedIn: authState.value != null,
        isAdmin: isAdmin,
        location: state.matchedLocation,
        redirectParam: state.uri.queryParameters['redirect'],
      );
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
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AdminScreen(),
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

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.watch, size: 80, color: AppColors.goldAccent),
              const SizedBox(height: 24),
              const CircularProgressIndicator(color: AppColors.goldAccent),
              const SizedBox(height: 24),
              Text(
                'Initializing...',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: AppColors.neutral,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
