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
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'ADMIN COMMAND CENTER',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => ref.read(firebaseAuthProvider).signOut(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MANAGEMENT DASHBOARD',
              style: GoogleFonts.outfit(
                fontSize: 12,
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
              childAspectRatio: 1.1,
              children: [
                _AdminDashboardCard(
                  icon: Icons.inventory_2_outlined,
                  title: 'Manage Inventory',
                  subtitle: 'Products & Stock',
                  color: Colors.blue,
                  onTap: () => _showManagementView(context, 'products'),
                ),
                _AdminDashboardCard(
                  icon: Icons.shopping_bag_outlined,
                  title: 'Store Orders',
                  subtitle: 'Fulfillment & Status',
                  color: Colors.orange,
                  onTap: () => _showManagementView(context, 'orders'),
                ),
                _AdminDashboardCard(
                  icon: Icons.support_agent_rounded,
                  title: 'Concierge Tickets',
                  subtitle: 'Customer Support',
                  color: Colors.green,
                  onTap: () => _showManagementView(context, 'tickets'),
                ),
                _AdminDashboardCard(
                  icon: Icons.analytics_outlined,
                  title: 'Business Intel',
                  subtitle: 'Sales & Metrics',
                  color: Colors.purple,
                  onTap: () {},
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'SYSTEM OVERVIEW',
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.goldAccent,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            _SystemStatusRow(label: 'Firebase Services', status: 'Operational'),
            _SystemStatusRow(label: 'Order Processing', status: 'Live'),
            _SystemStatusRow(label: 'Stock Alerts', status: '2 Items Low'),
          ],
        ),
      ),
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
}

class _AdminDashboardCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _AdminDashboardCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
          ),
          boxShadow: [
            if (!isDark)
              BoxShadow(
                color: Colors.black.withAlpha(10),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(30),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              title,
              style: GoogleFonts.outfit(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(
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
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              status,
              style: const TextStyle(
                color: AppColors.success,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withAlpha(50),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: GoogleFonts.outfit(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: query.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
                if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

                final docs = snapshot.data!.docs;
                if (docs.isEmpty) return const Center(child: Text('No data found'));

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data() as Map<String, dynamic>;
                    return _buildListItem(context, data, type);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListItem(BuildContext context, Map<String, dynamic> data, String type) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (type == 'products') ...[
            Text(data['name'] ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Stock: ${data['stock'] ?? data['stockCount'] ?? 0}', style: TextStyle(color: AppColors.goldAccent)),
          ] else if (type == 'orders') ...[
            Text('Order #${data['id'] ?? 'N/A'}', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('Amount: \$${data['totalAmount']}', style: const TextStyle(color: AppColors.goldAccent)),
            Text('Status: ${data['status']?.toString().toUpperCase()}', style: const TextStyle(fontSize: 10)),
          ] else ...[
            Text(data['subject'] ?? 'No Subject', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('From: ${data['userEmail']}', style: const TextStyle(fontSize: 12)),
            const SizedBox(height: 4),
            Text(data['message'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ],
      ),
    );
  }
}
