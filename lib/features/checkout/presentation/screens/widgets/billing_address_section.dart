import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fit_store/common/widgets/texts/section_heading.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import '../../../../settings/presentation/controllers/address/address_cubit.dart';

class BillingAddressSection extends StatelessWidget {
  const BillingAddressSection({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final selectedAddress = state.selectedAddress;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionHeading(
              title: 'Shipping Address',
              buttonTitle: 'Change',
              showActionButton: true,
              onPressed: () => context.read<AddressCubit>().selectNewAddressPopup(context),
            ),
            selectedAddress.id.isNotEmpty
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  selectedAddress.name,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: AppSizes.spaceBtwItems / 2),
                Row(
                  children: [
                    Icon(Icons.phone, color: Colors.grey, size: 16.r),
                    SizedBox(width: AppSizes.spaceBtwItems),
                    Text(
                      selectedAddress.phoneNumber,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                SizedBox(height: AppSizes.spaceBtwItems / 2),
                Row(
                  children: [
                    Icon(Icons.location_history, color: Colors.grey, size: 16.r),
                    SizedBox(width: AppSizes.spaceBtwItems),
                    Expanded(
                      child: Text(
                        selectedAddress.toString(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        softWrap: true,
                      ),
                    ),
                  ],
                ),
              ],
            )
                : Text(
              'Select Address',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        );
      },
    );
  }
}