import 'package:flutter_test/flutter_test.dart';
import 'package:app_watchhub/core/router/app_router.dart';

void main() {
  group('resolveAuthRedirect', () {
    test('guest can browse catalog without login', () {
      expect(
        resolveAuthRedirect(
          isLoading: false,
          hasError: false,
          isLoggedIn: false,
          isGuest: false,
          role: null,
          location: AppRoutes.catalog,
          redirectParam: null,
        ),
        isNull,
      );
    });

    test('guest is sent to login with redirect when opening checkout', () {
      expect(
        resolveAuthRedirect(
          isLoading: false,
          hasError: false,
          isLoggedIn: false,
          isGuest: true,
          role: 'user',
          location: AppRoutes.checkout,
          redirectParam: null,
        ),
        '${AppRoutes.login}?redirect=%2Fcheckout',
      );
    });

    test('guest is sent to login for orders and profile', () {
      expect(
        resolveAuthRedirect(
          isLoading: false,
          hasError: false,
          isLoggedIn: false,
          isGuest: true,
          role: null,
          location: AppRoutes.orders,
          redirectParam: null,
        ),
        contains('redirect=%2Forders'),
      );

      expect(
        resolveAuthRedirect(
          isLoading: false,
          hasError: false,
          isLoggedIn: false,
          isGuest: true,
          role: null,
          location: AppRoutes.profile,
          redirectParam: null,
        ),
        contains('redirect=%2Fprofile'),
      );
    });

    test('resolved splash sends everyone to catalog', () {
      expect(
        resolveAuthRedirect(
          isLoading: false,
          hasError: false,
          isLoggedIn: false,
          isGuest: false,
          role: null,
          location: AppRoutes.splash,
          redirectParam: null,
        ),
        AppRoutes.catalog,
      );
    });

    test('logged-in user returns to redirect target after login', () {
      expect(
        resolveAuthRedirect(
          isLoading: false,
          hasError: false,
          isLoggedIn: true,
          isGuest: false,
          role: 'user',
          location: AppRoutes.login,
          redirectParam: AppRoutes.checkout,
        ),
        AppRoutes.checkout,
      );
    });

    test('admin is forced to admin dashboard', () {
      expect(
        resolveAuthRedirect(
          isLoading: false,
          hasError: false,
          isLoggedIn: true,
          isGuest: false,
          role: 'admin',
          location: AppRoutes.catalog,
          redirectParam: null,
        ),
        AppRoutes.admin,
      );
    });

    test('auth loading keeps splash and blocks other routes', () {
      expect(
        resolveAuthRedirect(
          isLoading: true,
          hasError: false,
          isLoggedIn: false,
          isGuest: false,
          role: null,
          location: AppRoutes.splash,
          redirectParam: null,
        ),
        isNull,
      );

      expect(
        resolveAuthRedirect(
          isLoading: true,
          hasError: false,
          isLoggedIn: false,
          isGuest: false,
          role: null,
          location: AppRoutes.catalog,
          redirectParam: null,
        ),
        AppRoutes.splash,
      );
    });
  });
}
