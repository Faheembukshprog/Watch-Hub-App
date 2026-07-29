import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../domain/models/product_model.dart';
import '../providers/catalog_providers.dart';
import '../providers/wishlist_provider.dart';
import '../providers/reviews_provider.dart';
import 'package:app_watchhub/features/cart/presentation/providers/cart_provider.dart';
import 'package:app_watchhub/shared/models/review_model.dart';

class ProductDetailsScreen extends ConsumerWidget {
  final String id;

  const ProductDetailsScreen({super.key, required this.id});

  // Dynamic Specs Map based on watch ID
  static const Map<String, Map<String, String>> _specsMap = {
    'rolex_submariner': {
      'movement': 'Automatic Calibre 3235',
      'diameter': '41 mm',
      'water': '300 Meters / 30 Bar',
      'reserve': '70 Hours',
    },
    'omega_speedmaster': {
      'movement': 'Manual Calibre 3861',
      'diameter': '42 mm',
      'water': '50 Meters / 5 Bar',
      'reserve': '50 Hours',
    },
    'patek_nautilus': {
      'movement': 'Automatic Calibre 26-330',
      'diameter': '40 mm',
      'water': '120 Meters / 12 Bar',
      'reserve': '45 Hours',
    },
    'ap_royal_oak': {
      'movement': 'Automatic Calibre 4302',
      'diameter': '41 mm',
      'water': '50 Meters / 5 Bar',
      'reserve': '70 Hours',
    },
    'cartier_santos': {
      'movement': 'Automatic Calibre 1847 MC',
      'diameter': '39.8 mm',
      'water': '100 Meters / 10 Bar',
      'reserve': '42 Hours',
    },
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(watchProductsProvider);

    return productsAsync.when(
      data: (products) {
        final product = products.firstWhere(
          (p) => p.id == id,
          orElse: () => ProductModel(
            id: id,
            name: 'Speedmaster Professional Moonwatch',
            brand: 'OMEGA',
            price: 6800.00,
            imageUrl:
                'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=600',
            description:
                'The Speedmaster Professional Moonwatch is one of the world\'s most iconic timepieces. Having been a part of all six lunar missions, the legendary chronograph is an impressive representation of the brand\'s adventurous pioneering spirit.',
            stockCount: 5,
          ),
        );

        return _buildDetailsUI(context, ref, product);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
        ),
      ),
      error: (err, stack) {
        final fallbackProduct = ProductModel(
          id: id,
          name: 'Speedmaster Professional Moonwatch',
          brand: 'OMEGA',
          price: 6800.00,
          imageUrl:
              'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=600',
          description:
              'The Speedmaster Professional Moonwatch is one of the world\'s most iconic timepieces. Having been a part of all six lunar missions, the legendary chronograph is an impressive representation of the brand\'s adventurous pioneering spirit.',
          stockCount: 5,
        );
        return _buildDetailsUI(context, ref, fallbackProduct);
      },
    );
  }

  Widget _buildDetailsUI(
    BuildContext context,
    WidgetRef ref,
    ProductModel product,
  ) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Wishlist State integration
    final wishlist = ref.watch(wishlistProvider);
    final isInWish = wishlist.contains(product.id);

    // Reviews State integration
    final allReviewsMap = ref.watch(productReviewsProvider);
    final reviews =
        allReviewsMap[product.id] ??
        [
          ReviewModel(
            id: 'seed-1',
            userName: 'Charles Vane',
            rating: 5.0,
            comment:
                'Exquisite timepiece. The finish and craftsmanship are top tier.',
            date: DateTime.now().subtract(const Duration(days: 2)),
          ),
          ReviewModel(
            id: 'seed-2',
            userName: 'Eleanor Guthrie',
            rating: 4.5,
            comment: 'Stunning luxury look, runs extremely accurately.',
            date: DateTime.now().subtract(const Duration(days: 5)),
          ),
        ];

    final averageRating = reviews.isEmpty
        ? 0.0
        : reviews.fold<double>(0.0, (sum, r) => sum + r.rating) /
              reviews.length;

    // Spec values lookup
    final specs =
        _specsMap[product.id] ??
        {
          'movement': 'Automatic Mechanical',
          'diameter': '41 mm',
          'water': '100 Meters / 10 Bar',
          'reserve': '48 Hours',
        };

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1115)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isInWish ? Icons.favorite : Icons.favorite_border,
              color: const Color(0xFFD4AF37),
            ),
            onPressed: () {
              ref.read(wishlistProvider.notifier).toggleWishlist(product);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    isInWish
                        ? 'Removed ${product.name} from Wishlist'
                        : 'Added ${product.name} to Wishlist',
                  ),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: const Color(0xFFD4AF37),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Watch Hero Image Display ---
                  Center(
                    child: Container(
                      height: 280,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF181B22) : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? const Color(0xFF2A2E39)
                              : const Color(0xFFE2E8F0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Hero(
                          tag: 'watch_image_${product.id}',
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) =>
                                      Icon(
                                        Icons.watch,
                                        size: 160,
                                        color: isDark
                                            ? Colors.white24
                                            : Colors.black26,
                                      ),
                                )
                              : Icon(
                                  Icons.watch,
                                  size: 160,
                                  color: isDark
                                      ? Colors.white24
                                      : Colors.black26,
                                ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // --- Brand & Title ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.brand.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: const Color(0xFFD4AF37),
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                      Text(
                        'ID: ${product.id}',
                        style: TextStyle(
                          color: isDark
                              ? const Color(0xFFA0A5B5)
                              : const Color(0xFF64748B),
                          fontSize: 11,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Text(
                    product.name,
                    style: GoogleFonts.outfit(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFFD4AF37),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Rating Summary ---
                  Row(
                    children: [
                      Row(
                        children: List.generate(5, (index) {
                          return Icon(
                            index < averageRating.floor()
                                ? Icons.star
                                : (index < averageRating
                                      ? Icons.star_half
                                      : Icons.star_border),
                            color: const Color(0xFFD4AF37),
                            size: 18,
                          );
                        }),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${averageRating.toStringAsFixed(1)} (${reviews.length} reviews)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Key Specifications Grid (2x2 Matrix) ---
                  Text(
                    'Specifications',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 12),

                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    childAspectRatio: 2.6,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    children: [
                      _SpecCard(
                        icon: Icons.settings_outlined,
                        label: 'Movement',
                        value: specs['movement']!,
                      ),
                      _SpecCard(
                        icon: Icons.straighten,
                        label: 'Case Diameter',
                        value: specs['diameter']!,
                      ),
                      _SpecCard(
                        icon: Icons.water_drop_outlined,
                        label: 'Water Resistance',
                        value: specs['water']!,
                      ),
                      _SpecCard(
                        icon: Icons.shield_outlined,
                        label: 'Power Reserve',
                        value: specs['reserve']!,
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // --- Overview / Description ---
                  Text(
                    'Overview',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    product.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? const Color(0xFFA0A5B5)
                          : const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --- Reviews & Ratings UI Section ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Customer Reviews',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      TextButton.icon(
                        icon: const Icon(Icons.rate_review_outlined, size: 16),
                        label: const Text('Write Review'),
                        onPressed: () =>
                            _showWriteReviewDialog(context, ref, product.id),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No reviews yet. Be the first to review this timepiece!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final r = reviews[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF181B22)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isDark
                                  ? const Color(0xFF2A2E39)
                                  : const Color(0xFFE2E8F0),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    r.userName,
                                    style: GoogleFonts.outfit(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                      color: isDark
                                          ? Colors.white
                                          : const Color(0xFF0F172A),
                                    ),
                                  ),
                                  Text(
                                    '${r.date.month}/${r.date.day}/${r.date.year}',
                                    style: TextStyle(
                                      color: isDark
                                          ? const Color(0xFFA0A5B5)
                                          : const Color(0xFF64748B),
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: List.generate(5, (starIdx) {
                                  return Icon(
                                    starIdx < r.rating.floor()
                                        ? Icons.star
                                        : Icons.star_border,
                                    color: const Color(0xFFD4AF37),
                                    size: 14,
                                  );
                                }),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                r.comment,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? const Color(0xFFA0A5B5)
                                      : const Color(0xFF64748B),
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // --- Sticky Bottom Action Bar ---
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF181B22) : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? const Color(0xFF2A2E39)
                      : const Color(0xFFE2E8F0),
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -4),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Add product to cart via state provider
                        ref.read(cartProvider.notifier).addToCart(product);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Added ${product.name} to Shopping Cart',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: const Color(0xFFD4AF37),
                            action: SnackBarAction(
                              label: 'VIEW CART',
                              textColor: isDark
                                  ? const Color(0xFF0F1115)
                                  : Colors.white,
                              onPressed: () {
                                context.go('/cart');
                              },
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.shopping_bag_outlined),
                      label: Text(
                        'ADD TO CART',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD4AF37),
                        foregroundColor: isDark
                            ? const Color(0xFF0F1115)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
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

  void _showWriteReviewDialog(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) {
    final nameController = TextEditingController();
    final commentController = TextEditingController();
    double selectedRating = 5.0;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text('Submit Product Review'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Your Name'),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < selectedRating.floor()
                                ? Icons.star
                                : Icons.star_border,
                            color: const Color(0xFFD4AF37),
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              selectedRating = index + 1.0;
                            });
                          },
                        );
                      }),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: commentController,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        labelText: 'Your Review',
                        alignLabelWithHint: true,
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                  ),
                  onPressed: () {
                    final name = nameController.text.trim();
                    final comment = commentController.text.trim();
                    if (name.isNotEmpty && comment.isNotEmpty) {
                      ref
                          .read(productReviewsProvider.notifier)
                          .addReview(productId, name, selectedRating, comment);
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Thank you! Review submitted successfully.',
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFFD4AF37),
                        ),
                      );
                    }
                  },
                  child: const Text('SUBMIT'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

class _SpecCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _SpecCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B22) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE2E8F0),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: const Color(0xFFD4AF37)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    color: isDark
                        ? const Color(0xFFA0A5B5)
                        : const Color(0xFF64748B),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
