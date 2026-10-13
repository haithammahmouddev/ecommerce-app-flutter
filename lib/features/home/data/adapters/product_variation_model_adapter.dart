import 'package:hive_ce/hive.dart';
import '../model/product_variation_model.dart';

class ProductVariationModelAdapter extends TypeAdapter<ProductVariationModel> {
  @override
  final int typeId = 8;

  @override
  ProductVariationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ProductVariationModel(
      id: fields[0] as String? ?? '',
      sku: fields[1] as String? ?? '',
      image: fields[2] as String? ?? '',
      description: fields[3] as String?,
      price: fields[4] as double? ?? 0.0,
      salePrice: fields[5] as double?,
      stock: fields[6] as int? ?? 0,
      attributeValues: fields[7] != null
          ? Map<String, String>.from(fields[7] as Map)
          : {},
    );
  }

  @override
  void write(BinaryWriter writer, ProductVariationModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.sku)
      ..writeByte(2)..write(obj.image)
      ..writeByte(3)..write(obj.description)
      ..writeByte(4)..write(obj.price)
      ..writeByte(5)..write(obj.salePrice)
      ..writeByte(6)..write(obj.stock)
      ..writeByte(7)..write(obj.attributeValues);
  }
}