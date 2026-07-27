import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:app_watchhub/features/cart/presentation/providers/cart_provider.dart';
import 'package:app_watchhub/features/catalog/domain/models/product_model.dart';

void main() {
  group('CartNotifier Unit Tests', () {
    late ProviderContainer container;

    final testProduct1 = ProductModel(
      id: 'watch-001',
      name: 'Seamaster 300M',
      brand: 'Omega',
      price: 5400.00,
      imageUrl: '',
      description: 'Classic professional dive timepiece.',
      stockCount: 10,
    );

    final testProduct2 = ProductModel(
      id: 'watch-002',
      name: 'Submariner',
      brand: 'Rolex',
      price: 9500.00,
      imageUrl: '',
      description: 'The legendary luxury diving watch.',
      stockCount: 5,
    );

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('Initial cart state should be empty list', () {
      final cart = container.read(cartProvider);
      expect(cart, isEmpty);
      expect(container.read(cartProvider.notifier).totalAmount, 0.0);
      expect(container.read(cartProvider.notifier).totalItemCount, 0);
    });

    test('addToCart adds a new product or increments quantity if existing', () {
      final notifier = container.read(cartProvider.notifier);

      // Add Product 1
      notifier.addToCart(testProduct1);
      var cart = container.read(cartProvider);
      expect(cart, hasLength(1));
      expect(cart[0].product.id, 'watch-001');
      expect(cart[0].quantity, 1);
      expect(notifier.totalAmount, 5400.00);

      // Add Product 1 again (should increment quantity)
      notifier.addToCart(testProduct1);
      cart = container.read(cartProvider);
      expect(cart, hasLength(1));
      expect(cart[0].quantity, 2);
      expect(notifier.totalAmount, 10800.00);

      // Add Product 2
      notifier.addToCart(testProduct2);
      cart = container.read(cartProvider);
      expect(cart, hasLength(2));
      expect(cart[1].product.id, 'watch-002');
      expect(cart[1].quantity, 1);
      expect(notifier.totalAmount, 20300.00);
      expect(notifier.totalItemCount, 3);
    });

    test('updateQuantity modifies item quantity or removes if quantity <= 0', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addToCart(testProduct1);
      notifier.addToCart(testProduct2);

      // Update quantity of product 1 to 5
      notifier.updateQuantity('watch-001', 5);
      var cart = container.read(cartProvider);
      expect(cart[0].quantity, 5);
      expect(notifier.totalAmount, (5400.00 * 5) + 9500.00);

      // Update quantity of product 2 to 0 (should remove it)
      notifier.updateQuantity('watch-002', 0);
      cart = container.read(cartProvider);
      expect(cart, hasLength(1));
      expect(cart[0].product.id, 'watch-001');
      expect(notifier.totalAmount, 5400.00 * 5);
    });

    test('removeFromCart completely deletes item from cart', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addToCart(testProduct1);
      notifier.addToCart(testProduct2);

      expect(container.read(cartProvider), hasLength(2));

      notifier.removeFromCart('watch-001');
      final cart = container.read(cartProvider);
      expect(cart, hasLength(1));
      expect(cart[0].product.id, 'watch-002');
      expect(notifier.totalAmount, 9500.00);
    });

    test('clearCart empties the shopping cart', () {
      final notifier = container.read(cartProvider.notifier);

      notifier.addToCart(testProduct1);
      notifier.addToCart(testProduct2);

      expect(container.read(cartProvider), isNotEmpty);

      notifier.clearCart();
      expect(container.read(cartProvider), isEmpty);
      expect(notifier.totalAmount, 0.0);
    });
  });
}
