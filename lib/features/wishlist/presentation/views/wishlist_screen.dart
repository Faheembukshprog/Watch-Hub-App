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
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1200), // Grid needs more width
          child: catalogAsync.when(
            data: (products) {
              final wishlistedProducts = products
                  .where((p) => wishlistIds.contains(p.id))
                  .toList();

              if (wishlistedProducts.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.favorite_border_rounded,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your wishlist is empty',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Add watches to your wishlist and move them to the cart when you are ready to buy.',
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
                            foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                            backgroundColor: AppColors.goldAccent,
                            minimumSize: const Size(200, 52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          child: const Text('CONTINUE BROWSING'),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return GridView.builder(
                padding: const EdgeInsets.all(24),
                physics: const BouncingScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 250,
                  childAspectRatio: 0.68,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
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
        ),
      ),
    );
  }
}

class _WishlistCard extends ConsumerWidget {
  final ProductModel watch;
  const _WishlistCard({required this.watch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 4,
      shadowColor: Colors.black12,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: isDark
          ? AppColors.darkSurface
          : Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container + Remove button overlay
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Container(
                    width: double.infinity,
                    color: isDark ? AppColors.darkBg : Colors.grey[100],
                    padding: const EdgeInsets.all(16),
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
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      ref.read(wishlistProvider.notifier).toggleWishlist(watch);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(6),
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
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)]
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
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  watch.brand.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldAccent,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  watch.name,
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Text(
                  '\$${watch.price.toStringAsFixed(0)}',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.goldAccent,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: watch.stock <= 0
                        ? null
                        : () {
                            final error = ref
                                .read(cartProvider.notifier)
                                .addToCart(watch);
                            
                            if (error != null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(error),
                                  backgroundColor: AppColors.error,
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                              return;
                            }

                            ref
                                .read(wishlistProvider.notifier)
                                .toggleWishlist(watch);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Moved ${watch.name} to Shopping Bag'),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: AppColors.goldAccent,
                              ),
                            );
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: watch.stock <= 0
                          ? Colors.grey
                          : AppColors.goldAccent,
                      foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      watch.stock <= 0 ? 'OUT OF STOCK' : 'ADD TO BAG',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
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
