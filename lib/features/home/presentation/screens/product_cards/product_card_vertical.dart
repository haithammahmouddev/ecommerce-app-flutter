import 'package:fit_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:fit_store/common/widgets/styles/shadows.dart';
import 'package:fit_store/features/home/domain/entities/product_entity.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/products_cubit.dart';
import 'package:fit_store/features/home/presentation/screens/product_detail/product_detail.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/enums.dart';
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
import '../widgets/product_card_add_to_cart_button.dart';

class ProductCardVertical extends StatelessWidget {
  const ProductCardVertical({
    super.key,
    required this.product,
  });

  final ProductEntity product;

  @override
  Widget build(BuildContext context) {
    final productsCubit = context.read<ProductsCubit>();
    final dark = HelperFunctions.isDarkMode(context);

    final bool isVariable =
        product.productVariations != null && product.productVariations!.isNotEmpty;

    final bool isOutOfStock = isVariable
        ? (product.productVariations == null ||
        product.productVariations!.every((v) => v.stock <= 0))
        : product.stock <= 0;

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
        width: 180.w,
        padding: EdgeInsets.all(1.r),
        decoration: BoxDecoration(
          boxShadow: [ShadowStyle.verticalProductShadow],
          borderRadius: BorderRadius.circular(AppSizes.productImageRadius),
          color: dark ? AppColors.darkerGrey : AppColors.white,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RoundedContainer(
              height: 180.h,
              width: 180.w,
              padding: EdgeInsets.all(AppSizes.sm),
              backgroundColor: dark ? AppColors.dark : AppColors.white,
              child: Stack(
                children: [
                  Center(
                    child: RoundedImage(
                      isNetworkImage: true,
                      imageUrl: product.thumbnail,
                      applyImageRadius: true,
                    ),
                  ),
                  if (!isOutOfStock && salePercentage != null && salePercentage.isNotEmpty)
                    Positioned(
                      top: 12.h,
                      child: RoundedContainer(
                        radius: AppSizes.sm,
                        backgroundColor: AppColors.primary.withValues(alpha: 0.8),
                        padding: EdgeInsets.symmetric(
                          horizontal: AppSizes.sm,
                          vertical: AppSizes.xs,
                        ),
                        child: Text(
                          salePercentage.endsWith('%')
                              ? salePercentage
                              : '$salePercentage%',
                          style: Theme.of(context)
                              .textTheme
                              .labelLarge!
                              .apply(color: AppColors.black),
                        ),
                      ),
                    ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: FavouriteIcon(productId: product.id),
                  ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),
            Padding(
              padding: EdgeInsets.only(left: AppSizes.sm),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ProductTitleText(
                    title: product.title,
                    smallSize: true,
                    maxLines: 1,
                  ),
                  SizedBox(height: AppSizes.spaceBtwItems / 2),
                  if (product.brand != null)
                    BrandTitleWithVerifiedIcon(
                      title: product.brand!.name,
                      brandTextSize: TextSizes.small,
                    ),
                ],
              ),
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: isOutOfStock
                      ? Padding(
                    padding: EdgeInsets.only(left: AppSizes.sm),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Iconsax.danger,
                          color: Colors.red,
                          size: 16.r,
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
                          padding: EdgeInsets.only(left: AppSizes.sm),
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
                        padding: EdgeInsets.only(left: AppSizes.sm),
                        child: Text(
                          productsCubit.getProductPrice(product),
                          style: Theme.of(context).textTheme.titleMedium!.apply(
                            color: AppColors.dark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                ProductCardAddToCartButton(product: product.toModel()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}