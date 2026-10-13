import 'package:hive_ce/hive.dart';
import '../../../../../../utils/constants/enums.dart';
import '../model/banners_model.dart';

class BannerModelAdapter extends TypeAdapter<BannerModel> {
  @override
  final int typeId = 3;

  @override
  BannerModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    final targetTypeIndex = fields[3] as int? ?? 0;
    final targetType = (targetTypeIndex >= 0 && targetTypeIndex < BannerTargetType.values.length)
        ? BannerTargetType.values[targetTypeIndex]
        : BannerTargetType.none;

    return BannerModel(
      id: fields[0] as String? ?? '',
      imageUrl: fields[1] as String? ?? '',
      isActive: fields[2] as bool? ?? false,
      targetType: targetType,
      targetId: fields[4] as String? ?? '',
      targetName: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BannerModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imageUrl)
      ..writeByte(2)
      ..write(obj.isActive)
      ..writeByte(3)
      ..write(obj.targetType.index)
      ..writeByte(4)
      ..write(obj.targetId)
      ..writeByte(5)
      ..write(obj.targetName);
  }
}