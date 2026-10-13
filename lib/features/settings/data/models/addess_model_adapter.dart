import 'package:hive_ce_flutter/adapters.dart';
import 'address_model.dart';

class AddressModelAdapter extends TypeAdapter<AddressModel> {
  @override
  final int typeId = 5;

  @override
  AddressModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return AddressModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      street: fields[3] as String,
      city: fields[4] as String,
      state: fields[5] as String,
      postalCode: fields[6] as String,
      country: fields[7] as String,
      dateTime: fields[8] as DateTime?,
      selectedAddress: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AddressModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.phoneNumber)
      ..writeByte(3)..write(obj.street)
      ..writeByte(4)..write(obj.city)
      ..writeByte(5)..write(obj.state)
      ..writeByte(6)..write(obj.postalCode)
      ..writeByte(7)..write(obj.country)
      ..writeByte(8)..write(obj.dateTime)
      ..writeByte(9)..write(obj.selectedAddress);
  }
}