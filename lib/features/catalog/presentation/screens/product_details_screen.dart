import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:app_watchhub/core/router/app_router.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import '../../domain/models/product_model.dart';
import '../../data/repositories/review_repository.dart';
import '../providers/catalog_providers.dart';
import '../providers/wishlist_provider.dart';
import '../providers/reviews_provider.dart';
import 'package:app_watchhub/features/cart/presentation/providers/cart_provider.dart';

class ProductDetailsScreen extends ConsumerStatefulWidget {
  final String id;

  const ProductDetailsScreen({super.key, required this.id});

  @override
  ConsumerState<ProductDetailsScreen> createState() =>
      _ProductDetailsScreenState();
}

class _ProductDetailsScreenState extends ConsumerState<ProductDetailsScreen> {
  String _reviewSortBy = 'Date';

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

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      useSafeArea: false,
      builder: (context) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          iconTheme: const IconThemeData(color: Colors.white),
          elevation: 0,
        ),
        body: Center(
          child: InteractiveViewer(
            minScale: 0.5,
            maxScale: 5.0,
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    fit: BoxFit.contain,
                  )
                : const Icon(
                    Icons.watch,
                    size: 200,
                    color: Colors.white24,
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(watchProductsProvider);

    return productsAsync.when(
      data: (products) {
        final product = products.firstWhere(
          (p) => p.id == widget.id,
          orElse: () => ProductModel(
            id: widget.id,
            name: 'Speedmaster Professional Moonwatch',
            brand: 'OMEGA',
            price: 6800.00,
            imageUrl:
                'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=600',
            description:
                'The Speedmaster Professional Moonwatch is one of the world\'s most iconic timepieces. Having been a part of all six lunar missions, the legendary chronograph is an impressive representation of the brand\'s adventurous pioneering spirit.',
            stock: 5,
          ),
        );

        return _buildDetailsUI(context, ref, product);
      },
      loading: () => const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
      ),
      error: (err, stack) {
        final fallbackProduct = ProductModel(
          id: widget.id,
          name: 'Speedmaster Professional Moonwatch',
          brand: 'OMEGA',
          price: 6800.00,
          imageUrl:
              'https://images.unsplash.com/photo-1524592094714-0f0654e20314?auto=format&fit=crop&q=80&w=600',
          description:
              'The Speedmaster Professional Moonwatch is one of the world\'s most iconic timepieces. Having been a part of all six lunar missions, the legendary chronograph is an impressive representation of the brand\'s adventurous pioneering spirit.',
          stock: 5,
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

    // Reviews from Firestore
    final reviewsAsync = ref.watch(productReviewsProvider(product.id));
    final reviews = reviewsAsync.value ?? [];
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
      backgroundColor: AppColors.scaffoldBackground(theme.brightness),
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
              color: AppColors.goldAccent,
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
                  backgroundColor: AppColors.goldAccent,
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
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Watch Hero Image Display ---
                  Center(
                    child: Container(
                      height: 280,
                      margin: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: GestureDetector(
                        onTap: () => _showFullScreenImage(context, product.imageUrl),
                        child: InteractiveViewer(
                          boundaryMargin: const EdgeInsets.all(20),
                          minScale: 0.5,
                          maxScale: 3.0,
                          child: Center(
                            child: Hero(
                              tag: 'watch_image_${product.id}',
                              child: product.imageUrl.isNotEmpty
                                  ? Image.network(
                                      product.imageUrl,
                                      height: 200,
                                      fit: BoxFit.contain,
                                      errorBuilder:
                                          (context, error, stackTrace) => Icon(
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
                          color: AppColors.goldAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          product.brand.toUpperCase(),
                          style: GoogleFonts.outfit(
                            color: AppColors.goldAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            letterSpacing: 1.5,
                          ),
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
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                      height: 1.2,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.goldAccent,
                    ),
                  ),

                  const SizedBox(height: 8),

                  if (product.stock > 0)
                    Text(
                      'In Stock: ${product.stock}',
                      style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    )
                  else
                    const Text(
                      'OUT OF STOCK',
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
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
                            color: AppColors.goldAccent,
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
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
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
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  Text(
                    product.description,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
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
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      Row(
                        children: [
                          PopupMenuButton<String>(
                            onSelected: (value) {
                              setState(() {
                                _reviewSortBy = value;
                              });
                            },
                            itemBuilder: (BuildContext context) => [
                              const PopupMenuItem(
                                value: 'Date',
                                child: Text('By Date'),
                              ),
                              const PopupMenuItem(
                                value: 'Rating',
                                child: Text('By Rating'),
                              ),
                            ],
                            child: Chip(
                              label: Text(
                                'Sort: $_reviewSortBy',
                                style: const TextStyle(fontSize: 11),
                              ),
                              backgroundColor: AppColors.goldAccent.withValues(
                                alpha: 0.2,
                              ),
                              labelStyle: const TextStyle(
                                color: AppColors.goldAccent,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          TextButton.icon(
                            onPressed: () =>
                                _onWriteReviewPressed(context, ref, product.id),
                            icon: const Icon(Icons.rate_review_outlined),
                            label: const Text('Write Review'),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.goldAccent,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (reviewsAsync.isLoading && reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    )
                  else if (reviewsAsync.hasError)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Unable to load reviews right now.',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.secondaryText(theme.brightness),
                        ),
                      ),
                    )
                  else if (reviews.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No reviews yet. Be the first to review this timepiece!',
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          color: AppColors.neutral,
                        ),
                      ),
                    )
                  else
                    Builder(
                      builder: (context) {
                        var sortedReviews = List.from(reviews);
                        if (_reviewSortBy == 'Rating') {
                          sortedReviews.sort(
                            (a, b) => b.rating.compareTo(a.rating),
                          );
                        } else {
                          sortedReviews.sort(
                            (a, b) => b.date.compareTo(a.date),
                          );
                        }

                        return ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: sortedReviews.length,
                          itemBuilder: (context, index) {
                            final r = sortedReviews[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? AppColors.darkSurface
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
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
                                              : AppColors.lightTextPrimary,
                                        ),
                                      ),
                                      Text(
                                        '${r.date.month}/${r.date.day}/${r.date.year}',
                                        style: TextStyle(
                                          color: isDark
                                              ? AppColors.darkTextSecondary
                                              : AppColors.lightTextSecondary,
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
                                        color: AppColors.goldAccent,
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
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                      height: 1.4,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
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
              color: isDark ? AppColors.darkSurface : Colors.white,
              border: Border(
                top: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
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
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: product.stock <= 0
                                ? null
                                : () {
                                    final error = ref
                                        .read(cartProvider.notifier)
                                        .addToCart(product);
                                    
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

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Added ${product.name} to Shopping Cart',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                        backgroundColor: AppColors.goldAccent,
                                        action: SnackBarAction(
                                          label: 'VIEW CART',
                                          textColor: isDark
                                              ? AppColors.darkBg
                                              : Colors.white,
                                          onPressed: () {
                                            context.go(AppRoutes.cart);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(Icons.shopping_bag_outlined),
                            label: Text(
                              product.stock <= 0 ? 'OUT OF STOCK' : 'ADD TO CART',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: product.stock <= 0
                                  ? Colors.grey
                                  : AppColors.goldAccent,
                              foregroundColor: isDark
                                  ? AppColors.darkBg
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: product.stock <= 0
                                ? null
                                : () {
                                    final error = ref
                                        .read(cartProvider.notifier)
                                        .addToCart(product);
                                    
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
                                    context.go(AppRoutes.checkout);
                                  },
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size(double.infinity, 50),
                              backgroundColor: product.stock <= 0
                                  ? Colors.grey.withAlpha(50)
                                  : (isDark
                                      ? AppColors.darkSurfaceCard
                                      : Theme.of(context).colorScheme.primary),
                              foregroundColor: isDark
                                  ? Colors.white
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: Text(
                              'BUY NOW',
                              style: GoogleFonts.outfit(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ],
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
    WidgetRef ref, {
    required String productId,
    required String userId,
    required String userName,
  }) {
    final nameController = TextEditingController(text: userName);
    final commentController = TextEditingController();
    double selectedRating = 5.0;
    var isSubmitting = false;

    showDialog<void>(
      context: context,
      builder: (dialogContext) {
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
                            color: AppColors.goldAccent,
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
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(color: AppColors.neutral),
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldAccent,
                  ),
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final name = nameController.text.trim();
                          final comment = commentController.text.trim();
                          if (name.isEmpty || comment.isEmpty) {
                            return;
                          }

                          setState(() => isSubmitting = true);

                          try {
                            await ref
                                .read(reviewRepositoryProvider)
                                .submitReview(
                                  productId: productId,
                                  userId: userId,
                                  userName: name,
                                  rating: selectedRating,
                                  comment: comment,
                                );
                            if (dialogContext.mounted) {
                              Navigator.of(dialogContext).pop();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Thank you! Review submitted successfully.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.goldAccent,
                                ),
                              );
                            }
                          } catch (_) {
                            setState(() => isSubmitting = false);
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Failed to submit review. Please try again.',
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  backgroundColor: AppColors.error,
                                ),
                              );
                            }
                          }
                        },
                  child: Text(isSubmitting ? 'SUBMITTING...' : 'SUBMIT'),
                ),
              ],
            );
          },
        );
      },
    ).whenComplete(() {
      nameController.dispose();
      commentController.dispose();
    });
  }

  void _onWriteReviewPressed(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) {
    final user = ref.read(authStateProvider).value;
    if (user == null) {
      final redirect = Uri.encodeComponent(
        AppRoutes.productDetailsPath(productId),
      );
      context.go('${AppRoutes.login}?redirect=$redirect');
      return;
    }

    final displayName = user.displayName?.trim();
    final userName = (displayName != null && displayName.isNotEmpty)
        ? displayName
        : user.email?.split('@').first ?? 'Collector';

    _showWriteReviewDialog(
      context,
      ref,
      productId: productId,
      userId: user.uid,
      userName: userName,
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
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.goldAccent),
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
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  value,
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
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
