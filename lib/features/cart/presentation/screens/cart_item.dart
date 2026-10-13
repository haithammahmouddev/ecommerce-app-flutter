import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:fit_store/utils/helpers/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../common/widgets/images/rounded_image.dart';
import '../../../../common/widgets/texts/brand_title_text_with_verified_icon.dart';
import '../../../../common/widgets/texts/product_title_text.dart';
import '../../data/models/cart_item_model.dart';
import '../controllers/cart/cart_cubit.dart';

class CartItem extends StatelessWidget {
  const CartItem({super.key, required this.item, required this.index});

  final CartItemModel item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final dark = HelperFunctions.isDarkMode(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RoundedImage(
          width: 80.w,
          height: 80.h,
          imageUrl: item.image ?? '',
          isNetworkImage: true,
          padding: EdgeInsets.all(AppSizes.sm),
          backgroundColor: dark ? AppColors.darkerGrey : AppColors.lightGrey,
        ),
        SizedBox(width: AppSizes.spaceBtwItems),
        Expanded(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 15.h),
              BrandTitleWithVerifiedIcon(title: item.brandName ?? ''),
              Flexible(
                child: ProductTitleText(title: item.title, maxLines: 1),
              ),
              Text.rich(
                TextSpan(
                  children: (item.selectedVariation ?? {}).entries
                      .map(
                        (e) => TextSpan(
                      children: [
                        TextSpan(
                          text: ' ${e.key} ',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        TextSpan(
                          text: '${e.value} ',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  )
                      .toList(),
                ),
              ),
            ],
          ),
        ),

        IconButton(
          onPressed: () {
            context.read<CartCubit>().removeFromCartDialog(index, context);
          },
          padding: EdgeInsets.zero,
          icon: Icon(Iconsax.trash, color: Colors.red, size: 20.r),
        ),
      ],
    );
  }
}