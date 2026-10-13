import 'package:fit_store/features/home/data/model/product_model.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../cart/presentation/controllers/cart/cart_cubit.dart';
import '../../../../cart/presentation/controllers/cart/cart_state.dart';

class ProductCardAddToCartButton extends StatelessWidget {
  const ProductCardAddToCartButton({
    super.key,
    required this.product,
  });

  final ProductModel product;

  @override
  Widget build(BuildContext context) {
    final cartCubit = context.read<CartCubit>();

    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final productQuantityInCart = cartCubit.getProductQuantityInCart(product.id);

        return Container(
          decoration: BoxDecoration(
            color: productQuantityInCart > 0 ? AppColors.primary : AppColors.dark,
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
            child: Center(
              child: productQuantityInCart > 0
                  ? Text(
                productQuantityInCart.toString(),
                style: Theme.of(context)
                    .textTheme
                    .bodyLarge!
                    .apply(color: AppColors.white),
              )
                  : const Icon(
                Iconsax.add,
                color: AppColors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}