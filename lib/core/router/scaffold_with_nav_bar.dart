import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';

/// Navigation shell wrapper that displays a persistent navigation interface.
/// Optimized for all screen sizes with strict internal constraints to prevent height collapse.
class ScaffoldWithNavBar extends StatelessWidget {
  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  void _onItemTapped(int index) {
    // Switches to the target branch.
    // Re-selecting the current tab resets its navigation stack to the root route.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    // 1. Scaffold MUST be at the top level (NEVER wrapped in Center or ConstrainedBox)
    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,

      // 2. Root page canvas expands to 100% full browser width
      body: SafeArea(
        child: SizedBox.expand(
          child: navigationShell,
        ),
      ),

      // 3. Bottom nav bar stays pinned at the bottom
      bottomNavigationBar: Container(
        color: isDark ? AppColors.darkSurface : Colors.white,
        child: Align(
          alignment: Alignment.bottomCenter,
          heightFactor: 1.0, // Ensures Align doesn't take more vertical space than its child
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              selectedIndex: navigationShell.currentIndex,
              onDestinationSelected: _onItemTapped,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.storefront_outlined),
                  selectedIcon: Icon(Icons.storefront),
                  label: 'Catalog',
                ),
                NavigationDestination(
                  icon: Icon(Icons.shopping_cart_outlined),
                  selectedIcon: Icon(Icons.shopping_cart),
                  label: 'Cart',
                ),
                NavigationDestination(
                  icon: Icon(Icons.receipt_long_outlined),
                  selectedIcon: Icon(Icons.receipt_long),
                  label: 'Orders',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(Icons.person),
                  label: 'Profile',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
