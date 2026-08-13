import 'package:flutter/material.dart';
import 'package:app_watchhub/core/constants/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:app_watchhub/core/router/app_router.dart';
import 'package:app_watchhub/shared/providers/firebase_provider.dart';
import '../../../cart/presentation/providers/cart_provider.dart';
import '../../../orders/domain/models/order_model.dart';
import '../../../orders/presentation/providers/order_history_provider.dart';

class CheckoutScreen extends ConsumerStatefulWidget {
  const CheckoutScreen({super.key});

  @override
  ConsumerState<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends ConsumerState<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  String _selectedPaymentMethod = 'Cash on Delivery';

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _placeOrder(double totalAmount) {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();

      final cartItems = ref.read(cartProvider);

      final orderItems = cartItems
          .map(
            (item) => OrderItem(
              productId: item.product.id,
              productName: item.product.name,
              price: item.product.price,
              quantity: item.quantity,
            ),
          )
          .toList();

      final newOrder = OrderModel(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: orderItems,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        shippingAddress: _addressController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      ref.read(orderHistoryProvider.notifier).addOrder(newOrder);

      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: AppColors.goldAccent,
            size: 64,
          ),
          title: Text(
            'Order Placed!',
            style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Thank you for your purchase, ${_nameController.text.trim()}.\n\nOrder ID: ${newOrder.id}\nTotal paid: \$${totalAmount.toStringAsFixed(2)}\n\nOur concierge team will contact you shortly.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(height: 1.4),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.goldAccent,
                foregroundColor: isDark
                    ? AppColors.darkBg
                    : Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                ref.read(cartProvider.notifier).clearCart();
                Navigator.of(dialogContext).popUntil((route) => route.isFirst);
              },
              child: const Text('BACK TO BOUTIQUE'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.goldAccent),
        ),
      );
    }

    final cartItems = ref.watch(cartProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final subtotal = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    const shipping = 0.00;
    final tax = subtotal * 0.08;
    final totalAmount = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBg
          : AppColors.lightBg,
      appBar: AppBar(
        title: Text(
          'SECURE CHECKOUT',
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
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: cartItems.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          size: 80,
                          color: AppColors.neutral,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Your cart is empty',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Please select a timepiece from our collection before proceeding to checkout.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.neutral, fontSize: 15),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton(
                          onPressed: () => context.go(AppRoutes.catalog),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.goldAccent,
                            foregroundColor: isDark ? AppColors.darkBg : Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          ),
                          child: const Text('BACK TO BOUTIQUE'),
                        ),
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                  physics: const BouncingScrollPhysics(),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // --- Custom Luxury Stepper Progress Indicator ---
                        const Center(child: _CheckoutProgressIndicator()),
                        const SizedBox(height: 48),

                        // --- Shipping Section ---
                        _buildSectionHeader('SHIPPING DESTINATION'),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(
                            labelText: 'Full Collector Name',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Identification name required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _addressController,
                          decoration: const InputDecoration(
                            labelText: 'Delivery Address',
                            prefixIcon: Icon(Icons.location_on_outlined),
                          ),
                          maxLines: 2,
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Delivery destination required'
                              : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          decoration: const InputDecoration(
                            labelText: 'Secure Contact Number',
                            prefixIcon: Icon(Icons.phone_outlined),
                          ),
                          validator: (value) =>
                              value == null || value.trim().isEmpty
                              ? 'Contact number required'
                              : null,
                        ),
                        const SizedBox(height: 40),

                        // --- Payment Method ---
                        _buildSectionHeader('PAYMENT PROTOCOL'),
                        const SizedBox(height: 20),

                        // Standard Flutter 3.32+ RadioGroup
                        RadioGroup<String>(
                          groupValue: _selectedPaymentMethod,
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _selectedPaymentMethod = value);
                            }
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.darkSurface
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDark
                                    ? AppColors.darkBorder
                                    : AppColors.lightBorder,
                              ),
                              boxShadow: [
                                BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))
                              ],
                            ),
                            child: Column(
                              children: [
                                RadioListTile<String>(
                                  title: Text(
                                    'Cash on Delivery',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: const Text('Pay upon personalized hand-delivery', style: TextStyle(fontSize: 12)),
                                  value: 'Cash on Delivery',
                                  activeColor: AppColors.goldAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                                Divider(
                                  height: 1,
                                  indent: 16,
                                  endIndent: 16,
                                  color: isDark
                                      ? AppColors.darkBorder
                                      : AppColors.lightBorder,
                                ),
                                RadioListTile<String>(
                                  title: Text(
                                    'Vault Card / Wire',
                                    style: GoogleFonts.outfit(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  subtitle: const Text('Encrypted digital transaction', style: TextStyle(fontSize: 12)),
                                  value: 'Card',
                                  activeColor: AppColors.goldAccent,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),

                        // --- Order Summary ---
                        _buildSectionHeader('TRANSACTION SUMMARY'),
                        const SizedBox(height: 20),
                        Card(
                          color: isDark ? AppColors.darkSurface : Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.lightBorder),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Column(
                              children: [
                                ...cartItems.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8.0,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Expanded(
                                          child: Text(
                                            '${item.product.name} (x${item.quantity})',
                                            style: GoogleFonts.inter(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                        Text(
                                          '\$${(item.product.price * item.quantity).toStringAsFixed(0)}',
                                          style: GoogleFonts.outfit(
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.goldAccent,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(height: 1),
                                ),
                                _buildSummaryRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}', isDark),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Express Courier', 'INCLUDED', isDark, isSuccess: true),
                                const SizedBox(height: 12),
                                _buildSummaryRow('Sales Tax', '\$${tax.toStringAsFixed(2)}', isDark),
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 20),
                                  child: Divider(height: 1),
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'TOTAL',
                                      style: GoogleFonts.outfit(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    Text(
                                      '\$${totalAmount.toStringAsFixed(2)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: AppColors.goldAccent,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 48),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () => _placeOrder(totalAmount),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.goldAccent,
                              foregroundColor: isDark
                                  ? AppColors.darkBg
                                  : Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 4,
                            ),
                            child: Text(
                              'AUTHORIZE & PLACE ORDER',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.5,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 60),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.outfit(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        letterSpacing: 2.0,
        color: AppColors.goldAccent,
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, bool isDark, {bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark
                ? AppColors.darkTextSecondary
                : AppColors.lightTextSecondary,
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSuccess ? AppColors.success : (isDark ? Colors.white : Colors.black87),
          ),
        ),
      ],
    );
  }
}

class _CheckoutProgressIndicator extends StatelessWidget {
  const _CheckoutProgressIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStep(
          stepNumber: '1',
          label: 'Bag',
          isCompleted: true,
          isActive: false,
          isDark: isDark,
        ),
        _buildLine(isCompleted: true),
        _buildStep(
          stepNumber: '2',
          label: 'Shipping',
          isCompleted: false,
          isActive: true,
          isDark: isDark,
        ),
        _buildLine(isCompleted: false),
        _buildStep(
          stepNumber: '3',
          label: 'Success',
          isCompleted: false,
          isActive: false,
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildStep({
    required String stepNumber,
    required String label,
    required bool isCompleted,
    required bool isActive,
    required bool isDark,
  }) {
    Color circleColor = isDark ? AppColors.darkSurface : Colors.white;
    Color borderCol = isDark
        ? AppColors.darkBorder
        : AppColors.lightBorder;
    Color textCol = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    if (isCompleted) {
      circleColor = AppColors.goldAccent.withValues(alpha: 0.15);
      borderCol = AppColors.goldAccent;
      textCol = AppColors.goldAccent;
    } else if (isActive) {
      circleColor = AppColors.goldAccent;
      borderCol = AppColors.goldAccent;
      textCol = isDark ? Colors.black87 : Colors.white;
    }

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderCol, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: AppColors.goldAccent,
                  )
                : Text(
                    stepNumber,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: textCol,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: isActive || isCompleted ? AppColors.goldAccent : AppColors.neutral,
          ),
        ),
      ],
    );
  }

  Widget _buildLine({required bool isCompleted}) {
    return Container(
      width: 60,
      height: 2,
      margin: const EdgeInsets.only(bottom: 24, left: 8, right: 8),
      color: isCompleted
          ? AppColors.goldAccent
          : AppColors.neutral.withValues(alpha: 0.3),
    );
  }
}
