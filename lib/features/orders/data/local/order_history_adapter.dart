import 'package:app_watchhub/features/orders/domain/models/order_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class OrderHistoryAdapter extends TypeAdapter<OrderModel> {
  @override
  int get typeId => 41;

  @override
  OrderModel read(BinaryReader reader) {
    final id = reader.readString();
    final itemCount = reader.readInt();
    final items = [
      for (var index = 0; index < itemCount; index++)
        OrderItem(
          productId: reader.readString(),
          productName: reader.readString(),
          price: reader.readDouble(),
          quantity: reader.readInt(),
        ),
    ];
    final totalAmount = reader.readDouble();
    final orderDate = DateTime.fromMillisecondsSinceEpoch(reader.readInt());
    final shippingAddress = reader.readString();
    final paymentMethod = reader.readString();
    final statusName = reader.readString();

    return OrderModel(
      id: id,
      items: items,
      totalAmount: totalAmount,
      orderDate: orderDate,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      status: OrderStatus.values.byName(statusName),
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeString(obj.id)
      ..writeInt(obj.items.length);

    for (final item in obj.items) {
      writer
        ..writeString(item.productId)
        ..writeString(item.productName)
        ..writeDouble(item.price)
        ..writeInt(item.quantity);
    }

    writer
      ..writeDouble(obj.totalAmount)
      ..writeInt(obj.orderDate.millisecondsSinceEpoch)
      ..writeString(obj.shippingAddress)
      ..writeString(obj.paymentMethod)
      ..writeString(obj.status.name);
  }
}
