import 'package:fit_store/features/cart/presentation/screens/cart.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax/iconsax.dart';
import '../controllers/cart/cart_cubit.dart';
import '../controllers/cart/cart_state.dart';

class CartCounterIcon extends StatelessWidget {
  const CartCounterIcon({
    super.key,
    this.iconColor,
    this.counterBgColor,
    this.counterTextColor,
  });

  final Color? iconColor;
  final Color? counterBgColor;
  final Color? counterTextColor;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return Stack(
      children: [
        IconButton(
          onPressed: () => Navigator.pushNamed(
            context,
            CartScreen.routeName,
          ),
          icon: Icon(
            Iconsax.shopping_bag,
            color: iconColor,
          ),
        ),
        Positioned(
          right: 0,
          child: Container(
            width: AppSizes.fontSizeLg,
            height: AppSizes.fontSizeLg,
            decoration: BoxDecoration(
              color: counterBgColor ?? (dark ? AppColors.white : AppColors.black),
              borderRadius: BorderRadius.circular(100),
            ),
            child: Center(
              child: BlocBuilder<CartCubit, CartState>(
                buildWhen: (previous, current) =>
                previous.noOfCartItems != current.noOfCartItems,
                builder: (context, state) {
                  return Text(
                    state.noOfCartItems.toString(),
                    style: Theme.of(context).textTheme.labelLarge!.apply(
                      color: counterTextColor ??
                          (dark ? AppColors.black : AppColors.white),
                      fontSizeFactor: 0.8,
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }
}