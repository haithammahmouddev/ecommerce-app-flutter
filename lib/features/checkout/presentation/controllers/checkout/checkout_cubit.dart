import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/image_strings.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../data/models/payment_method_model.dart';
import '../../screens/widgets/payment_tile.dart';
import 'checkout_state.dart';

class CheckoutCubit extends Cubit<CheckoutState> {
  CheckoutCubit() : super(CheckoutState.initial());

  void selectPaymentMethod(PaymentMethodModel paymentMethod) {
    emit(state.copyWith(selectedPaymentMethod: paymentMethod));
  }

  Future<dynamic> showPaymentMethodsModal(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      builder: (_) => BlocProvider.value(
        value: this,
        child: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(AppSizes.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SectionHeading(
                  title: 'Select Payment Method',
                  showActionButton: false,
                ),
                SizedBox(height: AppSizes.spaceBtwSections),

                PaymentTile(
                  paymentMethod: PaymentMethodModel(name: 'Paypal', image: AppImages.paypal),
                ),
                SizedBox(height: AppSizes.spaceBtwItems / 2),

                PaymentTile(
                  paymentMethod: PaymentMethodModel(name: 'Credit Card', image: AppImages.creditCard),
                ),
                SizedBox(height: AppSizes.spaceBtwItems / 2),

                PaymentTile(
                  paymentMethod: PaymentMethodModel(name: 'Vodafone Cash', image: 'assets/icons/payment_methods/vc.png'),
                ),

                SizedBox(height: AppSizes.spaceBtwItems / 2),
                PaymentTile(
                  paymentMethod: PaymentMethodModel(name: 'Fawry', image: 'assets/icons/payment_methods/Fawry-Logo.jpg.webp'),
                ),
                SizedBox(height: AppSizes.spaceBtwItems / 2),
                PaymentTile(
                  paymentMethod: PaymentMethodModel(
                    name: 'InstaPay',
                    image: 'assets/icons/payment_methods/cee7c78a0483d165342d302ad395cf343be0fb861de76174e0d2a99e68bad6aa_600 (1).webp',
                  ),
                ),
                SizedBox(height: AppSizes.spaceBtwItems / 2),
              ],
            ),
          ),
        ),
      ),
    );
  }
}