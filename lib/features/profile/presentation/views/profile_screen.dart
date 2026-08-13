import 'package:flutter/material.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import 'package:app_watchhub/shared/providers/theme_provider.dart';
import '../providers/profile_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    final user = ref.watch(firebaseAuthProvider).currentUser;
    final profileAsync = ref.watch(userProfileProvider);
    final themeMode = ref.watch(themeProvider);

    final profile = profileAsync.value;
    final isAnonymous = user?.isAnonymous ?? true;
    
    final email = isAnonymous
        ? 'guest@watchhub.com'
        : (user?.email ?? 'collector@watchhub.com');
        
    final displayName = profile?['displayName'] ?? 
        (isAnonymous ? 'Guest Client' : (user?.displayName ?? 'Valued Collector'));
        
    final vipBadge = isAnonymous ? 'VISITOR' : 'COLLECTOR MEMBER';
    final shippingAddress = profile?['shippingAddress'] ?? 'No address on file';
    final phone = profile?['phone'] ?? 'No phone on file';

    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: SingleChildScrollView(
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
                  padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  child: Column(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isAnonymous
                                    ? AppColors.neutral.withValues(alpha: 0.3)
                                    : AppColors.goldAccent,
                                width: 2,
                              ),
                              boxShadow: isAnonymous
                                  ? []
                                  : [
                                      BoxShadow(
                                        color: AppColors.goldAccent.withValues(
                                          alpha: 0.2,
                                        ),
                                        blurRadius: 20,
                                        spreadRadius: 2,
                                      ),
                                    ],
                            ),
                          ),
                          CircleAvatar(
                            radius: 54,
                            backgroundColor: isDark
                                ? AppColors.darkBg
                                : AppColors.lightSurfaceMuted,
                            child: Icon(
                              isAnonymous
                                  ? Icons.person_outline_rounded
                                  : Icons.workspace_premium_outlined,
                              size: 54,
                              color: AppColors.goldAccent,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Display Name
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? Colors.white
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.edit_note_rounded),
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
                          fontSize: 14,
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // VIP Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
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
                            letterSpacing: 2.0,
                            color: AppColors.goldAccent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // --- Menu Section ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isAnonymous) ...[
                        _buildSectionLabel('COLLECTOR DOSSIER'),
                        const SizedBox(height: 16),
                        _ProfileMenuItem(
                          icon: Icons.location_on_outlined,
                          title: 'Primary Residence',
                          subtitle: shippingAddress,
                          onTap: () => _showEditProfileDialog(context, ref),
                          isDark: isDark,
                        ),
                        _ProfileMenuItem(
                          icon: Icons.phone_outlined,
                          title: 'Verified Contact',
                          subtitle: phone,
                          onTap: () => _showEditProfileDialog(context, ref),
                          isDark: isDark,
                        ),
                        const SizedBox(height: 32),
                      ],

                      _buildSectionLabel('CURATED SERVICES'),
                      const SizedBox(height: 16),

                      _ProfileMenuItem(
                        icon: Icons.favorite_border_rounded,
                        title: 'Private Vault (Wishlist)',
                        subtitle: 'View your hand-picked luxury collection',
                        onTap: () => context.push('/wishlist'),
                        isDark: isDark,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.history_edu_rounded,
                        title: 'Acquisition History',
                        subtitle: 'Trace your past boutique transactions',
                        onTap: () => context.go('/orders'),
                        isDark: isDark,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.support_agent_rounded,
                        title: 'Concierge Assistance',
                        subtitle: 'Submit tickets for priority support',
                        onTap: () => context.push('/support'),
                        isDark: isDark,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.question_answer_outlined,
                        title: 'Knowledge Base',
                        subtitle: 'Frequently asked questions & heritage',
                        onTap: () => context.push('/faq'),
                        isDark: isDark,
                      ),
                      _ProfileMenuItem(
                        icon: Icons.feedback_outlined,
                        title: 'Boutique Feedback',
                        subtitle: 'Share your experience with our team',
                        onTap: () => _showFeedbackDialog(context, ref),
                        isDark: isDark,
                      ),

                      const SizedBox(height: 32),

                      _buildSectionLabel('PREFERENCES'),
                      const SizedBox(height: 16),

                      Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                          ),
                        ),
                        child: SwitchListTile(
                          value: isDark,
                          activeThumbColor: AppColors.goldAccent,
                          title: Text(
                            'Dark Obsidian Theme',
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: isDark ? Colors.white : AppColors.lightTextPrimary,
                            ),
                          ),
                          subtitle: const Text('Adjust appearance for low-light environments', style: TextStyle(fontSize: 12)),
                          onChanged: (val) {
                            ref.read(themeProvider.notifier).toggleTheme();
                          },
                        ),
                      ),

                      _ProfileMenuItem(
                        icon: Icons.logout_rounded,
                        title: isAnonymous ? 'Disconnect Session' : 'Secure Sign Out',
                        subtitle: 'Safely leave the WatchHub boutique',
                        onTap: () => ref.read(firebaseAuthProvider).signOut(),
                        textColor: AppColors.error,
                        iconColor: AppColors.error,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: AppColors.neutral,
        letterSpacing: 2.0,
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

    final profile = ref.read(userProfileProvider).value;

    final nameController = TextEditingController(
      text: profile?['displayName'] ?? authUser.displayName ?? '',
    );
    final phoneController = TextEditingController(
      text: profile?['phone'] ?? '',
    );
    final addressController = TextEditingController(
      text: profile?['shippingAddress'] ?? '',
    );

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Edit Collector Profile'),
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
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Contact Number',
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Primary Residence',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldAccent),
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
                      content: Text('Profile records updated.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Record update failed: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('SAVE RECORDS'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Boutique Feedback'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: feedbackController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Your Experience',
                hintText: 'Share your thoughts on our collection and service.',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldAccent),
            onPressed: () async {
              final message = feedbackController.text.trim();
              if (message.isEmpty) return;

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
                      content: Text('Feedback received. Thank you.'),
                      backgroundColor: AppColors.success,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              } catch (e) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    SnackBar(
                      content: Text('Submission failed: $e'),
                      backgroundColor: AppColors.error,
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              }
            },
            child: const Text('SEND'),
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
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.goldAccent).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor ?? AppColors.goldAccent, size: 24),
        ),
        title: Text(
          title,
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color:
                textColor ??
                (isDark ? Colors.white : AppColors.lightTextPrimary),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
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
