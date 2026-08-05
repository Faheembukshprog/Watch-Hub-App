import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:app_watchhub/core/router/app_router.dart';
import '../providers/catalog_providers.dart';
import '../providers/wishlist_provider.dart';
import '../../domain/models/product_model.dart';

class CatalogScreen extends ConsumerStatefulWidget {
  const CatalogScreen({super.key});

  @override
  ConsumerState<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends ConsumerState<CatalogScreen> {
  String _searchQuery = '';
  String _selectedBrand = 'All';
  double _minPrice = 0;
  double _maxPrice = 20000;
  String _selectedType = 'All';
  String _sortBy = 'Default';
  final _searchController = TextEditingController();
  late final PageController _bannerPageController;

  final Map<String, double> _popularityScores = {
    'rolex_submariner': 4.8,
    'omega_speedmaster': 4.6,
    'patek_nautilus': 4.9,
    'ap_royal_oak': 4.7,
    'cartier_santos': 4.4,
  };

  final List<String> _brands = [
    'All',
    'Rolex',
    'OMEGA',
    'Patek Philippe',
    'Audemars Piguet',
    'Cartier',
  ];

  final List<String> _productTypes = [
    'All',
    'Sports',
    'Luxury',
    'Classic',
    'Dress',
  ];

  final List<String> _sortOptions = [
    'Default',
    'Price Low-High',
    'Price High-Low',
    'Popularity',
  ];

  final List<Map<String, String>> _promoBanners = [
    {
      'title': 'The Royal Oak Collection',
      'subtitle': 'An avant-garde masterpiece of horology',
      'image':
          'https://images.unsplash.com/photo-1629581678313-36cf745a9af9?auto=format&fit=crop&q=80&w=800',
    },
    {
      'title': 'Deep Dive Masterpieces',
      'subtitle': 'Engineered to withstand the depths of the ocean',
      'image':
          'https://images.unsplash.com/photo-1547996160-81dfa63595aa?auto=format&fit=crop&q=80&w=800',
    },
    {
      'title': 'Heritage & Complications',
      'subtitle': 'Timeless classic timepieces for true collectors',
      'image':
          'https://images.unsplash.com/photo-1622434641406-a158123450f9?auto=format&fit=crop&q=80&w=800',
    },
  ];

  @override
  void initState() {
    super.initState();
    _bannerPageController = PageController(viewportFraction: 0.92);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _bannerPageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalogAsync = ref.watch(watchProductsProvider);
    final authUser = ref.watch(authStateProvider).value;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: catalogAsync.when(
          data: (products) {
            // Apply filtering logic locally for high-fidelity demonstration
            var filteredProducts = products.where((product) {
              final matchesBrand =
                  _selectedBrand == 'All' ||
                  product.brand.toLowerCase() == _selectedBrand.toLowerCase();
              final matchesQuery =
                  product.name.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ||
                  product.brand.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  );
              final matchesPrice =
                  product.price >= _minPrice && product.price <= _maxPrice;
              final matchesType =
                  _selectedType == 'All' ||
                  product.tags.contains(_selectedType.toLowerCase());
              return matchesBrand &&
                  matchesQuery &&
                  matchesPrice &&
                  matchesType;
            }).toList();

            // Apply sorting
            switch (_sortBy) {
              case 'Price Low-High':
                filteredProducts.sort((a, b) => a.price.compareTo(b.price));
                break;
              case 'Price High-Low':
                filteredProducts.sort((a, b) => b.price.compareTo(a.price));
                break;
              case 'Popularity':
                filteredProducts.sort((a, b) {
                  final aScore = _popularityScores[a.id] ?? 0.0;
                  final bScore = _popularityScores[b.id] ?? 0.0;
                  return bScore.compareTo(aScore);
                });
                break;
              case 'Default':
              default:
                // Keep default order
                break;
            }

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- Premium AppBar ---
                SliverAppBar(
                  pinned: true,
                  floating: true,
                  expandedHeight: 60,
                  backgroundColor: theme.scaffoldBackgroundColor,
                  title: Text(
                    'WATCHHUB',
                    style: GoogleFonts.outfit(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4.0,
                      color: isDark ? Colors.white : AppColors.lightTextPrimary,
                    ),
                  ),
                  actions: [
                    if (authUser != null)
                      IconButton(
                        icon: const Icon(Icons.logout_rounded),
                        tooltip: 'Sign Out',
                        onPressed: () =>
                            ref.read(firebaseAuthProvider).signOut(),
                      )
                    else
                      IconButton(
                        icon: const Icon(Icons.login_rounded),
                        tooltip: 'Sign In',
                        onPressed: () => context.go(AppRoutes.login),
                      ),
                  ],
                ),

                // --- Hero Promo Banner Carousel ---
                SliverToBoxAdapter(
                  child: Container(
                    height: 180,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: PageView.builder(
                      itemCount: _promoBanners.length,
                      controller: _bannerPageController,
                      itemBuilder: (context, index) {
                        final banner = _promoBanners[index];
                        return Container(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(16),
                            image: DecorationImage(
                              image: CachedNetworkImageProvider(
                                banner['image']!,
                              ),
                              fit: BoxFit.cover,
                              colorFilter: ColorFilter.mode(
                                Colors.black.withValues(alpha: 0.45),
                                BlendMode.darken,
                              ),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  banner['title']!.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  banner['subtitle']!,
                                  style: GoogleFonts.inter(
                                    fontSize: 12,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),

                // --- Sleek Glass Search Bar ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.darkSurface : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: (val) {
                          setState(() {
                            _searchQuery = val;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Search collection, complication, brand...',
                          prefixIcon: Icon(
                            Icons.search_rounded,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          suffixIcon: _searchQuery.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() {
                                      _searchQuery = '';
                                    });
                                  },
                                )
                              : null,
                          filled: false,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                        ),
                      ),
                    ),
                  ),
                ),

                // --- Luxury Brand Filter Chips ---
                SliverToBoxAdapter(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Row(
                      children: _brands.map((brand) {
                        final isSelected = _selectedBrand == brand;
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ChoiceChip(
                            label: Text(
                              brand.toUpperCase(),
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.8,
                                color: isSelected
                                    ? (isDark ? AppColors.darkBg : Colors.white)
                                    : (isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary),
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              if (selected) {
                                setState(() {
                                  _selectedBrand = brand;
                                });
                              }
                            },
                            selectedColor: AppColors.goldAccent,
                            backgroundColor: isDark
                                ? AppColors.darkSurface
                                : Colors.white,
                            side: BorderSide(
                              color: isSelected
                                  ? AppColors.goldAccent
                                  : (isDark
                                        ? AppColors.darkBorder
                                        : AppColors.lightBorder),
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            showCheckmark: false,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),

                // --- Price Range Filter ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Price Range: \$${_minPrice.toStringAsFixed(0)} - \$${_maxPrice.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        RangeSlider(
                          values: RangeValues(_minPrice, _maxPrice),
                          min: 0,
                          max: 20000,
                          divisions: 20,
                          labels: RangeLabels(
                            _minPrice.toStringAsFixed(0),
                            _maxPrice.toStringAsFixed(0),
                          ),
                          onChanged: (RangeValues values) {
                            setState(() {
                              _minPrice = values.start;
                              _maxPrice = values.end;
                            });
                          },
                          activeColor: AppColors.goldAccent,
                          inactiveColor: isDark
                              ? AppColors.darkBorder
                              : AppColors.lightBorder,
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Product Type & Sort Filters ---
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: DropdownButton<String>(
                            value: _selectedType,
                            isExpanded: true,
                            underline: Container(
                              height: 1,
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            items: _productTypes.map((type) {
                              return DropdownMenuItem(
                                value: type,
                                child: Text(
                                  type,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _selectedType = value;
                                });
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButton<String>(
                            value: _sortBy,
                            isExpanded: true,
                            underline: Container(
                              height: 1,
                              color: isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder,
                            ),
                            items: _sortOptions.map((sort) {
                              return DropdownMenuItem(
                                value: sort,
                                child: Text(
                                  sort,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _sortBy = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // --- Product Catalog Grid ---
                if (filteredProducts.isEmpty)
                  const SliverFillRemaining(
                    child: Center(
                      child: Text(
                        'No matching timepieces found in the vault.',
                        style: TextStyle(
                          color: AppColors.neutral,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.68,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 14,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final watch = filteredProducts[index];
                        return _ProductCard(watch: watch);
                      }, childCount: filteredProducts.length),
                    ),
                  ),
              ],
            );
          },
          loading: () => const _CatalogShimmerLoader(),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Text(
                'Failed to sync vault inventory: $error',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends ConsumerWidget {
  final ProductModel watch;
  const _ProductCard({required this.watch});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wishlist = ref.watch(wishlistProvider);
    final isInWish = wishlist.contains(watch.id);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => context.go('/product/${watch.id}'),
      child: Card(
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
            // Image Visual Display Layer with Wishlist Overlay
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
                      child: Hero(
                        tag: 'watch_image_${watch.id}',
                        child: watch.imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: watch.imageUrl,
                                fit: BoxFit.contain,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                      baseColor: isDark
                                          ? Colors.grey[800]!
                                          : Colors.grey[300]!,
                                      highlightColor: isDark
                                          ? Colors.grey[700]!
                                          : Colors.grey[100]!,
                                      child: Container(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surface,
                                      ),
                                    ),
                                errorWidget: (context, url, error) => Icon(
                                  Icons.watch_rounded,
                                  size: 48,
                                  color: isDark
                                      ? Colors.white30
                                      : Colors.black26,
                                ),
                              )
                            : Icon(
                                Icons.watch_rounded,
                                size: 48,
                                color: isDark ? Colors.white30 : Colors.black26,
                              ),
                      ),
                    ),
                  ),

                  // Wishlist Toggle Circle Button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () {
                        ref
                            .read(wishlistProvider.notifier)
                            .toggleWishlist(watch);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              isInWish
                                  ? 'Removed ${watch.name} from Wishlist'
                                  : 'Added ${watch.name} to Wishlist',
                            ),
                            behavior: SnackBarBehavior.floating,
                            backgroundColor: AppColors.goldAccent,
                            duration: const Duration(seconds: 1),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.darkSurfaceCard
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Icon(
                          isInWish ? Icons.favorite : Icons.favorite_border,
                          size: 18,
                          color: AppColors.goldAccent,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Text Meta Layer
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    watch.brand.toUpperCase(),
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldAccent,
                      letterSpacing: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    watch.name,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
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
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: AppColors.goldAccent,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogShimmerLoader extends StatelessWidget {
  const _CatalogShimmerLoader();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseCol = isDark ? Colors.grey[800]! : Colors.grey[300]!;
    final highCol = isDark ? Colors.grey[700]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseCol,
      highlightColor: highCol,
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.transparent,
            title: Container(height: 20, width: 120, color: Colors.white),
          ),
          SliverToBoxAdapter(
            child: Container(
              height: 180,
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.68,
                crossAxisSpacing: 14,
                mainAxisSpacing: 14,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                childCount: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
