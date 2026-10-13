import 'package:hive_ce/hive.dart';
import '../model/reviews_model.dart';

class ReviewModelAdapter extends TypeAdapter<ReviewModel> {
  @override
  final int typeId = 10;

  @override
  ReviewModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return ReviewModel(
      id: fields[0] as String? ?? '',
      productId: fields[1] as String? ?? '',
      userId: fields[2] as String? ?? '',
      userName: fields[3] as String? ?? '',
      userImage: fields[4] as String? ?? '',
      rating: fields[5] as double? ?? 0.0,
      comment: fields[6] as String? ?? '',
      createdAt: fields[7] as DateTime? ?? DateTime.now(),
      updatedAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, ReviewModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.productId)
      ..writeByte(2)..write(obj.userId)
      ..writeByte(3)..write(obj.userName)
      ..writeByte(4)..write(obj.userImage)
      ..writeByte(5)..write(obj.rating)
      ..writeByte(6)..write(obj.comment)
      ..writeByte(7)..write(obj.createdAt)
      ..writeByte(8)..write(obj.updatedAt);
  }
}