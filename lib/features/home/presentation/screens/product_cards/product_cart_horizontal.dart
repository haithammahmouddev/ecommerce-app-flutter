import 'package:fit_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/images/rounded_image.dart';
import '../../../../../common/widgets/texts/brand_title_text_with_verified_icon.dart';
import '../../../../../common/widgets/texts/product_title_text.dart';
import '../../../../favourites/presentation/screens/widgets/favourite_icon.dart';
import '../../controller/products_cubit/products_cubit.dart';
import '../product_detail/product_detail.dart';

class ProductCardHorizontal extends StatelessWidget {
  const ProductCardHorizontal({super.key, required this.product});

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    final productsCubit = context.read<ProductsCubit>();

    final bool isVariable =
        product.productVariations != null && product.productVariations!.isNotEmpty;

    final bool isOutOfStock = isVariable
        ? (product.productVariations == null ||
        product.productVariations!.every((v) => v.stock <= 0))
        : product.stock <= 0;

    final String displayPrice = productsCubit.getProductPrice(product);

    bool hasDiscount = false;
    String? salePercentage;

    if (isVariable) {
      Set<int> percentages = {};
      for (var v in product.productVariations!) {
        if (v.salePrice != null && v.salePrice! > 0 && v.salePrice! < v.price) {
          hasDiscount = true;
          int pct = (((v.price - v.salePrice!) / v.price) * 100).round();
          percentages.add(pct);
        }
      }
      if (hasDiscount && percentages.isNotEmpty) {
        var sorted = percentages.toList()..sort();
        if (sorted.length == 1 || sorted.first == sorted.last) {
          salePercentage = '${sorted.first}%';
        } else {
          salePercentage = '${sorted.first}% - ${sorted.last}%';
        }
      }
    } else {
      hasDiscount = product.salePrice != null &&
          product.salePrice! > 0 &&
          product.salePrice! < product.price;
      if (hasDiscount) {
        salePercentage = productsCubit.calculateSalePercentage(product.price, product.salePrice);
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (_) {
          return BlocProvider.value(
            value: context.read<ProductsCubit>(),
            child: ProductDetailScreen(product: product),
          );
        }));
      },
      child: Container(
        width: 322.w,
        padding: EdgeInsets.all(1.r),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppSizes.productImageRadius),
          color: dark ? AppColors.darkerGrey : AppColors.softGrey,
        ),
        child: Stack(
          children: [
            Row(
              children: [
                RoundedContainer(
                  height: 120.h,
                  padding: EdgeInsets.all(AppSizes.sm),
                  backgroundColor: dark ? AppColors.dark : AppColors.lightGrey,
                  child: Stack(
                    children: [
                      SizedBox(
                        height: 120.h,
                        width: 120.w,
                        child: RoundedImage(
                          imageUrl: product.thumbnail,
                          applyImageRadius: true,
                          isNetworkImage: true,
                        ),
                      ),
                      if (!isOutOfStock && salePercentage != null && salePercentage.isNotEmpty)
                        Positioned(
                          top: 1.h,
                          left: 0,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: 75.w),
                            child: RoundedContainer(
                              radius: AppSizes.sm,
                              backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                              padding: EdgeInsets.symmetric(
                                horizontal: AppSizes.xs,
                                vertical: AppSizes.xs,
                              ),
                              child: Text(
                                salePercentage.endsWith('%')
                                    ? salePercentage
                                    : '$salePercentage%',
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .apply(color: AppColors.black),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(top: AppSizes.sm, left: AppSizes.sm),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            ProductTitleText(
                              title: product.title,
                              smallSize: true,
                            ),
                            SizedBox(height: AppSizes.spaceBtwItems / 2),
                            if (product.brand != null)
                              BrandTitleWithVerifiedIcon(title: product.brand!.name),
                          ],
                        ),
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Flexible(
                              child: isOutOfStock
                                  ? Padding(
                                padding: EdgeInsets.only(left: AppSizes.xs),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Iconsax.danger,
                                      color: Colors.red,
                                      size: 14.r,
                                    ),
                                    SizedBox(width: 4.w),
                                    Text(
                                      'unavailable',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall!
                                          .apply(color: Colors.red),
                                    ),
                                  ],
                                ),
                              )
                                  : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (!isVariable && hasDiscount)
                                    Padding(
                                      padding: EdgeInsets.only(left: AppSizes.xs),
                                      child: Text(
                                        '\$${product.price}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelMedium!
                                            .apply(
                                          decoration: TextDecoration.lineThrough,
                                        ),
                                      ),
                                    ),
                                  Padding(
                                    padding: EdgeInsets.only(left: AppSizes.xs),
                                    child: Text(
                                      displayPrice,
                                      style: Theme.of(context).textTheme.titleMedium!.apply(
                                        color: dark ? AppColors.white : AppColors.dark,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              decoration: BoxDecoration(
                                color: AppColors.dark,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(AppSizes.cardRadiusMd),
                                  bottomRight: Radius.circular(
                                    AppSizes.productImageRadius,
                                  ),
                                ),
                              ),
                              child: SizedBox(
                                width: AppSizes.iconLg * 1.2,
                                height: AppSizes.iconLg * 1.2,
                                child: const Center(
                                  child: Icon(Iconsax.add, color: AppColors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              top: 30.h,
              right: 0,
              child: FavouriteIcon(productId: product.id),
            ),
          ],
        ),
      ),
    );
  }
}