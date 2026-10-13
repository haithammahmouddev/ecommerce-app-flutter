import 'address_entity.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/formatters/formatter.dart';
import '../../../auth/domain/entities/order_entity.dart';

class UserEntity {
  final String id;
  final String fullName;
  final String userName;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final AppRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderEntity>? orders;
  final List<AddressEntity>? addresses;

  const UserEntity({
    required this.id,
    this.fullName = '',
    this.userName = '',
    required this.email,
    this.phoneNumber = '',
    this.profilePicture = '',
    this.role = AppRole.user,
    this.createdAt,
    this.updatedAt,
    this.orders,
    this.addresses,
  });

  String get formattedPhoneNo => FormatterApp.formatPhoneNumber(phoneNumber);

  String get formattedDate =>
      createdAt != null ? FormatterApp.formatDate(createdAt!) : '';

  String get formattedUpdatedAtDate =>
      updatedAt != null ? FormatterApp.formatDate(updatedAt!) : '';

  static const empty = UserEntity(
    id: '',
    email: '',
  );

  UserEntity copyWith({
    String? id,
    String? fullName,
    String? userName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    AppRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderEntity>? orders,
    List<AddressEntity>? addresses,
  }) {
    return UserEntity(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      userName: userName ?? this.userName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePicture: profilePicture ?? this.profilePicture,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      orders: orders ?? this.orders,
      addresses: addresses ?? this.addresses,
    );
  }

}