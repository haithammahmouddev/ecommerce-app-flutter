import '../../domain/entities/brand_entity.dart';

class BrandModel {
  final String id;
  final String name;
  final String image;
  final bool? isFeatured;
  final int? productsCount;

  BrandModel({
    required this.id,
    required this.image,
    required this.name,
    this.isFeatured,
    this.productsCount,
  });

  static BrandModel empty() => BrandModel(id: '', image: '', name: '');

  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      isFeatured: json['isFeatured'] as bool?,
      productsCount: json['productsCount'] as int?,
    );
  }

  factory BrandModel.fromFirebaseJson(Map<String, dynamic> data, String docId) {
    return BrandModel(
      id: docId,
      name: data['name'] ?? '',
      image: data['image'] ?? '',
      isFeatured: data['isFeatured'] as bool?,
      productsCount: data['productCounts'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Name': name,
      'Image': image,
      'IsFeatured': isFeatured,
      'ProductsCount': productsCount,
    };
  }

  factory BrandModel.fromEntity(BrandEntity entity) {
    return BrandModel(
      id: entity.id,
      name: entity.name,
      image: entity.image,
      isFeatured: entity.isFeatured,
      productsCount: entity.productsCount,
    );
  }

  BrandEntity toEntity() {
    return BrandEntity(
      id: id,
      name: name,
      image: image,
      isFeatured: isFeatured ?? false,
      productsCount: productsCount ?? 0,
    );
  }
}