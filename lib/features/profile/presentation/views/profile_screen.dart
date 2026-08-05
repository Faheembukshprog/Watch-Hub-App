import 'package:flutter/material.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import 'package:app_watchhub/shared/providers/theme_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          'BOUTIQUE PROFILE',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
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
                color: isDark
                    ? AppColors.darkSurface
                    : Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(32),
                ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? AppColors.darkBorder
                        : AppColors.lightBorder,
                  ),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 16),
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
                                : AppColors.goldAccent,
                            width: 2,
                          ),
                          boxShadow: isAnonymous
                              ? []
                              : [
                                  BoxShadow(
                                    color: AppColors.goldAccent.withValues(
                                      alpha: 0.25,
                                    ),
                                    blurRadius: 16,
                                    spreadRadius: 2,
                                  ),
                                ],
                        ),
                      ),
                      CircleAvatar(
                        radius: 48,
                        backgroundColor: isDark
                            ? AppColors.darkBg
                            : AppColors.lightSurfaceMuted,
                        child: Icon(
                          isAnonymous
                              ? Icons.person_outline_rounded
                              : Icons.workspace_premium_outlined,
                          size: 48,
                          color: AppColors.goldAccent,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Display Name
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Text(
                          displayName,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.outfit(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? Colors.white
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit_rounded),
                        color: AppColors.goldAccent,
                        tooltip: 'Edit Profile',
                        onPressed: () => _showEditProfileDialog(context, ref),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // User Email
                  Text(
                    email,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
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
                      color: AppColors.goldAccent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.goldAccent, width: 1),
                    ),
                    child: Text(
                      vipBadge,
                      style: GoogleFonts.outfit(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: AppColors.goldAccent,
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
                      color: AppColors.neutral,
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
                  _ProfileMenuItem(
                    icon: Icons.feedback_outlined,
                    title: 'Send Feedback',
                    subtitle: 'Share your experience with the boutique',
                    onTap: () => _showFeedbackDialog(context, ref),
                    isDark: isDark,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'SETTINGS & PREFERENCES',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: AppColors.neutral,
                      letterSpacing: 1.5,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // High-Contrast Theme Switcher
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.darkSurface
                          : Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder,
                      ),
                    ),
                    child: SwitchListTile(
                      value: isDark,
                      activeThumbColor: AppColors.goldAccent,
                      inactiveTrackColor: isDark
                          ? Colors.black26
                          : AppColors.lightControlTrack,
                      title: Text(
                        'Dark Obsidian Theme',
                        style: GoogleFonts.outfit(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: isDark
                              ? Colors.white
                              : AppColors.lightTextPrimary,
                        ),
                      ),
                      subtitle: Text(
                        'Adjust screen appearance for recording',
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
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
                    textColor: AppColors.error,
                    iconColor: AppColors.error,
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

  Future<void> _showEditProfileDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final authUser = ref.read(firebaseAuthProvider).currentUser;
    if (authUser == null) {
      return;
    }

    final nameController = TextEditingController(
      text: authUser.displayName ?? '',
    );
    final phoneController = TextEditingController();
    final addressController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Edit Profile'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Shipping Address',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final displayName = nameController.text.trim();
              final phone = phoneController.text.trim();
              final address = addressController.text.trim();

              try {
                final userDoc = FirebaseFirestore.instance
                    .collection('users')
                    .doc(authUser.uid);

                await userDoc.set({
                  'displayName': displayName,
                  'phone': phone,
                  'shippingAddress': address,
                }, SetOptions(merge: true));

                if (displayName.isNotEmpty) {
                  await authUser.updateDisplayName(displayName);
                }

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Profile updated successfully.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Could not save profile: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  Future<void> _showFeedbackDialog(BuildContext context, WidgetRef ref) async {
    final authUser = ref.read(firebaseAuthProvider).currentUser;
    final email = authUser?.email ?? 'guest@watchhub.com';
    final feedbackController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Send Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your message',
                hintText: 'Tell us how we can improve the boutique experience.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final message = feedbackController.text.trim();
              if (message.isEmpty) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter your feedback.'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
                return;
              }

              try {
                await FirebaseFirestore.instance.collection('feedback').add({
                  'userId': authUser?.uid ?? 'anonymous',
                  'userEmail': email,
                  'message': message,
                  'createdAt': FieldValue.serverTimestamp(),
                });
                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('Feedback sent. Thank you!'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Feedback failed: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('Send'),
          ),
        ],
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
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.goldAccent).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.goldAccent, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color:
                textColor ??
                (isDark ? Colors.white : AppColors.lightTextPrimary),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 11,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
        ),
        trailing: const Icon(
          Icons.arrow_forward_ios_rounded,
          size: 14,
          color: AppColors.neutral,
        ),
      ),
    );
  }
}
