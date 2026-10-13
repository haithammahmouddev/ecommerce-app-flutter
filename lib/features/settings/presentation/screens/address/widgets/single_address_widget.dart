import 'package:fit_store/common/widgets/custom_shapes/containers/rounded_container.dart';
import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../controllers/address/address_cubit.dart';
import '../../../../domain/entities/address_entity.dart';

class SingleAddress extends StatelessWidget {
  const SingleAddress({
    super.key,
    required this.address,
    required this.onTap,
  });

  final AddressEntity address;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);

    return BlocBuilder<AddressCubit, AddressState>(
      builder: (context, state) {
        final isSelected = state.selectedAddress?.id == address.id;
        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppSizes.cardRadiusLg.r),
          child: RoundedContainer(
            showBorder: true,
            padding: EdgeInsets.all(AppSizes.md),
            width: double.infinity,
            backgroundColor: isSelected
                ? AppColors.primary.withValues(alpha: 0.5)
                : Colors.transparent,
            borderColor: isSelected
                ? Colors.transparent
                : dark
                ? AppColors.darkerGrey
                : AppColors.grey,
            margin: EdgeInsets.only(bottom: AppSizes.spaceBtwItems),
            child: Stack(
              children: [
                Positioned(
                  right: 5.w,
                  top: 0,
                  child: Icon(
                    isSelected ? Iconsax.tick_circle5 : Iconsax.tick_circle,
                    color: isSelected
                        ? AppColors.primary
                        : dark
                        ? AppColors.darkerGrey
                        : AppColors.grey,
                    size: 24.r,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    SizedBox(height: AppSizes.sm / 2),
                    Text(
                      address.phoneNumber,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: AppSizes.sm / 2),
                    Text(
                      '${address.street}, ${address.city}, ${address.state}, ${address.country}',
                      softWrap: true,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}