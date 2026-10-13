import 'package:fit_store/features/home/presentation/controller/products_cubit/variation_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/widgets/chips/rounded_choice_chips.dart';
import '../../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../domain/entities/product_entity.dart';
import '../../../controller/products_cubit/variation_state.dart';

class ProductAttributes extends StatelessWidget {
  const ProductAttributes({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return BlocBuilder<VariationCubit, VariationState>(
      builder: (context, state) {
        return Column(
          children: [
            if (state.selectedVariation.id.isNotEmpty) ...[
              RoundedContainer(
                padding: EdgeInsets.all(AppSizes.md),
                backgroundColor: dark ? AppColors.darkerGrey : AppColors.grey,
                child: Column(
                  children: [
                    Row(
                      children: [
                        const SectionHeading(
                          title: 'Variation',
                          showActionButton: false,
                        ),
                        SizedBox(width: AppSizes.spaceBtwItems),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const ProductTitleText(
                                  title: 'Price : ',
                                  smallSize: true,
                                ),
                                if (state.selectedVariation.salePrice != null &&
                                    state.selectedVariation.salePrice! > 0) ...[
                                  Text(
                                    '\$${state.selectedVariation.price}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall!
                                        .apply(
                                      decoration:
                                      TextDecoration.lineThrough,
                                    ),
                                  ),
                                  SizedBox(width: AppSizes.spaceBtwItems),
                                ],
                                ProductPriceText(
                                  price: context
                                      .read<VariationCubit>()
                                      .getVariationPrice(),
                                ),
                              ],
                            ),
                            SizedBox(height: AppSizes.spaceBtwItems / 2),
                            Row(
                              children: [
                                const ProductTitleText(
                                  title: 'Stock : ',
                                  smallSize: true,
                                ),
                                Text(
                                  state.variationStockStatus,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.titleMedium,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),

                    SizedBox(height: AppSizes.spaceBtwItems),
                    ProductTitleText(
                      title: state.selectedVariation.description ?? '',
                      smallSize: true,
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              SizedBox(height: AppSizes.spaceBtwItems / 2),
            ],
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: product.productAttributes!.map((attribute) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionHeading(
                      title: attribute.name ?? '',
                      showActionButton: false,
                    ),
                    SizedBox(height: AppSizes.spaceBtwItems / 2),
                    Wrap(
                      spacing: 8.w,
                      children: attribute.values!.map((attributeValue) {
                        final isSelected =
                            state.selectedAttributes[attribute.name] ==
                                attributeValue;

                        final available = context
                            .read<VariationCubit>()
                            .getAttributesAvailabilityInVariation(
                          product.productVariations!,
                          attribute.name!,
                        )
                            .contains(attributeValue);

                        return TChoiceChip(
                          text: attributeValue,
                          selected: isSelected,
                          onSelected: available
                              ? (selected) {
                            if (selected && available) {
                              context
                                  .read<VariationCubit>()
                                  .onAttributeSelected(
                                context,
                                product,
                                attribute.name ?? '',
                                attributeValue,
                              );
                            }
                          }
                              : null,
                        );
                      }).toList(),
                    ),
                    SizedBox(height: AppSizes.spaceBtwItems),
                  ],
                );
              }).toList(),
            ),
          ],
        );
      },
    );
  }
}