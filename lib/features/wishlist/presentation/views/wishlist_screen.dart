import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      backgroundColor: isDark
          ? const Color(0xFF0F1115)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'CURATED WISHLIST',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.favorite_border_rounded,
                      size: 80,
                      color: isDark ? Colors.white24 : Colors.black26,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Your curated wishlist is empty',
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? const Color(0xFFA0A5B5)
                            : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Curate your personal collection of luxury pieces while browsing the boutique.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark ? Colors.white30 : Colors.black38,
                      ),
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
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
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

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image Container + Remove button overlay
          Expanded(
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF0F1115)
                        : const Color(0xFFF1F5F9),
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
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
                        color: isDark ? const Color(0xFF20242D) : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A2E39)
                              : const Color(0xFFE2E8F0),
                        ),
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        size: 16,
                        color: Colors.redAccent,
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
                    color: const Color(0xFFD4AF37),
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  watch.name,
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
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
                    color: const Color(0xFFD4AF37),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(cartProvider.notifier).addToCart(watch);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Added ${watch.name} to Shopping Bag'),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: const Color(0xFFD4AF37),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD4AF37),
                      foregroundColor: isDark
                          ? const Color(0xFF0F1115)
                          : Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'ADD TO BAG',
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
