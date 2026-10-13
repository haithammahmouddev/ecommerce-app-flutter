import 'package:hive_ce/hive.dart';
import '../model/category_model.dart';

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 9;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return CategoryModel(
      id: fields[0] as String? ?? '',
      name: fields[1] as String? ?? '',
      image: fields[2] as String? ?? '',
      parentId: fields[3] as String?,
      isFeatured: fields[4] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.name)
      ..writeByte(2)..write(obj.image)
      ..writeByte(3)..write(obj.parentId)
      ..writeByte(4)..write(obj.isFeatured);
  }
}