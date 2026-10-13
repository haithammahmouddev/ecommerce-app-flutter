import '../../domain/entities/product_variation_entity.dart';

class ProductVariationModel {
  final String id;
  String sku;
  String image;
  String? description;
  double price;
  double? salePrice;
  int stock;
  Map<String, String> attributeValues;

  ProductVariationModel({
    required this.id,
    this.sku = '',
    this.image = '',
    this.description = '',
    this.price = 0.0,
    this.salePrice,
    this.stock = 0,
    required this.attributeValues,
  });

  factory ProductVariationModel.fromJson(Map<String, dynamic> document) {
    return ProductVariationModel(
      id: document['Id']?.toString() ?? '',
      sku: document['Sku']?.toString() ?? '',
      image: document['Image']?.toString() ?? '',
      description: document['Description']?.toString(),
       price: document['Price'] != null ? (document['Price'] as num).toDouble() : 0.0,
      salePrice: document['SalePrice'] != null ? (document['SalePrice'] as num).toDouble() : null,
      stock: document['Stock'] != null ? (document['Stock'] as num).toInt() : 0,
      attributeValues: document['AttributeValues'] != null
          ? Map<String, String>.from(
        (document['AttributeValues'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
        ),
      )
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Sku': sku,
      'Image': image,
      'Description': description,
      'Price': price,
      'SalePrice': salePrice,
      'Stock': stock,
      'AttributeValues': attributeValues,
    };
  }

  ProductVariationEntity toEntity() {
    return ProductVariationEntity(
      id: id,
      sku: sku,
      image: image,
      description: description,
      price: price,
      salePrice: salePrice,
      stock: stock,
      attributeValues: attributeValues,
    );
  }

  factory ProductVariationModel.fromEntity(ProductVariationEntity entity) {
    return ProductVariationModel(
      id: entity.id,
      sku: entity.sku,
      image: entity.image,
      description: entity.description,
      price: entity.price,
      salePrice: entity.salePrice,
      stock: entity.stock,
      attributeValues: entity.attributeValues,
    );
  }
}