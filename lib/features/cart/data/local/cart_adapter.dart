import 'package:app_watchhub/features/cart/domain/models/cart_item_model.dart';
import 'package:app_watchhub/features/catalog/domain/models/product_model.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';

class CartAdapter extends TypeAdapter<CartItemModel> {
  @override
  int get typeId => 40;

  @override
  CartItemModel read(BinaryReader reader) {
    final product = ProductModel(
      id: reader.readString(),
      name: reader.readString(),
      brand: reader.readString(),
      price: reader.readDouble(),
      imageUrl: reader.readString(),
      description: reader.readString(),
      stockCount: reader.readInt(),
      isAvailable: reader.readBool(),
      tags: reader.readStringList(),
    );
    final quantity = reader.readInt();

    return CartItemModel(product: product, quantity: quantity);
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    final product = obj.product;

    writer
      ..writeString(product.id)
      ..writeString(product.name)
      ..writeString(product.brand)
      ..writeDouble(product.price)
      ..writeString(product.imageUrl)
      ..writeString(product.description)
      ..writeInt(product.stockCount)
      ..writeBool(product.isAvailable)
      ..writeStringList(product.tags)
      ..writeInt(obj.quantity);
  }
}
