import 'package:hive_ce/hive.dart';
import 'brand_model.dart';

class BrandModelAdapter extends TypeAdapter<BrandModel> {
  @override
  final int typeId = 2;

  @override
  BrandModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return BrandModel(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? '',
      image: fields[2] as String? ?? '',
      isFeatured: fields[3] as bool?,
      productsCount: fields[4] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, BrandModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.image)
      ..writeByte(3)..write(obj.isFeatured)
      ..writeByte(4)..write(obj.productsCount);
  }
}