import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_store/utils/formatters/formatter.dart';
import '../../domain/entities/address_entity.dart';

class AddressModel {
  final String id;
  final String name;
  final String phoneNumber;
  final String street;
  final String city;
  final String state;
  final String postalCode;
  final String country;
  final DateTime? dateTime;
  final bool selectedAddress;

  AddressModel({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.street,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.country,
    this.dateTime,
    this.selectedAddress = true,
  });

  String get formattedPhoneNo => FormatterApp.formatPhoneNumber(phoneNumber);

  static AddressModel empty() => AddressModel(
    id: '',
    name: '',
    phoneNumber: '',
    street: '',
    city: '',
    state: '',
    postalCode: '',
    country: '',
  );

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'PhoneNumber': phoneNumber,
      'Street': street,
      'City': city,
      'State': state,
      'PostalCode': postalCode,
      'Country': country,
      'DateTime': dateTime != null ? Timestamp.fromDate(dateTime!) : null,
      'SelectedAddress': selectedAddress,
    };
  }

   factory AddressModel.fromSnapshot(DocumentSnapshot<Map<String, dynamic>> snapshot) {
    final data = snapshot.data();
    if (data == null) return AddressModel.empty();

    return AddressModel(
      id: snapshot.id,
      name: data['Name'] ?? data['name'] ?? '',
      phoneNumber: data['PhoneNumber'] ?? data['phoneNumber'] ?? '',
      street: data['Street'] ?? data['street'] ?? '',
      city: data['City'] ?? data['city'] ?? '',
      state: data['State'] ?? data['state'] ?? '',
      postalCode: data['PostalCode'] ?? data['postalCode'] ?? '',
      country: data['Country'] ?? data['country'] ?? '',
      dateTime: data['DateTime'] != null
          ? (data['DateTime'] is Timestamp
          ? (data['DateTime'] as Timestamp).toDate()
          : DateTime.tryParse(data['DateTime'].toString()))
          : null,
      selectedAddress: data['SelectedAddress'] ?? data['selectedAddress'] ?? true,
    );
  }


  AddressEntity toEntity() {
    return AddressEntity(
      id: id,
      name: name,
      phoneNumber: phoneNumber,
      street: street,
      city: city,
      state: state,
      postalCode: postalCode,
      country: country,
      dateTime: dateTime,
      selectedAddress: selectedAddress,
    );
  }

   factory AddressModel.fromEntity(AddressEntity entity) {
    return AddressModel(
      id: entity.id,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      street: entity.street,
      city: entity.city,
      state: entity.state,
      postalCode: entity.postalCode,
      country: entity.country,
      dateTime: entity.dateTime,
      selectedAddress: entity.selectedAddress,
    );
  }

  AddressModel copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? street,
    String? city,
    String? state,
    String? postalCode,
    String? country,
    DateTime? dateTime,
    bool? selectedAddress,
  }) {
    return AddressModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      street: street ?? this.street,
      city: city ?? this.city,
      state: state ?? this.state,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      dateTime: dateTime ?? this.dateTime,
      selectedAddress: selectedAddress ?? this.selectedAddress,
    );
  }

  factory AddressModel.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return AddressModel.empty();
    return AddressModel.fromMap(json);
  }

  factory AddressModel.fromMap(Map<String, dynamic> data) {
     DateTime? _parseDate(dynamic date) {
      if (date == null) return null;
      if (date is Timestamp) return date.toDate();
      if (date is String) return DateTime.tryParse(date);
      return null;
    }

    return AddressModel(
      id: (data['Id'] ?? data['id'] ?? '').toString(),
      name: (data['Name'] ?? data['name'] ?? '').toString(),
      phoneNumber: (data['PhoneNumber'] ?? data['phoneNumber'] ?? '').toString(),
      street: (data['Street'] ?? data['street'] ?? '').toString(),
      city: (data['City'] ?? data['city'] ?? '').toString(),
      state: (data['State'] ?? data['state'] ?? '').toString(),
      postalCode: (data['PostalCode'] ?? data['postalCode'] ?? '').toString(),
      country: (data['Country'] ?? data['country'] ?? '').toString(),
      dateTime: _parseDate(data['DateTime'] ?? data['dateTime']),
      selectedAddress: data['SelectedAddress'] ?? data['selectedAddress'] ?? true,
    );
  }
}
