import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({super.key});

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  void _showBIView(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _BusinessIntelligenceView(),
    );
  }

  void _showManagementView(BuildContext context, String type) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdminListView(type: type),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'ADMIN COMMAND CENTER',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: isDark ? Colors.white : AppColors.lightTextPrimary,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: AppColors.goldAccent),
            onPressed: () => ref.read(firebaseAuthProvider).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MANAGEMENT DASHBOARD',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.goldAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 1.05,
              children: [
                _AdminDashboardCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Inventory',
                  subtitle: 'Vault Control',
                  accentColor: Colors.blueAccent,
                  onTap: () => _showManagementView(context, 'products'),
                ),
                _AdminDashboardCard(
                  icon: Icons.receipt_long_rounded,
                  title: 'Orders',
                  subtitle: 'Fulfillment',
                  accentColor: Colors.orangeAccent,
                  onTap: () => _showManagementView(context, 'orders'),
                ),
                _AdminDashboardCard(
                  icon: Icons.support_agent_rounded,
                  title: 'Support',
                  subtitle: 'Concierge',
                  accentColor: AppColors.success,
                  onTap: () => _showManagementView(context, 'tickets'),
                ),
                _AdminDashboardCard(
                  icon: Icons.analytics_outlined,
                  title: 'Intelligence',
                  subtitle: 'Metrics',
                  accentColor: Colors.purpleAccent,
                  onTap: () => _showBIView(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'OPERATIONAL STATUS',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: AppColors.goldAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            const _SystemStatusRow(label: 'Global Database', status: 'SYNCHRONIZED'),
            const _SystemStatusRow(label: 'Auth Services', status: 'ENCRYPTED'),
            const _SystemStatusRow(label: 'Payment Bridge', status: 'READY'),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _AdminDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accentColor;
  final VoidCallback onTap;

  const _AdminDashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: accentColor, size: 24),
            ),
            const Spacer(),
            Text(
              title.toUpperCase(),
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                letterSpacing: 0.5,
                color: isDark ? Colors.white : AppColors.lightTextPrimary,
              ),
            ),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                fontSize: 10,
                color: isDark ? Colors.white54 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SystemStatusRow extends StatelessWidget {
  final String label;
  final String status;

  const _SystemStatusRow({required this.label, required this.status});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: const BoxDecoration(color: AppColors.success, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Text(
                status,
                style: GoogleFonts.outfit(
                  color: AppColors.success,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AdminListView extends ConsumerWidget {
  final String type;
  const _AdminListView({required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestore = ref.watch(firebaseFirestoreProvider);

    String title = '';
    Query query;

    switch (type) {
      case 'products':
        title = 'Inventory Management';
        query = firestore.collection('products');
        break;
      case 'orders':
        title = 'System Orders';
        query = firestore.collectionGroup('orders');
        break;
      case 'tickets':
        title = 'Support Concierge';
        query = firestore.collection('support_tickets').orderBy('timestamp', descending: true);
        break;
      default:
        query = firestore.collection('products');
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title.toUpperCase(), style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: AppColors.goldAccent)),
                IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.goldAccent), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator(color: AppColors.goldAccent));

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return Center(child: Text('No records found in this category', style: GoogleFonts.outfit(color: AppColors.neutral)));

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  physics: const BouncingScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final doc = docs[index];
                    final data = doc.data() as Map<String, dynamic>;
                    return _AdminListItem(doc: doc, data: data, type: type);
                  },
                );
              },
            ),
          ),
          if (type == 'products')
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _showProductDialog(context, ref),
                  icon: const Icon(Icons.add_rounded),
                  label: const Text('ADD NEW MASTERPIECE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.goldAccent,
                    foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _showProductDialog(BuildContext context, WidgetRef ref, [DocumentSnapshot? doc]) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final data = doc?.data() as Map<String, dynamic>?;
    
    final nameController = TextEditingController(text: data?['name']);
    final brandController = TextEditingController(text: data?['brand']);
    final priceController = TextEditingController(text: data?['price']?.toString());
    final stockController = TextEditingController(text: (data?['stock'] ?? data?['stockCount'])?.toString());
    final imageController = TextEditingController(text: data?['imageUrl']);
    final descController = TextEditingController(text: data?['description']);
    final categoryController = TextEditingController(text: data?['category'] ?? (data?['tags'] as List?)?.first);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24), side: BorderSide(color: AppColors.goldAccent.withValues(alpha: 0.3))),
        title: Text(
          doc == null ? 'CREATE MASTERPIECE' : 'EDIT TIMEPIECE',
          style: GoogleFonts.outfit(fontWeight: FontWeight.bold, letterSpacing: 1.2, color: AppColors.goldAccent),
        ),
        content: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 8),
                _AdminTextField(controller: nameController, label: 'Product Name', icon: Icons.watch_rounded),
                _AdminTextField(controller: brandController, label: 'Brand Name', icon: Icons.business_rounded),
                _AdminTextField(controller: priceController, label: 'Retail Price', icon: Icons.attach_money_rounded, keyboardType: TextInputType.number),
                _AdminTextField(controller: stockController, label: 'Vault Stock', icon: Icons.inventory_2_rounded, keyboardType: TextInputType.number),
                _AdminTextField(controller: categoryController, label: 'Primary Category', icon: Icons.category_rounded),
                _AdminTextField(controller: imageController, label: 'High-Res Image URL', icon: Icons.image_rounded),
                _AdminTextField(controller: descController, label: 'Heritage & Details', icon: Icons.description_rounded, maxLines: 3),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('DISCARD', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.goldAccent, foregroundColor: isDark ? AppColors.darkBg : Colors.white),
            onPressed: () async {
              final product = {
                'name': nameController.text,
                'brand': brandController.text,
                'price': double.tryParse(priceController.text) ?? 0.0,
                'stock': int.tryParse(stockController.text) ?? 0,
                'imageUrl': imageController.text,
                'description': descController.text,
                'tags': [categoryController.text.toLowerCase()],
                'isAvailable': true,
              };

              try {
                if (doc == null) {
                  await ref.read(firebaseFirestoreProvider).collection('products').add(product);
                } else {
                  await doc.reference.update(product);
                }
                if (context.mounted) {
                  Navigator.pop(context);
                  _showSuccessSnackBar(context, doc == null ? 'Timepiece added to vault' : 'Timepiece records updated');
                }
              } catch (e) {
                if (context.mounted) _showErrorSnackBar(context, 'Operation failed: $e');
              }
            },
            child: const Text('SAVE TO VAULT'),
          ),
        ],
      ),
    );
  }
}

class _AdminTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final int maxLines;

  const _AdminTextField({required this.controller, required this.label, required this.icon, this.keyboardType, this.maxLines = 1});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : Colors.black, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: AppColors.goldAccent, fontSize: 12),
          prefixIcon: Icon(icon, color: AppColors.goldAccent, size: 20),
          filled: true,
          fillColor: isDark ? AppColors.darkBg : Colors.grey[50],
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppColors.goldAccent, width: 1.5)),
        ),
      ),
    );
  }
}

class _AdminListItem extends ConsumerWidget {
  final DocumentSnapshot doc;
  final Map<String, dynamic> data;
  final String type;

  const _AdminListItem({required this.doc, required this.data, required this.type});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (type == 'products') ...[
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(color: AppColors.goldAccent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(14)),
                  child: const Icon(Icons.watch_rounded, color: AppColors.goldAccent, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(data['name'] ?? 'Unknown Timepiece', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 15)),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text('\$${data['price']}', style: const TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold, fontSize: 13)),
                          const SizedBox(width: 12),
                          Text('Stock: ${data['stock'] ?? data['stockCount'] ?? 0}', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 12)),
                        ],
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note_rounded, color: Colors.blueAccent, size: 26),
                      onPressed: () => _showEditProduct(context, ref),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_sweep_rounded, color: AppColors.error, size: 26),
                      onPressed: () => _deleteProduct(context, ref),
                    ),
                  ],
                ),
              ],
            ),
          ] else if (type == 'orders') ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ORDER #${data['id']?.toString().toUpperCase() ?? doc.id.substring(0, 8)}', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 0.5)),
                      const SizedBox(height: 4),
                      Text('Amount: \$${data['totalAmount']}', style: const TextStyle(color: AppColors.goldAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBg : Colors.grey[100],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.2)),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: data['status'] ?? 'pending',
                      dropdownColor: isDark ? AppColors.darkSurface : Colors.white,
                      style: GoogleFonts.outfit(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.goldAccent),
                      items: ['pending', 'processing', 'shipped', 'delivered', 'cancelled']
                          .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                          .toList(),
                      onChanged: (val) async {
                        if (val != null) {
                          await doc.reference.update({'status': val});
                          if (context.mounted) _showSuccessSnackBar(context, 'Order status updated to ${val.toUpperCase()}');
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),
          ] else ...[
            Row(
              children: [
                const Icon(Icons.support_agent_rounded, color: AppColors.goldAccent, size: 20),
                const SizedBox(width: 12),
                Expanded(child: Text(data['subject'] ?? 'No Subject', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 14))),
              ],
            ),
            const SizedBox(height: 8),
            Text('From: ${data['userEmail']}', style: TextStyle(fontSize: 11, color: isDark ? Colors.white54 : Colors.black54)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              width: double.infinity,
              decoration: BoxDecoration(color: isDark ? AppColors.darkBg : Colors.grey[50], borderRadius: BorderRadius.circular(12)),
              child: Text(data['message'] ?? '', style: const TextStyle(fontSize: 12, height: 1.4)),
            ),
          ],
        ],
      ),
    );
  }

  void _showEditProduct(BuildContext context, WidgetRef ref) {
    const _AdminListView(type: 'products')._showProductDialog(context, ref, doc);
  }

  void _deleteProduct(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('REMOVE TIMEPIECE?', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
        content: const Text('This action will permanently remove this item from the boutique vault.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text('CANCEL', style: TextStyle(color: isDark ? Colors.white54 : Colors.black54))),
          TextButton(
            onPressed: () async {
              await doc.reference.delete();
              if (context.mounted) {
                Navigator.pop(context);
                _showSuccessSnackBar(context, 'Timepiece removed from vault');
              }
            },
            child: const Text('DELETE', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

void _showSuccessSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Text(message, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white)),
        ],
      ),
      backgroundColor: AppColors.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

void _showErrorSnackBar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          const Icon(Icons.error_outline_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(message, style: GoogleFonts.outfit(fontWeight: FontWeight.bold, color: Colors.white))),
        ],
      ),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}

class _BusinessIntelligenceView extends ConsumerWidget {
  const _BusinessIntelligenceView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final firestore = ref.watch(firebaseFirestoreProvider);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkBg : AppColors.lightBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(color: AppColors.goldAccent.withValues(alpha: 0.3), width: 1.5),
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2))),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('BUSINESS INTEL', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldAccent, letterSpacing: 1.5)),
                IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.goldAccent), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _calculateMetrics(firestore),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator(color: AppColors.goldAccent));
                if (!snapshot.hasData) return const Center(child: Text('Data error'));
                final metrics = snapshot.data!;

                return ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  physics: const BouncingScrollPhysics(),
                  children: [
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.3,
                      children: [
                        _BIMetricTile(label: 'Total Revenue', value: '\$${metrics['revenue'].toStringAsFixed(0)}', icon: Icons.monetization_on_rounded, color: Colors.green),
                        _BIMetricTile(label: 'Total Orders', value: '${metrics['orders']}', icon: Icons.shopping_bag_rounded, color: Colors.orangeAccent),
                        _BIMetricTile(label: 'Vault Value', value: '\$${metrics['inventoryValue'].toStringAsFixed(0)}', icon: Icons.account_balance_rounded, color: Colors.blueAccent),
                        _BIMetricTile(label: 'Unit Stock', value: '${metrics['totalStock']}', icon: Icons.warehouse_rounded, color: Colors.purpleAccent),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Text('LOW STOCK WARNINGS', style: GoogleFonts.outfit(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.error, letterSpacing: 1.0)),
                    const SizedBox(height: 16),
                    if (metrics['lowStock'].isEmpty)
                      Center(child: Text('All masterpieces are well-stocked.', style: TextStyle(color: AppColors.success, fontSize: 12, fontStyle: FontStyle.italic)))
                    else
                      ...metrics['lowStock'].map((name) => Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppColors.error.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.error.withValues(alpha: 0.2))),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber_rounded, color: AppColors.error, size: 20),
                            const SizedBox(width: 12),
                            Expanded(child: Text(name, style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.error))),
                          ],
                        ),
                      )),
                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<Map<String, dynamic>> _calculateMetrics(FirebaseFirestore firestore) async {
    final orders = await firestore.collectionGroup('orders').get();
    final products = await firestore.collection('products').get();

    double revenue = 0;
    for (var doc in orders.docs) {
      revenue += (doc.data()['totalAmount'] as num?)?.toDouble() ?? 0.0;
    }

    double inventoryValue = 0;
    int totalStock = 0;
    List<String> lowStock = [];

    for (var doc in products.docs) {
      final data = doc.data();
      final price = (data['price'] as num?)?.toDouble() ?? 0.0;
      final stock = (data['stock'] ?? data['stockCount'] ?? 0) as int;
      
      inventoryValue += (price * stock);
      totalStock += stock;
      if (stock < 5) {
        lowStock.add('${data['name']} ($stock left)');
      }
    }

    return {
      'revenue': revenue,
      'orders': orders.docs.length,
      'inventoryValue': inventoryValue,
      'totalStock': totalStock,
      'lowStock': lowStock,
    };
  }
}

class _BIMetricTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _BIMetricTile({required this.label, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 16),
              const SizedBox(width: 8),
              Expanded(child: Text(label, style: GoogleFonts.inter(fontSize: 10, fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.goldAccent)),
        ],
      ),
    );
  }
}
