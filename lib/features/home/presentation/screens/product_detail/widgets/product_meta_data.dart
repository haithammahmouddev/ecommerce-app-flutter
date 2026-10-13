import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/variation_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/variation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../../common/widgets/images/circular_image.dart';
import '../../../../../../common/widgets/texts/brand_title_text_with_verified_icon.dart';
import '../../../../../../common/widgets/texts/product_price_text.dart';
import '../../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/enums.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../domain/entities/product_entity.dart';

class ProductMetaData extends StatelessWidget {
  const ProductMetaData({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final ProductsCubit productsCubit = context.read<ProductsCubit>();

    return BlocBuilder<VariationCubit, VariationState>(
      builder: (context, variationState) {
        final bool isSelected = variationState.isVariationFullySelected;
        final bool isVariable =
            product.productVariations != null &&
                product.productVariations!.isNotEmpty;

        final double effectivePrice = isSelected
            ? variationState.selectedVariation.price
            : product.price;

        final double? effectiveSalePrice = isSelected
            ? variationState.selectedVariation.salePrice
            : product.salePrice;

        final bool hasSale = isSelected
            ? (effectiveSalePrice != null &&
            effectiveSalePrice > 0 &&
            effectiveSalePrice < effectivePrice)
            : (isVariable
            ? product.productVariations!.any(
              (v) =>
          v.salePrice != null &&
              v.salePrice! > 0 &&
              v.salePrice! < v.price,
        )
            : (product.salePrice != null &&
            product.salePrice! > 0 &&
            product.salePrice! < product.price));

        String? salePercentage;
        if (isSelected) {
          if (hasSale) {
            salePercentage = productsCubit.calculateSalePercentage(
              effectivePrice,
              effectiveSalePrice,
            );
          }
        } else if (isVariable) {
          Set<int> percentages = {};
          for (var v in product.productVariations!) {
            if (v.salePrice != null &&
                v.salePrice! > 0 &&
                v.salePrice! < v.price) {
              int pct = (((v.price - v.salePrice!) / v.price) * 100).round();
              percentages.add(pct);
            }
          }
          if (percentages.isNotEmpty) {
            var sorted = percentages.toList()..sort();
            if (sorted.length == 1 || sorted.first == sorted.last) {
              salePercentage = '${sorted.first}%';
            } else {
              salePercentage = '${sorted.first}% - ${sorted.last}%';
            }
          }
        } else {
          if (hasSale) {
            salePercentage = productsCubit.calculateSalePercentage(
              product.price,
              product.salePrice,
            );
          }
        }

        final String finalDisplayPrice = isSelected
            ? (effectiveSalePrice != null && effectiveSalePrice > 0
            ? effectiveSalePrice.toString()
            : effectivePrice.toString())
            : productsCubit.getProductPrice(product);

        final bool showPercentageAbove = isVariable && !isSelected;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPercentageAbove &&
                salePercentage != null &&
                salePercentage.isNotEmpty) ...[
              RoundedContainer(
                backgroundColor: AppColors.primary,
                radius: AppSizes.sm,
                padding: EdgeInsets.symmetric(
                  horizontal: AppSizes.sm,
                  vertical: AppSizes.xs,
                ),
                child: Text(
                  salePercentage.endsWith('%')
                      ? salePercentage
                      : '$salePercentage%',
                  style: Theme.of(
                    context,
                  ).textTheme.labelLarge!.apply(color: AppColors.black),
                ),
              ),
              SizedBox(height: AppSizes.spaceBtwItems / 2),
            ],

            Row(
              children: [
                if (!showPercentageAbove &&
                    salePercentage != null &&
                    salePercentage.isNotEmpty &&
                    hasSale) ...[
                  RoundedContainer(
                    backgroundColor: AppColors.primary,
                    radius: AppSizes.sm,
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSizes.sm,
                      vertical: AppSizes.xs,
                    ),
                    child: Text(
                      salePercentage.endsWith('%')
                          ? salePercentage
                          : '$salePercentage%',
                      style: Theme.of(
                        context,
                      ).textTheme.labelLarge!.apply(color: AppColors.black),
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceBtwItems),
                ],

                if (hasSale) ...[
                  Text(
                    isSelected
                        ? '\$$effectivePrice'
                        : productsCubit.getProductOriginalPriceRange(product),
                    style: Theme.of(context).textTheme.titleSmall!.apply(
                      decoration: TextDecoration.lineThrough,
                    ),
                  ),
                  SizedBox(width: AppSizes.spaceBtwItems),
                ],

                ProductPriceText(price: finalDisplayPrice, isLarge: true),
              ],
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 1.5),
            ProductTitleText(title: product.title),
            SizedBox(height: AppSizes.spaceBtwItems / 1.5),
            Row(
              children: [
                const ProductTitleText(title: 'Stock : ', smallSize: true),
                Text(
                  isSelected
                      ? variationState.variationStockStatus
                      : productsCubit.getProductStockStatus(product.stock),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),
            Row(
              spacing: 3.w,
              children: [
                CircularImage(
                  image: product.brand != null ? product.brand!.image : '',
                  width: 35.w,
                  height: 35.h,
                  padding: 4.r,
                  isNetworkImage: true,
                  fit: BoxFit.contain,
                  backgroundColor: Colors.white,
                ),
                BrandTitleWithVerifiedIcon(
                  title: product.brand != null ? product.brand!.name : '',
                  brandTextSize: TextSizes.medium,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}