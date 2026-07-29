import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import 'package:app_watchhub/shared/providers/theme_provider.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final themeMode = ref.watch(themeProvider);

    final isAnonymous = user?.isAnonymous ?? true;
    final email = isAnonymous
        ? 'guest@watchhub.com'
        : (user?.email ?? 'collector@watchhub.com');
    final displayName = isAnonymous
        ? 'Guest Client'
        : (user?.displayName ?? 'Valued Collector');
    final vipBadge = isAnonymous ? 'VISITOR' : 'COLLECTOR MEMBER';

    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1115)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'BOUTIQUE PROFILE',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- Premium Header Card with Glowing Badge ---
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF181B22) : Colors.white,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF2A2E39)
                        : const Color(0xFFE2E8F0),
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Outer gold glowing border for VIP Collector
                      Container(
                        width: 108,
                        height: 108,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isAnonymous
                                ? Colors.transparent
                                : const Color(0xFFD4AF37),
                            width: 2,
                          ),
                          boxShadow: isAnonymous
                              ? []
                              : [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD4AF37,
                                    ).withValues(alpha: 0.25),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: isDark
                            ? const Color(0xFF0F1115)
                            : const Color(0xFFF1F5F9),
                        child: Icon(
                          isAnonymous
                              ? Icons.person_outline_rounded
                              : Icons.workspace_premium_outlined,
                          size: 48,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Display Name
                  Text(
                    displayName,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : const Color(0xFF0F172A),
                    ),
                  ),
                  const SizedBox(height: 4),

                  // User Email
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? const Color(0xFFA0A5B5)
                          : const Color(0xFF64748B),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // VIP Badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4AF37),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      vipBadge,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // --- Menu Section ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SERVICES & SUPPORT',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  _ProfileMenuItem(
                    icon: Icons.favorite_border_rounded,
                    title: 'Saved Items (Wishlist)',
                    subtitle: 'View your curated private vault collection',
                    onTap: () => context.push('/wishlist'),
                    isDark: isDark,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.question_answer_outlined,
                    title: 'Frequently Asked Questions',
                    subtitle: 'Learn about authenticity, shipping & warranty',
                    onTap: () => context.push('/faq'),
                    isDark: isDark,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.support_agent_outlined,
                    title: 'Customer Concierge',
                    subtitle: 'Submit support tickets & message the team',
                    onTap: () => context.push('/support'),
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'SETTINGS & PREFERENCES',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // High-Contrast Theme Switcher
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF181B22) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF2A2E39)
                            : const Color(0xFFE2E8F0),
                      ),
                    ),
                    child: SwitchListTile(
                      value: isDark,
                      activeThumbColor: const Color(0xFFD4AF37),
                      inactiveTrackColor: isDark
                          ? Colors.black26
                          : Colors.grey[200],
                      title: Text(
                        'Dark Obsidian Theme',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : const Color(0xFF0F172A),
                        ),
                      ),
                      subtitle: Text(
                        'Adjust screen appearance for recording',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? const Color(0xFFA0A5B5)
                              : const Color(0xFF64748B),
                        ),
                      ),
                      onChanged: (val) {
                        ref.read(themeProvider.notifier).toggleTheme();
                      },
                    ),
                  ),

                  _ProfileMenuItem(
                    icon: Icons.history_edu_outlined,
                    title: 'My Orders',
                    subtitle: 'Track status and history of boutique purchases',
                    onTap: () => context.go('/orders'),
                    isDark: isDark,
                  ),
                  _ProfileMenuItem(
                    icon: Icons.logout_outlined,
                    title: isAnonymous ? 'Disconnect Guest Mode' : 'Sign Out',
                    subtitle: 'Securely disconnect from the WatchHub Boutique',
                    onTap: () {
                      ref.read(firebaseAuthProvider).signOut();
                    },
                    textColor: Colors.redAccent,
                    iconColor: Colors.redAccent,
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color? textColor;
  final Color? iconColor;
  final bool isDark;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.textColor,
    this.iconColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF181B22) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF2A2E39) : const Color(0xFFE2E8F0),
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? const Color(0xFFD4AF37)).withValues(
              alpha: 0.1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icon,
            color: iconColor ?? const Color(0xFFD4AF37),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color:
                textColor ?? (isDark ? Colors.white : const Color(0xFF0F172A)),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? const Color(0xFFA0A5B5) : const Color(0xFF64748B),
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: Colors.grey,
        ),
      ),
    );
  }
}
