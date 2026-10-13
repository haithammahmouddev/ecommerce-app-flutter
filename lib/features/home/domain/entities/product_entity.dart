import 'package:equatable/equatable.dart';
import 'package:fit_store/features/store/data/models/brand_model.dart';
import 'package:fit_store/features/home/domain/entities/product_attribute_entity.dart';
import 'package:fit_store/features/home/domain/entities/product_variation_entity.dart';
import 'package:flutter/cupertino.dart';

import '../../../store/domain/entities/brand_entity.dart';
import '../../data/model/product_attribute_model.dart';
import '../../data/model/product_model.dart';
import '../../data/model/product_variation_model.dart';

class ProductEntity extends Equatable {
  final String id;
  final String title;
  final double price;
  int stock;
  final double? salePrice;
  final String thumbnail;
  String productType;
  final String? description;
  final List<String>? images;
  final BrandEntity? brand;
  final List<ProductAttributeEntity>? productAttributes;
  final List<ProductVariationEntity>? productVariations;

    ProductEntity({
    required this.id,
    required this.title,
    required this.price,
    required this.thumbnail,
    required this.productType,
    this.salePrice,
    this.description,
    this.images,
    this.brand,
      required this.stock,
      this.productAttributes,
    this.productVariations,
  });

  ProductModel toModel() {
    return ProductModel(
      id: id,
      title: title,
      stock: stock,
      price: price,
      thumbnail: thumbnail,
      productType: productType,
      salePrice: salePrice,
      description: description,
      images: images,
      brand: brand != null ? BrandModel.fromEntity(brand!) : null,
      productAttributes: productAttributes?.map((e) =>
          ProductAttributeModel.fromEntity(e)).toList(),
      productVariations: productVariations?.map((e) =>
          ProductVariationModel.fromEntity(e)).toList(),
    );
  }

  @override
  List<Object?> get props => [id, title, price, salePrice, thumbnail, description, images, brand, productAttributes, productVariations];
}

