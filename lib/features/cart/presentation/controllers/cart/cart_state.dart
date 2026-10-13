import 'package:equatable/equatable.dart';
import '../../../data/models/cart_item_model.dart';

class CartState extends Equatable {
  final int noOfCartItems;
  final double totalCartPrice;
  final int productQuantityInCart;
  final List<CartItemModel> cartItems;

  const CartState({
    this.noOfCartItems = 0,
    this.totalCartPrice = 0.0,
    this.productQuantityInCart = 0,
    this.cartItems = const [],
  });

  CartState copyWith({
    int? noOfCartItems,
    double? totalCartPrice,
    int? productQuantityInCart,
    List<CartItemModel>? cartItems,
  }) {
    return CartState(
      noOfCartItems: noOfCartItems ?? this.noOfCartItems,
      totalCartPrice: totalCartPrice ?? this.totalCartPrice,
      productQuantityInCart: productQuantityInCart ?? this.productQuantityInCart,
      cartItems: cartItems ?? this.cartItems,
    );
  }

  @override
  List<Object?> get props => [
    noOfCartItems,
    totalCartPrice,
    productQuantityInCart,
    cartItems,
  ];
}