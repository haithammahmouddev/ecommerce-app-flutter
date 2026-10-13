import 'package:equatable/equatable.dart';

class ProductVariationEntity extends Equatable {
  final String id;
  final String sku;
  final String image;
  final String? description;
  final double price;
  final double? salePrice;
  final int stock;
  final Map<String, String> attributeValues;

  const ProductVariationEntity({
    required this.id,
    this.sku = '',
    this.image = '',
    this.description = '',
    this.price = 0.0,
    this.salePrice,
    this.stock = 0,
    required this.attributeValues,
  });

  static ProductVariationEntity empty() => const ProductVariationEntity(
    id: '',
    attributeValues: {},
    price: 0.0,
    salePrice: 0.0,
    image: '',
    sku: '',
    description: '',
    stock: 0,
  );

  @override
  List<Object?> get props => [id, sku, image, description, price, salePrice, stock, attributeValues];
}
