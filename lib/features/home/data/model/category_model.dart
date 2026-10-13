import '../../domain/entities/categories_entity.dart';

class CategoryModel {
  final String id;
  final String name;
  final String image;
  final String? parentId;
  final bool? isFeatured;

  CategoryModel({
    required this.id,
    required this.name,
    required this.image,
    this.parentId,
    this.isFeatured,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'parentId': parentId,
      'isFeatured': isFeatured,
    };
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      parentId: json['parentId'],
      isFeatured: json['isFeatured'],
    );
  }

  factory CategoryModel.fromFirebaseJson(Map<String, dynamic> json, String documentId) {
    return CategoryModel(
      id: documentId,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      parentId: json['parentId'] ?? '',
      isFeatured: json['isFeatured'] ?? false,
    );
  }

  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      image: image,
      parentId: parentId,
      isFeatured: isFeatured,
    );
  }
}