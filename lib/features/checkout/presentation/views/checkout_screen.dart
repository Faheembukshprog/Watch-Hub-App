import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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
          backgroundColor: isDark ? const Color(0xFF181B22) : Colors.white,
          icon: const Icon(
            Icons.check_circle_outline_rounded,
            color: Color(0xFFD4AF37),
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
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: isDark
                    ? const Color(0xFF0F1115)
                    : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
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
    final cartItems = ref.watch(cartProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final subtotal = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );
    const shipping = 0.00;
    final tax = subtotal * 0.08;
    final totalAmount = subtotal + shipping + tax;

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF0F1115)
          : const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: Text(
          'CHECKOUT',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            letterSpacing: 2.0,
            color: isDark ? Colors.white : const Color(0xFF0F172A),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty. Please add items to proceed.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // --- Custom Luxury Stepper Progress Indicator ---
                    const _CheckoutProgressIndicator(),
                    const SizedBox(height: 32),

                    // --- Shipping Section ---
                    Text(
                      'SHIPPING INFORMATION',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _addressController,
                      decoration: const InputDecoration(
                        labelText: 'Shipping Address',
                        prefixIcon: Icon(Icons.location_on_outlined),
                      ),
                      maxLines: 2,
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter your address'
                          : null,
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Phone Number',
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Please enter your phone number'
                          : null,
                    ),
                    const SizedBox(height: 32),

                    // --- Payment Method ---
                    Text(
                      'PAYMENT METHOD',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Standard Flutter 3.32+ RadioGroup / custom list tile setup
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
                              ? const Color(0xFF181B22)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF2A2E39)
                                : const Color(0xFFE2E8F0),
                          ),
                        ),
                        child: Column(
                          children: [
                            RadioListTile<String>(
                              title: Text(
                                'Cash on Delivery',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: 'Cash on Delivery',
                              activeColor: const Color(0xFFD4AF37),
                            ),
                            Divider(
                              height: 1,
                              color: isDark
                                  ? const Color(0xFF2A2E39)
                                  : const Color(0xFFE2E8F0),
                            ),
                            RadioListTile<String>(
                              title: Text(
                                'Credit / Debit Card',
                                style: GoogleFonts.outfit(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              value: 'Card',
                              activeColor: const Color(0xFFD4AF37),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // --- Order Summary ---
                    Text(
                      'ORDER SUMMARY',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.5,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: isDark ? const Color(0xFF181B22) : Colors.white,
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            ...cartItems.map(
                              (item) => Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 6.0,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        '${item.product.name} (x${item.quantity})',
                                        style: GoogleFonts.inter(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w500,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.product.price * item.quantity).toStringAsFixed(0)}',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF0F172A),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Subtotal',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFA0A5B5)
                                        : const Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '\$${subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Express Shipping',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFA0A5B5)
                                        : const Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                                const Text(
                                  'FREE',
                                  style: TextStyle(
                                    color: Colors.green,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Estimated Tax (8%)',
                                  style: TextStyle(
                                    color: isDark
                                        ? const Color(0xFFA0A5B5)
                                        : const Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                                Text(
                                  '\$${tax.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.outfit(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? Colors.white
                                        : const Color(0xFF0F172A),
                                  ),
                                ),
                                Text(
                                  '\$${totalAmount.toStringAsFixed(2)}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFFD4AF37),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _placeOrder(totalAmount),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFD4AF37),
                          foregroundColor: isDark
                              ? const Color(0xFF0F1115)
                              : Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          'CONFIRM & PLACE ORDER',
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _CheckoutProgressIndicator extends StatelessWidget {
  const _CheckoutProgressIndicator();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
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
          label: 'Review',
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
    Color circleColor = isDark ? const Color(0xFF181B22) : Colors.white;
    Color borderCol = isDark
        ? const Color(0xFF2A2E39)
        : const Color(0xFFE2E8F0);
    Color textCol = isDark ? const Color(0xFFA0A5B5) : const Color(0xFF64748B);

    if (isCompleted) {
      circleColor = const Color(0xFFD4AF37).withValues(alpha: 0.15);
      borderCol = const Color(0xFFD4AF37);
      textCol = const Color(0xFFD4AF37);
    } else if (isActive) {
      circleColor = const Color(0xFFD4AF37);
      borderCol = const Color(0xFFD4AF37);
      textCol = const Color(0xFFD4AF37);
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderCol, width: 2),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(
                    Icons.check_rounded,
                    size: 16,
                    color: Color(0xFFD4AF37),
                  )
                : Text(
                    stepNumber,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isActive ? Colors.black87 : textCol,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: textCol,
          ),
        ),
      ],
    );
  }

  Widget _buildLine({required bool isCompleted}) {
    return Container(
      width: 48,
      height: 2,
      margin: const EdgeInsets.only(bottom: 18),
      color: isCompleted
          ? const Color(0xFFD4AF37)
          : Colors.grey.withValues(alpha: 0.3),
    );
  }
}
