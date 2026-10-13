import 'package:hive_ce/hive.dart';
import '../model/product_attribute_model.dart';

class ProductAttributeModelAdapter extends TypeAdapter<ProductAttributeModel> {
  @override
  final int typeId = 7;

  @override
  ProductAttributeModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ProductAttributeModel(
      name: fields[0] as String?,
      values: fields[1] != null ? (fields[1] as List).cast<String>() : null,
    );
  }

  @override
  void write(BinaryWriter writer, ProductAttributeModel obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)..write(obj.name)
      ..writeByte(1)..write(obj.values);
  }
}