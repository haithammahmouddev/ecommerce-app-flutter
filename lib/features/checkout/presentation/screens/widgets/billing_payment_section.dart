import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../common/widgets/custom_shapes/containers/rounded_container.dart';
import '../../../../../common/widgets/texts/section_heading.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../../utils/constants/sizes.dart';
import '../../../../../utils/helpers/helper_functions.dart';
import '../../controllers/checkout/checkout_cubit.dart';
import '../../controllers/checkout/checkout_state.dart';

class BillingPaymentSection extends StatelessWidget {
  const BillingPaymentSection({super.key});

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return BlocBuilder<CheckoutCubit, CheckoutState>(
      builder: (context, state) {
        return Column(
          children: [
            SectionHeading(
              title: 'Payment Method',
              buttonTitle: 'Change',
              onPressed: () => context.read<CheckoutCubit>().showPaymentMethodsModal(context),
            ),
            SizedBox(height: AppSizes.spaceBtwItems / 2),
            Row(
              children: [
                RoundedContainer(
                  width: 60.w,
                  height: 35.h,
                  backgroundColor: dark ? AppColors.white : AppColors.white,
                  padding: EdgeInsets.all(AppSizes.sm),
                  child: Image(
                    image: AssetImage(state.selectedPaymentMethod.image),
                    fit: BoxFit.contain,
                  ),
                ),
                SizedBox(width: AppSizes.spaceBtwItems / 2),
                Text(
                  state.selectedPaymentMethod.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}