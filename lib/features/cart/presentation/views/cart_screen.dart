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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: cartItems.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your curated bag is empty',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Explore our exclusive timepieces and select a masterpiece to begin your collection.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => context.go('/catalog'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldAccent,
                            foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                            minimumSize: const Size(220, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('EXPLORE COLLECTION'),
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
                        padding: const EdgeInsets.all(24),
                        physics: const BouncingScrollPhysics(),
                        itemCount: cartItems.length,
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Container(
                            margin: const EdgeInsets.only(bottom: 20),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: isDark ? AppColors.darkSurface : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Row(
                              children: [
                                // Watch Image Container
                                Container(
                                  width: 100,
                                  height: 100,
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? AppColors.darkBg
                                        : AppColors.lightSurfaceMuted,
                                    borderRadius: BorderRadius.circular(16),
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
                                const SizedBox(width: 20),

                                // Watch Meta Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.product.brand.toUpperCase(),
                                        style: GoogleFonts.outfit(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.goldAccent,
                                          letterSpacing: 1.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.product.name,
                                        style: GoogleFonts.outfit(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isDark
                                              ? Colors.white
                                              : AppColors.lightTextPrimary,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '\$${item.product.price.toStringAsFixed(0)}',
                                        style: GoogleFonts.outfit(
                                          fontSize: 15,
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
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isDark
                                                    ? AppColors.darkBorder
                                                    : AppColors.lightBorder,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.remove,
                                              size: 18,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14.0,
                                          ),
                                          child: Text(
                                            '${item.quantity}',
                                            style: GoogleFonts.outfit(
                                              fontSize: 16,
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
                                            padding: const EdgeInsets.all(6),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: isDark
                                                    ? AppColors.darkBorder
                                                    : AppColors.lightBorder,
                                              ),
                                              borderRadius: BorderRadius.circular(
                                                8,
                                              ),
                                            ),
                                            child: Icon(
                                              Icons.add,
                                              size: 18,
                                              color: isDark
                                                  ? Colors.white70
                                                  : Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 16),
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
                                        size: 22,
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
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(32),
                        ),
                        border: Border(
                          top: BorderSide(
                            color: isDark
                                ? AppColors.darkBorder
                                : AppColors.lightBorder,
                          ),
                        ),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, -5))
                        ],
                      ),
                      child: SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            _buildInvoiceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', isDark),
                            const SizedBox(height: 12),
                            _buildInvoiceRow('Global Logistics', 'FREE', isDark, isSuccess: true),
                            const SizedBox(height: 12),
                            _buildInvoiceRow('Sales Tax (8%)', '\$${tax.toStringAsFixed(2)}', isDark),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20),
                              child: Divider(height: 1),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'GRAND TOTAL',
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.0,
                                    color: isDark
                                        ? Colors.white
                                        : AppColors.lightTextPrimary,
                                  ),
                                ),
                                Text(
                                  '\$${totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.goldAccent,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 32),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: () => context.push('/checkout'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.goldAccent,
                                  foregroundColor: isDark
                                      ? AppColors.darkBg
                                      : Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 20),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                  elevation: 4,
                                ),
                                child: Text(
                                  'PROCEED TO SECURE CHECKOUT',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.5,
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
        ),
      ),
    );
  }

  Widget _buildInvoiceRow(String label, String value, bool isDark, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSuccess ? AppColors.success : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}
