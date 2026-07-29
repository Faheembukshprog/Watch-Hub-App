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
      productId: map['productId'] ?? '',
      productName: map['productName'] ?? '',
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
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
      id: map['id'] ?? '',
      items: List<OrderItem>.from(
        (map['items'] as List<dynamic>).map((x) => OrderItem.fromMap(x)),
      ),
      totalAmount: (map['totalAmount'] as num).toDouble(),
      orderDate: DateTime.parse(map['orderDate']),
      shippingAddress: map['shippingAddress'] ?? '',
      paymentMethod: map['paymentMethod'] ?? '',
      status: OrderStatus.values.byName(map['status'] ?? 'pending'),
    );
  }
}
