import 'package:flutter/material.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';

import 'package:app_watchhub/features/catalog/presentation/providers/catalog_providers.dart';
import 'package:app_watchhub/features/catalog/presentation/providers/wishlist_provider.dart';
import 'package:app_watchhub/features/cart/presentation/providers/cart_provider.dart';
import 'package:app_watchhub/features/catalog/domain/models/product_model.dart';

class WishlistScreen extends ConsumerWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlistIds = ref.watch(wishlistProvider);
    final catalogAsync = ref.watch(watchProductsProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'CURATED WISHLIST',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: catalogAsync.when(
        data: (products) {
          final wishlistedProducts = products
              .where((p) => wishlistIds.contains(p.id))
              .toList();

          if (wishlistedProducts.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your wishlist is empty',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add watches to your wishlist and move them to the cart when you are ready to buy.',
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
            );
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.65,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
            ),
            itemCount: wishlistedProducts.length,
            itemBuilder: (context, index) {
              final watch = wishlistedProducts[index];
              return _WishlistCard(watch: watch);
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
        error: (err, stack) =>
            Center(child: Text('Failed to load wishlist: $err')),
      ),
    );
  }
}

class _WishlistCard extends ConsumerWidget {
  final ProductModel watch;
  const _WishlistCard({required this.watch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shadowColor: Colors.black26,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: isDark
          ? AppColors.darkSurface
          : Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container + Remove button overlay
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: isDark ? AppColors.darkBg : Colors.grey[100],
                    padding: const EdgeInsets.all(12),
                    child: watch.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: watch.imageUrl,
                            fit: BoxFit.contain,
                            errorWidget: (context, url, error) => Icon(
                              Icons.watch_rounded,
                              color: isDark ? Colors.white30 : Colors.black26,
                            ),
                          )
                        : Icon(
                            Icons.watch_rounded,
                            color: isDark ? Colors.white30 : Colors.black26,
                          ),
                  ),
                ),

                // Remove from wishlist top-right overlay button
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(wishlistProvider.notifier).toggleWishlist(watch);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: isDark
                            ? AppColors.darkSurfaceCard
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Details + Quick Add to Bag Action Button
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  watch.brand.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldAccent,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  watch.name,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${watch.price.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldAccent,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addToCart(watch);
                      ref.read(wishlistProvider.notifier).toggleWishlist(watch);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Moved ${watch.name} to Shopping Bag'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: AppColors.goldAccent,
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.goldAccent,
                      foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ADD TO CART',
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
