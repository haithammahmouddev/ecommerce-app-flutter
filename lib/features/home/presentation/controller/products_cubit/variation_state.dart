import 'package:equatable/equatable.dart';
import 'package:fit_store/features/home/domain/entities/product_variation_entity.dart';


class VariationState extends Equatable {
  final Map<String, dynamic> selectedAttributes;
  final String variationStockStatus;
  final ProductVariationEntity selectedVariation;
  final bool isVariationFullySelected;

  const VariationState({
    required this.selectedAttributes,
    required this.variationStockStatus,
    required this.selectedVariation,
    this.isVariationFullySelected = false,
  });

  factory VariationState.initial() {
    return VariationState(
      selectedAttributes: const {},
      variationStockStatus: '',
      selectedVariation: ProductVariationEntity.empty(),
      isVariationFullySelected: false,
    );
  }

  VariationState copyWith({
    Map<String, dynamic>? selectedAttributes,
    String? variationStockStatus,
    ProductVariationEntity? selectedVariation,
    bool? isVariationFullySelected,
  }) {
    return VariationState(
      selectedAttributes: selectedAttributes ?? this.selectedAttributes,
      variationStockStatus: variationStockStatus ?? this.variationStockStatus,
      selectedVariation: selectedVariation ?? this.selectedVariation,
      isVariationFullySelected: isVariationFullySelected ?? this.isVariationFullySelected,
    );
  }

  @override
  List<Object?> get props =>
      [selectedAttributes, variationStockStatus, selectedVariation, isVariationFullySelected];
}