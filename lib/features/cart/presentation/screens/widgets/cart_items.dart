import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/texts/product_price_text.dart';
import '../../controllers/cart/cart_cubit.dart';
import '../../controllers/cart/cart_state.dart';
import '../add_remove_cart_button.dart';
import '../cart_item.dart';

class CartItems extends StatelessWidget {
  const CartItems({
    super.key,
    this.showAddRemoveButtons = true,
  });

  final bool showAddRemoveButtons;

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final cartCubit = context.read<CartCubit>();
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: state.cartItems.length,
          separatorBuilder: (_, __) =>
              SizedBox(height: AppSizes.spaceBtwSections),
          itemBuilder: (_, index) {
            final item = state.cartItems[index];

            return Column(
              children: [
                CartItem(item: item, index: index),

                if (showAddRemoveButtons)
                  SizedBox(height: AppSizes.spaceBtwItems),

                if (showAddRemoveButtons)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          SizedBox(width: 70.w),
                          ProductQuantityWithAddRemoveButton(
                            quantity: item.quantity,
                            add: () => cartCubit.addOneToCart(item),
                            remove: () => cartCubit.removeOneFromCart(item, context),
                          ),
                        ],
                      ),
                      ProductPriceText(
                        price: (item.price * item.quantity).toStringAsFixed(1),
                      ),
                    ],
                  ),
              ],
            );
          },
        );
      },
    );
  }
}