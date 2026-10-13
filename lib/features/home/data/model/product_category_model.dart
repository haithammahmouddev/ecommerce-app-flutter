
import '../../domain/entities/product_category_entity.dart';


class ProductCategoryModel {
  final String productId;
  final String categoryId;

  ProductCategoryModel({
    required this.productId,
    required this.categoryId,
  });

  ProductCategoryEntity toEntity() {
    return ProductCategoryEntity(
      productId: productId,
      categoryId: categoryId,
    );
  }

  factory ProductCategoryModel.fromFirebaseJson(Map<String, dynamic> json) {
    return ProductCategoryModel(
      productId: json['productId'] as String? ?? '',
      categoryId: json['categoryId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productId': productId,
      'categoryId': categoryId,
    };
  }

}
