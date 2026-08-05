import 'package:flutter/material.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../providers/cart_provider.dart';

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(cartProvider);
    final cartNotifier = ref.read(cartProvider.notifier);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subtotal = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    // Luxury Boutique Details
    const shipping = 0.00; // Free Express Delivery for VIP clients
    final tax = subtotal * 0.08; // 8% Luxury Sales Tax
    final totalAmount = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBg
          : Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'SHOPPING BAG',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          if (cartItems.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear Bag',
              onPressed: () {
                cartNotifier.clearCart();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Shopping bag cleared.'),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: AppColors.goldAccent,
                  ),
                );
              },
            ),
        ],
      ),
      body: cartItems.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your cart is empty',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add watches to your bag and return here to complete checkout.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),
                    OutlinedButton(
                      onPressed: () => context.go('/catalog'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.goldAccent,
                        side: const BorderSide(color: AppColors.goldAccent),
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continue Shopping'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                // --- Cart Items List ---
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        child: Row(
                          children: [
                            // Watch Image Container
                            Container(
                              width: 80,
                              height: 80,
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkBg
                                    : AppColors.lightSurfaceMuted,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: item.product.imageUrl.isNotEmpty
                                  ? CachedNetworkImage(
                                      imageUrl: item.product.imageUrl,
                                      fit: BoxFit.contain,
                                      errorWidget: (context, url, error) =>
                                          Icon(
                                            Icons.watch_rounded,
                                            color: isDark
                                                ? Colors.white30
                                                : Colors.black26,
                                          ),
                                    )
                                  : Icon(
                                      Icons.watch_rounded,
                                      color: isDark
                                          ? Colors.white30
                                          : Colors.black26,
                                    ),
                            ),
                            const SizedBox(width: 16),

                            // Watch Meta Details
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.product.brand.toUpperCase(),
                                    style: GoogleFonts.outfit(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.goldAccent,
                                      letterSpacing: 1.0,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.product.name,
                                    style: GoogleFonts.outfit(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: isDark
                                          ? Colors.white
                                          : AppColors.lightTextPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    '\$${item.product.price.toStringAsFixed(0)}',
                                    style: GoogleFonts.outfit(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.goldAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Quantity Selector Controls
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        cartNotifier.updateQuantity(
                                          item.product.id,
                                          item.quantity - 1,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isDark
                                                ? AppColors.darkBorder
                                                : AppColors.lightBorder,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.remove,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10.0,
                                      ),
                                      child: Text(
                                        '${item.quantity}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        cartNotifier.updateQuantity(
                                          item.product.id,
                                          item.quantity + 1,
                                        );
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: isDark
                                                ? AppColors.darkBorder
                                                : AppColors.lightBorder,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                        child: Icon(
                                          Icons.add,
                                          size: 16,
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () {
                                    cartNotifier.removeFromCart(
                                      item.product.id,
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Removed ${item.product.name} from bag.',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.goldAccent,
                                      ),
                                    );
                                  },
                                  child: const Icon(
                                    Icons.delete_outline_rounded,
                                    color: AppColors.error,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),

                // --- Invoice Breakdown Sheet ---
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurface : Colors.white,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(24),
                    ),
                    border: Border(
                      top: BorderSide(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Subtotal',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              '\$${subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Shipping (Express)',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            const Text(
                              'FREE',
                              style: TextStyle(
                                color: AppColors.success,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Estimated Tax (8%)',
                              style: TextStyle(
                                color: isDark
                                    ? AppColors.darkTextSecondary
                                    : AppColors.lightTextSecondary,
                              ),
                            ),
                            Text(
                              '\$${tax.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Total Amount',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              '\$${totalAmount.toStringAsFixed(2)}',
                              style: GoogleFonts.outfit(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppColors.goldAccent,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              context.push('/checkout');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldAccent,
                              foregroundColor: isDark
                                  ? AppColors.darkBg
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            child: Text(
                              'PROCEED TO CHECKOUT',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
