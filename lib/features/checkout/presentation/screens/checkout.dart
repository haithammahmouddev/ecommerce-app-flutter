import 'package:fit_store/common/widgets/appbar/home_appbar.dart';
import 'package:fit_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:fit_store/features/checkout/presentation/screens/widgets/billing_address_section.dart';
import 'package:fit_store/features/checkout/presentation/screens/widgets/billing_payment_section.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/helpers/helper_functions.dart';
import 'package:fit_store/utils/helpers/pricing_calculator.dart';
import 'package:fit_store/utils/popups/loaders.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../common/di/injection_container.dart';
import '../../../cart/presentation/controllers/cart/cart_cubit.dart';
import '../../../cart/presentation/controllers/cart/cart_state.dart';
import '../../../cart/presentation/screens/widgets/cart_items.dart';
import '../../../settings/presentation/controllers/order/order_cubit.dart';
import '../controllers/checkout/checkout_cubit.dart';
import 'billing_amount_section.dart';

class CheckoutScreen extends StatelessWidget {
  const CheckoutScreen({super.key});
  static const String routeName = '/checkout-screen';

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return BlocProvider(
      create: (_) => sl<CheckoutCubit>(),
      child: Scaffold(
        appBar: const EComAppBar(
          title: Text('Order Review'),
          showBackArrow: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(AppSizes.defaultSpace),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CartItems(showAddRemoveButtons: false),
                SizedBox(height: AppSizes.spaceBtwSections * 0.8),
                RoundedContainer(
                  borderColor: AppColors.dashboardAppbarBackground,
                  showBorder: true,
                  padding: EdgeInsets.all(AppSizes.md),
                  backgroundColor: dark ? AppColors.black : AppColors.white,
                  child: Column(
                    children: [
                      const BillingAmountSection(),
                      SizedBox(height: AppSizes.spaceBtwItems),

                      const Divider(),
                      SizedBox(height: AppSizes.spaceBtwItems),

                      const BillingPaymentSection(),
                      SizedBox(height: AppSizes.spaceBtwSections),

                      const BillingAddressSection(),
                    ],
                  ),
                ),
                SizedBox(height: AppSizes.spaceBtwSections),
              ],
            ),
          ),
        ),

        bottomNavigationBar: BlocBuilder<CartCubit, CartState>(
          builder: (context, cartState) {
            final subTotal = cartState.totalCartPrice;
            final totalAmount = PricingCalculator.calculateTotalPrice(
              subTotal,
              'US',
            );

            return Padding(
              padding: EdgeInsets.all(AppSizes.defaultSpace),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: subTotal > 0
                      ? () {
                    context.read<OrderCubit>().processOrder(
                      context: context,
                      totalAmount: totalAmount,
                    );
                  }
                      : () {
                    Loaders.warningSnackBar(
                      title: 'Empty Cart',
                      message:
                      'Add items in the cart in order to proceed.',
                      context: context,
                    );
                  },
                  child: Text('Checkout \$$totalAmount'),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}