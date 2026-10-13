import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/variation_state.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../cart/presentation/controllers/cart/cart_cubit.dart';
import '../../../domain/entities/product_variation_entity.dart';
import 'images_cubit.dart';

class VariationCubit extends Cubit<VariationState> {
  VariationCubit() : super(VariationState.initial());

  List<ProductVariationEntity> _allVariations = [];

  void onAttributeSelected(
      BuildContext context, ProductEntity product, attributeName, attributeValue) {
    _allVariations = product.productVariations ?? [];

    final selectedAttributes = Map<String, dynamic>.from(state.selectedAttributes);
    selectedAttributes[attributeName] = attributeValue;

    emit(state.copyWith(selectedAttributes: selectedAttributes));

    final selectedVariation = _allVariations.firstWhere(
          (variation) => _isSameAttributeValues(variation.attributeValues, selectedAttributes),
      orElse: () => ProductVariationEntity.empty(),
    );

    final isFullySelected = selectedVariation.id.isNotEmpty;

    if (selectedVariation.image.isNotEmpty) {
      context.read<ImagesCubit>().setSelectedProductImage(selectedVariation.image);
    }

    if (isFullySelected) {
      final cartCubit = context.read<CartCubit>();
      cartCubit.updateProductQuantityInCart(
        cartCubit.getVariationQuantityInCart(product.id, selectedVariation.id),
      );
    }

    emit(state.copyWith(
      selectedVariation: selectedVariation,
      isVariationFullySelected: isFullySelected,
    ));

    getProductVariationStockStatus();
  }

  bool _isSameAttributeValues(
      Map<String, dynamic> variationAttributes, Map<String, dynamic> selectedAttributes) {
    if (variationAttributes.length != selectedAttributes.length) return false;
    for (final key in variationAttributes.keys) {
      final variationValue = variationAttributes[key]?.toString().trim().toLowerCase();
      final selectedValue = selectedAttributes[key]?.toString().trim().toLowerCase();

      if (variationValue != selectedValue) return false;
    }

    return true;
  }

  Set<String?> getAttributesAvailabilityInVariation(
      List<ProductVariationEntity> variations, String attributeName) {
    final availableVariationAttributeValues = variations
        .where((variation) =>
    variation.attributeValues[attributeName] != null &&
        variation.attributeValues[attributeName]!.isNotEmpty &&
        variation.stock > 0)
        .map((variation) => variation.attributeValues[attributeName]!)
        .toSet();

    return availableVariationAttributeValues;
  }

  String getVariationPrice() {
    if (state.isVariationFullySelected) {
      final v = state.selectedVariation;
      return (v.salePrice != null && v.salePrice! > 0 ? v.salePrice : v.price).toString();
    }

    if (_allVariations.isEmpty) return '0';

    double min = double.infinity;
    double max = 0;
    for (final v in _allVariations) {
      final effective = (v.salePrice != null && v.salePrice! > 0) ? v.salePrice! : v.price;
      if (effective < min) min = effective;
      if (effective > max) max = effective;
    }

    return min == max ? min.toString() : '$min - $max';
  }

  void getProductVariationStockStatus() {
    if (!state.isVariationFullySelected) {
      emit(state.copyWith(variationStockStatus: 'Select options'));
      return;
    }
    final isAvailable = state.selectedVariation.stock > 0;
    final status = isAvailable ? 'In Stock' : 'Out of Stock';
    emit(state.copyWith(variationStockStatus: status));
  }

  void resetSelectedAttributes() {
    _allVariations = [];
    emit(state.copyWith(
      selectedAttributes: const {},
      variationStockStatus: '',
      selectedVariation: ProductVariationEntity.empty(),
      isVariationFullySelected: false,
    ));
  }
}