abstract class AppRoutes {
  // Path Constants
  static const String splash = '/splash';
  static const String login = '/login';
  static const String catalog = '/catalog';
  static const String productDetails = '/product/:id';
  static const String cart = '/cart';
  static const String checkout = '/checkout';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Helper method for parameter substitution
  static String productDetailsPath(String id) => '/product/$id';
}
