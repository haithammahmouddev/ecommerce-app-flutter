import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/helpers/pricing_calculator.dart';
import '../../../cart/presentation/controllers/cart/cart_cubit.dart';
import '../../../cart/presentation/controllers/cart/cart_state.dart';

class BillingAmountSection extends StatelessWidget {
  const BillingAmountSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final subTotal = state.totalCartPrice;

        return Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Subtotal', style: Theme.of(context).textTheme.bodyMedium),
                Text('\$$subTotal', style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Shipping Fee', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '\$${PricingCalculator.calculateShippingCost(subTotal, 'US')}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Tax Fee', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '\$${PricingCalculator.calculateTax(subTotal, 'US')}',
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ],
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Order Total', style: Theme.of(context).textTheme.bodyMedium),
                Text(
                  '\$${PricingCalculator.calculateTotalPrice(subTotal, 'US')}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}