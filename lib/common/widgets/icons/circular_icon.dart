import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../utils/constants/colors.dart';
import '../../../utils/constants/sizes.dart';
import '../../../utils/helpers/helper_functions.dart';

class CircularIcon extends StatelessWidget {
  CircularIcon({
    super.key,
    required this.icon,
    this.width,
    this.height,
    double? size,
    this.onPressed,
    this.color,
    this.backgroundColor,
  }) : size = size ?? AppSizes.lg;

  final double? width, height, size;
  final IconData icon;
  final Color? color;
  final Color? backgroundColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height?.h,
      decoration: BoxDecoration(
        color: backgroundColor != null
            ? backgroundColor!
            : HelperFunctions.isDarkMode(context)
            ? AppColors.black.withValues(alpha: 0.9)
            : AppColors.white.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: color, size: size?.r),
      ),
    );
  }
}