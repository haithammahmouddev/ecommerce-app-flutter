import 'package:hive_ce_flutter/adapters.dart';
import 'cart_item_model.dart';

class CartItemModelAdapter extends TypeAdapter<CartItemModel> {
  @override
  final int typeId = 4;

  @override
  CartItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return CartItemModel(
      productId: fields[0] as String,
      title: fields[1] as String,
      price: fields[2] as double,
      image: fields[3] as String?,
      quantity: fields[4] as int,
      variationId: fields[5] as String,
      brandName: fields[6] as String?,
      selectedVariation: fields[7] != null
          ? Map<String, String>.from(fields[7] as Map)
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, CartItemModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.productId)
      ..writeByte(1)..write(obj.title)
      ..writeByte(2)..write(obj.price)
      ..writeByte(3)..write(obj.image)
      ..writeByte(4)..write(obj.quantity)
      ..writeByte(5)..write(obj.variationId)
      ..writeByte(6)..write(obj.brandName)
      ..writeByte(7)..write(obj.selectedVariation);
  }
}