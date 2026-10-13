import 'package:equatable/equatable.dart';

class CartItemEntity extends Equatable {
  final String productId;
  final String title;
  final double price;
  final String? image;
  final int quantity;
  final String variationId;
  final String? brandName;
  final Map<String, String>? selectedVariation;

  const CartItemEntity({
    required this.productId,
    required this.title,
    required this.price,
    this.image,
    required this.quantity,
    required this.variationId,
    this.brandName,
    this.selectedVariation,
  });

  @override
  List<Object?> get props => [
    productId,
    title,
    price,
    image,
    quantity,
    variationId,
    brandName,
    selectedVariation,
  ];
}
