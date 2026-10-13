import 'package:fit_store/features/home/presentation/controller/products_cubit/variation_cubit.dart';
import 'package:fit_store/features/home/presentation/controller/products_cubit/variation_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../../common/widgets/icons/circular_icon.dart';
import '../../../../../../utils/constants/colors.dart';
import '../../../../../../utils/constants/sizes.dart';
import '../../../../../../utils/helpers/helper_functions.dart';
import '../../../../../cart/presentation/controllers/cart/cart_cubit.dart';
import '../../../../../cart/presentation/controllers/cart/cart_state.dart';
import '../../../../data/model/product_model.dart';

class BottomAddToCart extends StatelessWidget {
  const BottomAddToCart({
    super.key,
    required this.product,
  });

  final ProductModel product;

  bool _isAvailable(VariationState variationState) {
    final isVariable = product.productType == 'variable';

    if (!isVariable) {
      return product.stock > 0;
    }

    if (variationState.isVariationFullySelected) {
      return variationState.selectedVariation.stock > 0;
    }

    final variations = product.productVariations ?? [];
    return variations.any((v) => v.stock > 0);
  }

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    context.read<CartCubit>().updateAlreadyAddedProductCount(product, context);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.defaultSpace,
        vertical: AppSizes.defaultSpace / 2,
      ),
      decoration: BoxDecoration(
        color: dark ? AppColors.darkerGrey : AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppSizes.cardRadiusLg),
          topRight: Radius.circular(AppSizes.cardRadiusLg),
        ),
      ),
      child: BlocBuilder<VariationCubit, VariationState>(
        builder: (context, variationState) {
          if (!_isAvailable(variationState)) {
            return const _UnavailableWarning();
          }

          return BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final cartCubit = context.read<CartCubit>();
              final quantity = state.productQuantityInCart;

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircularIcon(
                        icon: Iconsax.minus,
                        backgroundColor: AppColors.darkGrey,
                        width: 40.w,
                        height: 40.h,
                        color: AppColors.white,
                        onPressed: quantity < 1
                            ? null
                            : () => cartCubit.decrementProductQuantity(),
                      ),
                      SizedBox(width: AppSizes.spaceBtwItems),
                      Text(
                        '$quantity',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      SizedBox(width: AppSizes.spaceBtwItems),
                      CircularIcon(
                        icon: Iconsax.add,
                        backgroundColor: AppColors.black,
                        width: 40.w,
                        height: 40.h,
                        color: AppColors.white,
                        onPressed: () => cartCubit.incrementProductQuantity(),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: quantity < 1
                        ? null
                        : () => cartCubit.addToCart(product, context),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.all(AppSizes.md),
                      backgroundColor: AppColors.black,
                      foregroundColor: Colors.white,
                      disabledForegroundColor:
                      dark ? Colors.grey : Colors.black54,
                      side: const BorderSide(color: AppColors.black),
                    ),
                    child: const Text('Add to Cart'),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}

class _UnavailableWarning extends StatelessWidget {
  const _UnavailableWarning();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: AppSizes.md,
        vertical: AppSizes.md,
      ),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppSizes.cardRadiusMd),
        border: Border.all(color: Colors.red.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Iconsax.info_circle, color: Colors.red, size: 22.r),
          SizedBox(width: AppSizes.spaceBtwItems / 2),
          Flexible(
            child: Text(
              'This product is currently unavailable',
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .apply(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}