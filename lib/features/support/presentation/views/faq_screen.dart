import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

class FAQScreen extends ConsumerWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final firestore = ref.watch(firebaseFirestoreProvider);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'FAQ',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: firestore.collection('faq').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.goldAccent),
            );
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final faqs = snapshot.data?.docs ?? [];
          if (faqs.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No FAQs available',
                  style: GoogleFonts.outfit(fontSize: 16),
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            physics: const BouncingScrollPhysics(),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faqData = faqs[index].data() as Map<String, dynamic>;
              return _FAQTile(
                question: faqData['question'] ?? 'Question',
                answer: faqData['answer'] ?? 'Answer',
                isDark: isDark,
              );
            },
          );
        },
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;
  final bool isDark;

  const _FAQTile({
    required this.question,
    required this.answer,
    this.isDark = false,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            ExpansionTile(
              title: Text(
                question,
                style: GoogleFonts.outfit(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppColors.lightTextPrimary,
                ),
              ),
              iconColor: AppColors.goldAccent,
              collapsedIconColor: isDark ? Colors.white54 : Colors.black45,
              shape: const Border(),
              collapsedShape: const Border(),
              children: [
                const Divider(color: AppColors.goldAccent, height: 1),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    answer,
                    style: GoogleFonts.inter(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: 13,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
