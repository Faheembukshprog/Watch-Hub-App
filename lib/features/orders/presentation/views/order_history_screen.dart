import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:google_fonts/google_fonts.dart';
import '../providers/order_history_provider.dart';
import '../../domain/models/order_model.dart';

class OrderHistoryScreen extends ConsumerWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final orders = ref.watch(orderHistoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBg : AppColors.lightBg,
      appBar: AppBar(title: const Text('MY ORDERS')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: orders.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timeline_outlined,
                          size: 64,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No orders yet',
                          style: GoogleFonts.outfit(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Browse the boutique and place your first order to see tracking progress here.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 24),
                        OutlinedButton(
                          onPressed: () => context.go('/catalog'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.goldAccent,
                            side: const BorderSide(color: AppColors.goldAccent),
                            minimumSize: const Size(200, 48),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text('CONTINUE BROWSING'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20.0),
                  physics: const BouncingScrollPhysics(),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final formattedDate = DateFormat(
                      'MMM dd, yyyy • hh:mm a',
                    ).format(order.orderDate);

                    Color statusColor;
                    switch (order.status) {
                      case OrderStatus.delivered:
                        statusColor = AppColors.success;
                      case OrderStatus.cancelled:
                        statusColor = AppColors.error;
                      default:
                        statusColor = AppColors.warning;
                    }

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16.0),
                      color: isDark ? AppColors.darkSurface : Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                        side: BorderSide(
                          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                        ),
                      ),
                      child: ExpansionTile(
                        iconColor: AppColors.goldAccent,
                        collapsedIconColor: AppColors.neutral,
                        title: Text(
                          'Order #${order.id}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Row(
                          children: [
                            Text(
                              formattedDate,
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: statusColor.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                order.status.name.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.bold,
                                  color: statusColor,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                        trailing: Text(
                          '\$${order.totalAmount.toStringAsFixed(0)}',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: AppColors.goldAccent,
                          ),
                        ),
                        children: [
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'INVENTORY DETAILS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...order.items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 4.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.productName} (x${item.quantity})',
                                            style: const TextStyle(fontSize: 13),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '\$${(item.price * item.quantity).toStringAsFixed(0)}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'LOGISTICS',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  order.shippingAddress,
                                  style: const TextStyle(fontSize: 13),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Payment: ${order.paymentMethod}',
                                  style: TextStyle(
                                    fontStyle: FontStyle.italic,
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                                const SizedBox(height: 24),
                                Text(
                                  'CONCIERGE TRACKING',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.neutral,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                _OrderStatusTimeline(status: order.status),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _OrderStatusTimeline extends StatelessWidget {
  final OrderStatus status;

  const _OrderStatusTimeline({required this.status});

  Color _statusColor(OrderStatus step) {
    switch (step) {
      case OrderStatus.delivered:
        return AppColors.success;
      case OrderStatus.cancelled:
        return AppColors.error;
      case OrderStatus.shipped:
        return AppColors.warning;
      case OrderStatus.processing:
        return AppColors.goldAccent;
      case OrderStatus.pending:
        return AppColors.neutral;
    }
  }

  bool _isActive(OrderStatus step) {
    final orderIndex = OrderStatus.values.indexOf(status);
    final stepIndex = OrderStatus.values.indexOf(step);
    return stepIndex <= orderIndex;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    final steps = [
      OrderStatus.pending,
      OrderStatus.processing,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];

    return Column(
      children: steps.map((step) {
        final active = _isActive(step);
        final isLast = step == steps.last;
        
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 2.0),
                child: Column(
                  children: [
                    Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: active
                            ? _statusColor(step)
                            : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: active
                              ? _statusColor(step)
                              : (isDark ? Colors.white24 : Colors.grey[300]!),
                          width: active ? 3 : 2,
                        ),
                        boxShadow: active ? [
                          BoxShadow(
                            color: _statusColor(step).withValues(alpha: 0.3),
                            blurRadius: 6,
                            spreadRadius: 2,
                          )
                        ] : [],
                      ),
                    ),
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: 1.5,
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          color: active 
                            ? _statusColor(step).withValues(alpha: 0.5) 
                            : (isDark ? Colors.white12 : Colors.grey[200]!),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        step.name.toUpperCase(),
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: active
                              ? (isDark ? Colors.white : AppColors.lightTextPrimary)
                              : AppColors.neutral,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _statusSubtitle(step),
                        style: TextStyle(
                          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _statusSubtitle(OrderStatus step) {
    switch (step) {
      case OrderStatus.pending:
        return 'Order received by Concierge';
      case OrderStatus.processing:
        return 'Authentication, inspection and packaging';
      case OrderStatus.shipped:
        return 'Luxury shipment in transit with premium delivery';
      case OrderStatus.delivered:
        return 'Package delivered to your residence';
      case OrderStatus.cancelled:
        return 'Order has been cancelled';
    }
  }
}
