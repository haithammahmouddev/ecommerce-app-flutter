import 'package:fit_store/utils/constants/colors.dart';
import 'package:fit_store/utils/constants/sizes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';

import '../../../../common/widgets/icons/circular_icon.dart';

class ProductQuantityWithAddRemoveButton extends StatelessWidget {
  ProductQuantityWithAddRemoveButton({
    super.key,
    required this.add,
    double? width,
    double? height,
    this.iconSize,
    required this.remove,
    required this.quantity,
    this.addBackgroundColor = AppColors.black,
    this.removeBackgroundColor = AppColors.darkGrey,
    this.addForegroundColor = AppColors.white,
    this.removeForegroundColor = AppColors.white,
  })  : width = width ?? 40.w,
        height = height ?? 40.h;

  final VoidCallback? add, remove;
  final int quantity;
  final double width, height;
  final double? iconSize;
  final Color addBackgroundColor, removeBackgroundColor;
  final Color addForegroundColor, removeForegroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        CircularIcon(
          icon: Iconsax.minus,
          onPressed: remove,
          width: width,
          height: height,
          size: iconSize,
          color: removeForegroundColor,
          backgroundColor: removeBackgroundColor,
        ),
        SizedBox(width: AppSizes.spaceBtwItems),
        Text(quantity.toString(), style: Theme.of(context).textTheme.titleSmall),
        SizedBox(width: AppSizes.spaceBtwItems),
        CircularIcon(
          icon: Iconsax.add,
          onPressed: add,
          width: width,
          height: height,
          size: iconSize,
          color: addForegroundColor,
          backgroundColor: addBackgroundColor,
        ),
      ],
    );
  }
}