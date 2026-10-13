import '../../domain/entities/product_attribute_entity.dart';

class ProductAttributeModel {
  String? name;
  final List<String>? values;

  ProductAttributeModel({this.name, this.values});

  ProductAttributeEntity toEntity() {
    return ProductAttributeEntity(
      name: name,
      values: values,
    );
  }

  factory ProductAttributeModel.fromJson(Map<String, dynamic> json) {
    return ProductAttributeModel(
      name: json['Name'],
      values: json['Values'] != null ? List<String>.from(json['Values']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Name': name,
      'Values': values,
    };
  }

  factory ProductAttributeModel.fromEntity(ProductAttributeEntity entity) {
    return ProductAttributeModel(
      name: entity.name,
      values: entity.values,
    );
  }
}
