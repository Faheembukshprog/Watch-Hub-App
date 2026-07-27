import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
      // 1. Unfocus soft keyboard
      FocusScope.of(context).unfocus();

      // 2. Read current cart items (Fixed provider reference)
      final cartItems = ref.read(cartProvider);

      // 3. Convert CartItems into historical OrderItems snapshot
      final orderItems = cartItems
          .map((item) => OrderItem(
                productId: item.product.id,
                productName: item.product.name,
                price: item.product.price,
                quantity: item.quantity,
              ))
          .toList();

      // 4. Create the Order object
      final newOrder = OrderModel(
        id: 'ORD-${DateTime.now().millisecondsSinceEpoch}',
        items: orderItems,
        totalAmount: totalAmount,
        orderDate: DateTime.now(),
        shippingAddress: _addressController.text.trim(),
        paymentMethod: _selectedPaymentMethod,
      );

      // 5. Save to Order History
      ref.read(orderHistoryProvider.notifier).addOrder(newOrder);

      // 6. Show confirmation dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          icon: const Icon(
            Icons.check_circle_outline,
            color: Colors.green,
            size: 60,
          ),
          title: const Text('Order Placed!'),
          content: Text(
            'Thank you for your purchase, ${_nameController.text.trim()}.\nOrder ID: ${newOrder.id}\nTotal paid: \$${totalAmount.toStringAsFixed(2)}',
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Clear cart only when navigating away to prevent UI flash
                ref.read(cartProvider.notifier).clearCart();
                Navigator.of(dialogContext).popUntil((route) => route.isFirst);
              },
              child: const Text('Back to Home'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Fixed provider reference
    final cartItems = ref.watch(cartProvider);

    final totalAmount = cartItems.fold<double>(
      0.0,
      (sum, item) => sum + (item.product.price * item.quantity),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartItems.isEmpty
          ? const Center(
              child: Text(
                'Your cart is empty. Please add items to proceed.',
                style: TextStyle(fontSize: 16),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Shipping Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        prefixIcon: Icon(Icons.person_outline),
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
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
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                              ? 'Please enter your phone number'
                              : null,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Payment Method',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // --- NEW FLUTTER 3.32+ RADIOGROUP PATTERN ---
                    RadioGroup<String>(
                      groupValue: _selectedPaymentMethod,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() => _selectedPaymentMethod = value);
                        }
                      },
                      child: const Column(
                        children: [
                          RadioListTile<String>(
                            title: Text('Cash on Delivery'),
                            value: 'Cash on Delivery',
                          ),
                          RadioListTile<String>(
                            title: Text('Credit / Debit Card'),
                            value: 'Card',
                          ),
                        ],
                      ),
                    ),
                    // ---------------------------------------------

                    const SizedBox(height: 24),
                    Text(
                      'Order Summary',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            ...cartItems.map(
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
                                        '${item.product.name} (x${item.quantity})',
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Text(
                                      '\$${(item.product.price * item.quantity).toStringAsFixed(2)}',
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const Divider(),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Total',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                Text(
                                  '\$${totalAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _placeOrder(totalAmount),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: const Text('Confirm & Place Order'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}