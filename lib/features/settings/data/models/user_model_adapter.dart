import 'package:fit_store/features/settings/data/models/user_model.dart';
import 'package:hive_ce_flutter/adapters.dart';
import '../../../../utils/constants/enums.dart';

class UserModelAdapter extends TypeAdapter<UserModel> {
  @override
  final int typeId = 0;

  @override
  UserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };

    return UserModel(
      id: fields[0] as String,
      fullName: fields[1] as String,
      email: fields[2] as String,
      phoneNumber: fields[3] as String,
      profilePicture: fields[4] as String,
      role: AppRole.user,
      createdAt: null,
      updatedAt: null,
      orders: null,
      addresses: null,
    );
  }

  @override
  void write(BinaryWriter writer, UserModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)..write(obj.id)
      ..writeByte(1)..write(obj.fullName)
      ..writeByte(2)..write(obj.email)
      ..writeByte(3)..write(obj.phoneNumber)
      ..writeByte(4)..write(obj.profilePicture);
  }
}
