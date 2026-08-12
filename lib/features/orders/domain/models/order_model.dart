enum OrderStatus { pending, processing, shipped, delivered, cancelled }

class OrderItem {
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const OrderItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() => {
    'productId': productId,
    'productName': productName,
    'price': price,
    'quantity': quantity,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      productId: map['productId'] ?? 'UNK',
      productName: map['productName'] ?? 'Unknown Item',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
    );
  }
}

class OrderModel {
  final String id;
  final List<OrderItem> items;
  final double totalAmount;
  final DateTime orderDate;
  final String shippingAddress;
  final String paymentMethod;
  final OrderStatus status;

  const OrderModel({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.orderDate,
    required this.shippingAddress,
    required this.paymentMethod,
    this.status = OrderStatus.pending,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'items': items.map((x) => x.toMap()).toList(),
    'totalAmount': totalAmount,
    'orderDate': orderDate.toIso8601String(),
    'shippingAddress': shippingAddress,
    'paymentMethod': paymentMethod,
    'status': status.name,
  };

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? 'ORD-UNK',
      items: map['items'] != null
          ? List<OrderItem>.from(
              (map['items'] as List<dynamic>).map((x) => OrderItem.fromMap(x)),
            )
          : [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      orderDate: map['orderDate'] != null
          ? DateTime.tryParse(map['orderDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
      shippingAddress: map['shippingAddress'] ?? 'No Address',
      paymentMethod: map['paymentMethod'] ?? 'N/A',
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.pending,
      ),
    );
  }
}
