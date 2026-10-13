import 'package:hive_ce/hive.dart';
import '../model/product_model.dart';
import '../model/product_attribute_model.dart';
import '../model/product_variation_model.dart';
import '../../../store/data/models/brand_model.dart';

class ProductModelAdapter extends TypeAdapter<ProductModel> {
  @override
  final int typeId = 1;

  @override
  ProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ProductModel(
      id: fields[0] as String? ?? '',
      stock: fields[1] as int? ?? 0,
      sku: fields[2] as String?,
      price: fields[3] as double? ?? 0.0,
      title: fields[4] as String? ?? '',
      date: fields[5] as DateTime?,
      salePrice: fields[6] as double?,
      thumbnail: fields[7] as String? ?? '',
      isFeatured: fields[8] as bool?,
      brand: fields[9] as BrandModel?,
      description: fields[10] as String?,
      categoryId: fields[11] as String?,
      images: fields[12] != null ? (fields[12] as List).cast<String>() : null,
      productType: fields[13] as String? ?? '',
      productAttributes: fields[14] != null
          ? (fields[14] as List).cast<ProductAttributeModel>()
          : null,
      productVariations: fields[15] != null
          ? (fields[15] as List).cast<ProductVariationModel>()
          : null,
    );
  }

  @override
  void write(BinaryWriter writer, ProductModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.stock)
      ..writeByte(2)..write(obj.sku)
      ..writeByte(3)..write(obj.price)
      ..writeByte(4)..write(obj.title)
      ..writeByte(5)..write(obj.date)
      ..writeByte(6)..write(obj.salePrice)
      ..writeByte(7)..write(obj.thumbnail)
      ..writeByte(8)..write(obj.isFeatured)
      ..writeByte(9)..write(obj.brand)
      ..writeByte(10)..write(obj.description)
      ..writeByte(11)..write(obj.categoryId)
      ..writeByte(12)..write(obj.images)
      ..writeByte(13)..write(obj.productType)
      ..writeByte(14)..write(obj.productAttributes)
      ..writeByte(15)..write(obj.productVariations);
  }
}