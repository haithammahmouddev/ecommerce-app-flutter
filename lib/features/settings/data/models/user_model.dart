import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'address_model.dart';
import 'order_model.dart';
import '../../../../utils/constants/enums.dart';
import '../../../../utils/formatters/formatter.dart';
import '../../domain/entities/user_entity.dart';

class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String profilePicture;
  final AppRole role;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final List<OrderModel>? orders;
  final List<AddressModel>? addresses;

  UserModel({
    required this.id,
    this.fullName = '',
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

  static UserModel empty() => UserModel(
    id: '',
    email: '',
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );

  Map<String, dynamic> toJson({String? userName, String? phoneNum}) {
    return {
      'FullName': fullName,
      'Email': email,
      'PhoneNumber': phoneNum ?? phoneNumber,
      'ProfilePicture': profilePicture,
      'Role': role.name,
      'CreatedAt': createdAt?.toIso8601String(),
      'UpdatedAt': updatedAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  static DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    if (date is Timestamp) return date.toDate();
    if (date is String) return DateTime.tryParse(date);
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date);
    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return UserModel.empty();

    return UserModel(
      id: json['Id'] ?? json['id'] ?? '',
      fullName: json['FullName'] ?? json['fullName'] ?? '',
      email: json['Email'] ?? json['email'] ?? '',
      phoneNumber: json['PhoneNumber'] ?? json['phoneNumber'] ?? '',
      profilePicture: json['ProfilePicture'] ?? json['profilePicture'] ?? '',
      role: (json['Role'] == AppRole.admin.name || json['role'] == AppRole.admin.name)
          ? AppRole.admin
          : AppRole.user,
      createdAt: _parseDate(json['CreatedAt'] ?? json['createdAt']),
      updatedAt: _parseDate(json['UpdatedAt'] ?? json['updatedAt']),
      addresses: json['addresses'] != null
          ? (json['addresses'] as List).map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      orders: json['orders'] != null
          ? (json['orders'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  factory UserModel.fromFirebaseData(
      Map<String, dynamic>? data, {
        String? docId,
      }) {
    if (data == null || data.isEmpty) return UserModel.empty();

    return UserModel(
      id: docId ?? data['Id'] ?? data['id'] ?? '',
      fullName: data['FullName'] ?? '',
      email: data['Email'] ?? '',
      phoneNumber: data['PhoneNumber'] ?? '',
      profilePicture: data['ProfilePicture'] ?? '',
      role: data['Role'] == AppRole.admin.name ? AppRole.admin : AppRole.user,
      createdAt: _parseDate(data['CreatedAt']),
      updatedAt: _parseDate(data['UpdatedAt']),
      addresses: data['addresses'] != null
          ? (data['addresses'] as List).map((e) => AddressModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      orders: data['orders'] != null
          ? (data['orders'] as List).map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }

  factory UserModel.fromFirebaseUser({required User user,
    String? fullName, String? phoneNumber}) {
    return UserModel(
      id: user.uid,
      fullName: fullName ?? '',
      email: user.email ?? '',
      phoneNumber: phoneNumber ?? '',
      profilePicture: user.photoURL ??
          'https://pixabay.com',
      role: AppRole.user,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      profilePicture: entity.profilePicture,
      role: entity.role,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      orders: entity.orders?.map((o) => OrderModel.fromEntity(o)).toList(),
      addresses: entity.addresses?.map((a) => AddressModel.fromEntity(a)).toList(),
    );
  }

  UserEntity toEntity() {
    return UserEntity(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      profilePicture: profilePicture,
      role: role,
      createdAt: createdAt,
      updatedAt: updatedAt,
      orders: orders?.map((o) => o.toEntity()).toList(),
      addresses: addresses?.map((a) => a.toEntity()).toList(),
    );
  }

  UserModel copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? profilePicture,
    AppRole? role,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<OrderModel>? orders,
    List<AddressModel>? addresses,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
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
