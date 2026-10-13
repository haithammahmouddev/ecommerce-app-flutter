import 'package:hive_ce_flutter/adapters.dart';
import '../../../../../utils/constants/enums.dart';
 import '../../../cart/data/models/cart_item_model.dart';
import 'address_model.dart';
import 'order_model.dart';

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 6;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return OrderModel(
      id: fields[0] as String,
      userId: fields[1] as String,
      status: OrderStatus.values[fields[2] as int],
      totalAmount: fields[3] as double,
      orderDate: fields[4] as DateTime,
      paymentMethod: fields[5] as String,
      address: fields[6] as AddressModel?,
      deliveryDate: fields[7] as DateTime?,
      items: (fields[8] as List).cast<CartItemModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.userId)
      ..writeByte(2)..write(obj.status.index)
      ..writeByte(3)..write(obj.totalAmount)
      ..writeByte(4)..write(obj.orderDate)
      ..writeByte(5)..write(obj.paymentMethod)
      ..writeByte(6)..write(obj.address)
      ..writeByte(7)..write(obj.deliveryDate)
      ..writeByte(8)..write(obj.items);
  }
}