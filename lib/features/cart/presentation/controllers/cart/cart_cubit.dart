import 'package:fit_store/common/local_storage/loacal_storage_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../utils/constants/enums.dart';
import '../../../../../utils/popups/loaders.dart';
import '../../../../home/data/model/product_model.dart';
import '../../../../home/presentation/controller/products_cubit/variation_cubit.dart';
import '../../../data/models/cart_item_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState()) {
    loadCartItems();
  }

  void updateProductQuantityInCart(int quantity) {
    emit(state.copyWith(productQuantityInCart: quantity));
  }

  Future<void> addToCart(ProductModel product, BuildContext context) async {
    final VariationCubit variationCubit = context.read<VariationCubit>();


    if (state.productQuantityInCart < 1) {
      Loaders.customToast(message: 'Select Quantity', context: context);
      return;
    }

     if (product.productType == ProductType.variable.name &&
        variationCubit.state.selectedVariation.id.isEmpty) {
      Loaders.customToast(message: 'Select Variation', context: context);
      return;
    }

    if (product.productType == ProductType.variable.name) {
      if (variationCubit.state.selectedVariation.stock < 1) {
        Loaders.warningSnackBar(
          message: 'Selected variation is out of stock.',
          title: 'Oh Snap!',
          context: context,
        );
        return;
      }
    } else {
      if (product.stock < 1) {
        Loaders.warningSnackBar(
          message: 'Selected Product is out of stock.',
          title: 'Oh Snap!',
          context: context,
        );
        return;
      }
    }

    final selectedCartItem =
    convertToCartItem(product, state.productQuantityInCart, context);

    final updatedCartItems = List<CartItemModel>.from(state.cartItems);

    int index = updatedCartItems.indexWhere((cartItem) =>
    cartItem.productId == selectedCartItem.productId &&
        cartItem.variationId == selectedCartItem.variationId);

    if (index >= 0) {
      updatedCartItems[index].quantity = selectedCartItem.quantity;
    } else {
      updatedCartItems.add(selectedCartItem);
    }
    await updateCart(updatedCartItems);
    Loaders.customToast(
        message: 'Your Product has been added to the Cart.', context: context);
  }

  CartItemModel convertToCartItem(ProductModel product, int quantity, BuildContext context) {
    final VariationCubit variationCubit = context.read<VariationCubit>();

    if (product.productType == ProductType.single.name) {
      variationCubit.resetSelectedAttributes();
    }

    final variation = variationCubit.state.selectedVariation;
    final isVariation = variation.id.isNotEmpty;

    final variationSalePrice = variation.salePrice ?? 0.0;
    final variationPrice = variation.price;
    final productSalePrice = product.salePrice ?? 0.0;
    final productPrice = product.price;

    final double price = isVariation
        ? (variationSalePrice > 0.0 ? variationSalePrice : variationPrice)
        : (productSalePrice > 0.0 ? productSalePrice : productPrice);

    return CartItemModel(
      productId: product.id,
      title: product.title,
      price: price,
      quantity: quantity,
      variationId: variation.id,
      image: isVariation ? variation.image : product.thumbnail,
      brandName: product.brand != null ? product.brand!.name : '',
      selectedVariation: isVariation ? variation.attributeValues : null,
    );
  }

  Future<void> updateCart(List<CartItemModel> updatedItems) async {
    final totals = calculateCartTotals(updatedItems);
    await LocalStorageService.cartRepo.saveData(updatedItems);
    emit(state.copyWith(
      cartItems: updatedItems,
      totalCartPrice: totals['totalPrice'],
      noOfCartItems: totals['totalItems'],
    ));
  }

  Map<String, dynamic> calculateCartTotals(List<CartItemModel> items) {
    double calculatedTotalPrice = 0.0;
    int calculatedNoOfItems = 0;

    for (var item in items) {
      calculatedTotalPrice += (item.price) * item.quantity.toDouble();
      calculatedNoOfItems += item.quantity;
    }

    return {
      'totalPrice': calculatedTotalPrice,
      'totalItems': calculatedNoOfItems,
    };
  }

  void loadCartItems() {
    final List<CartItemModel>? storedData = LocalStorageService.cartRepo.getData();
    if (storedData != null && storedData.isNotEmpty) {
      final totals = calculateCartTotals(storedData);
      emit(state.copyWith(
        cartItems: storedData,
        totalCartPrice: totals['totalPrice'],
        noOfCartItems: totals['totalItems'],
      ));
    }
  }

  void addOneToCart(CartItemModel item) {
    final updatedCartItems = List<CartItemModel>.from(state.cartItems);

    int index = updatedCartItems.indexWhere((cartItem) =>
    cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      updatedCartItems[index].quantity += 1;
    } else {
      updatedCartItems.add(item);
    }

    updateCart(updatedCartItems);
  }

  void removeOneFromCart(CartItemModel item, BuildContext context) {
    final updatedCartItems = List<CartItemModel>.from(state.cartItems);

    int index = updatedCartItems.indexWhere((cartItem) =>
    cartItem.productId == item.productId &&
        cartItem.variationId == item.variationId);

    if (index >= 0) {
      if (updatedCartItems[index].quantity > 1) {
        updatedCartItems[index].quantity -= 1;
        updateCart(updatedCartItems);
      } else {
        removeFromCartDialog(index, context);
      }
    }
  }

  void removeFromCartDialog(int index, BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Remove Product'),
          content: const Text('Are you sure you want to remove this product?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel',),
            ),
            TextButton(
              onPressed: () {
                final updatedCartItems = List<CartItemModel>.from(state.cartItems);
                updatedCartItems.removeAt(index);
                updateCart(updatedCartItems);

                Navigator.of(dialogContext).pop();
                Loaders.customToast(
                  message: 'Product removed from the Cart.',
                  context: context,
                );
              },
              child: const Text('Confirm', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void incrementProductQuantity() {
    emit(state.copyWith(
      productQuantityInCart: state.productQuantityInCart + 1,
    ));
  }

  void decrementProductQuantity() {
    if (state.productQuantityInCart > 0) {
      emit(state.copyWith(
        productQuantityInCart: state.productQuantityInCart - 1,
      ));
    }
  }

  void updateAlreadyAddedProductCount(ProductModel product, BuildContext context) {
    final VariationCubit variationCubit = context.read<VariationCubit>();

    if (product.productType == ProductType.single.name) {
      final count = getProductQuantityInCart(product.id);
      emit(state.copyWith(productQuantityInCart: count));
    } else {
      final variationId = variationCubit.state.selectedVariation.id;
      if (variationId.isNotEmpty) {
        final count = getVariationQuantityInCart(product.id, variationId);
        emit(state.copyWith(productQuantityInCart: count));
      } else {
        emit(state.copyWith(productQuantityInCart: 0));
      }
    }
  }

  int getProductQuantityInCart(String productId) {
    return state.cartItems
        .where((item) => item.productId == productId)
        .fold(0, (previousValue, element) => previousValue + element.quantity);
  }

  int getVariationQuantityInCart(String productId, String variationId) {
    final foundItem = state.cartItems.firstWhere(
          (item) => item.productId == productId && item.variationId == variationId,
      orElse: () => CartItemModel.empty(),
    );

    return foundItem.quantity;
  }

  void clearCart() {
    emit(state.copyWith(
      productQuantityInCart: 0,
      cartItems: [],
      totalCartPrice: 0.0,
      noOfCartItems: 0,
    ));
  }
}