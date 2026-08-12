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

    return Scaffold(
      appBar: AppBar(title: const Text('My Orders')),
      body: orders.isEmpty
          ? Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
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
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Browse the boutique and place your first order to see tracking progress here.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context).brightness == Brightness.dark
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
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Continue Shopping'),
                    ),
                  ],
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12.0),
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
                  margin: const EdgeInsets.only(bottom: 12.0),
                  child: ExpansionTile(
                    title: Text(
                      'Order #${order.id}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Row(
                      children: [
                        Text(formattedDate),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            order.status.name.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: statusColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '\$${order.totalAmount.toStringAsFixed(2)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    children: [
                      const Divider(),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Items Purchased:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 8),
                            ...order.items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 2.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.productName} (x${item.quantity})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.price * item.quantity).toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Shipping Address:',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            Text(order.shippingAddress),
                            const SizedBox(height: 8),
                            Text(
                              'Payment Method: ${order.paymentMethod}',
                              style: const TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Delivery Progress',
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 10),
                            _OrderStatusTimeline(status: order.status),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
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
