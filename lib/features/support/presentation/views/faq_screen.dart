import 'package:flutter/material.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBg
          : AppColors.lightBg,
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
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        physics: const BouncingScrollPhysics(),
        children: const [
          _FAQTile(
            question: 'Are the watches authentic?',
            answer:
                'Yes, every timepiece in our collection is 100% authentic and comes with a certificate of authenticity and the original manufacturer warranty.',
          ),
          _FAQTile(
            question: 'How long does shipping take?',
            answer:
                'We offer worldwide express shipping. Domestic orders typically arrive within 2-3 business days, while international orders take 5-7 business days.',
          ),
          _FAQTile(
            question: 'What is your return policy?',
            answer:
                'We offer a 14-day return policy for unworn watches in their original condition and packaging. Please contact support to initiate a return.',
          ),
          _FAQTile(
            question: 'Do you offer servicing?',
            answer:
                'Yes, we have a network of certified watchmakers who can service your timepiece. Contact us for a quote and shipping instructions.',
          ),
        ],
      ),
    );
  }
}

class _FAQTile extends StatelessWidget {
  final String question;
  final String answer;

  const _FAQTile({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
