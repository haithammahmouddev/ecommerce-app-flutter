import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fit_store/features/home/data/model/product_attribute_model.dart';
import 'package:fit_store/features/home/data/model/product_variation_model.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import '../../../store/data/models/brand_model.dart';
import '../../../store/domain/entities/brand_entity.dart';

class ProductModel {
  String id;
  int stock;
  String? sku;
  double price;
  String title;
  DateTime? date;
  double? salePrice;
  String thumbnail;
  bool? isFeatured;
  BrandModel? brand;
  String? description;
  String? categoryId;
  List<String>? images;
  String productType;
  List<ProductAttributeModel>? productAttributes;
  List<ProductVariationModel>? productVariations;

  ProductModel({
    required this.id,
    required this.title,
    required this.stock,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.sku,
    this.brand,
    this.date,
    this.images,
    this.salePrice,
    this.isFeatured,
    this.categoryId,
    this.description,
    this.productAttributes,
    this.productVariations,
  });

  ProductEntity toEntity() {
    return ProductEntity(
      id: id,
      title: title,
      price: price,
      salePrice: salePrice,
      thumbnail: thumbnail,
      description: description,
      images: images,
      brand: brand?.toEntity() ?? BrandEntity.empty(),
      productAttributes: productAttributes?.map((e) => e.toEntity()).toList(),
      productVariations: productVariations?.map((e) => e.toEntity()).toList(),
      productType: productType, stock: stock,
    );
  }



  factory ProductModel.fromFirebaseJson(Map<String, dynamic> json, String? docId) {
    return ProductModel(
      id: docId ?? json['Id'] ?? '',
      title: json['Title'] ?? '',
      stock: json['Stock'] ?? 0,
      price: (json['Price'] ?? 0.0).toDouble(),
      thumbnail: json['Thumbnail'] ?? '',
      productType: json['ProductType'] ?? '',
      sku: json['Sku'],
      brand: json['Brand'] != null ? BrandModel.fromJson(json['Brand']) : null,
      date: json['Date'] != null ? (json['Date'] as Timestamp).toDate() : null,
      images: json['Images'] != null ? List<String>.from(json['Images']) : null,
      salePrice: json['SalePrice'] != null ? (json['SalePrice']).toDouble() : null,
      isFeatured: json['IsFeatured'],
      categoryId: json['CategoryId'],
      description: json['Description'],
      productAttributes: json['ProductAttributes'] != null
          ? (json['ProductAttributes'] as List).map((e) => ProductAttributeModel.fromJson(e)).toList()
          : null,
      productVariations: json['ProductVariations'] != null
          ? (json['ProductVariations'] as List).map((e) => ProductVariationModel.fromJson(e)).toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'Id': id,
      'Title': title,
      'Stock': stock,
      'Price': price,
      'Thumbnail': thumbnail,
      'ProductType': productType,
      'Sku': sku,
      'Brand': brand?.toJson(),
      'Date': date,
      'Images': images,
      'SalePrice': salePrice,
      'IsFeatured': isFeatured,
      'CategoryId': categoryId,
      'Description': description,
      'ProductAttributes': productAttributes?.map((e) => e.toJson()).toList(),
      'ProductVariations': productVariations?.map((e) => e.toJson()).toList(),
    };
  }
}
