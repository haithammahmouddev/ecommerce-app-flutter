import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../../utils/constants/colors.dart';
import '../../../../utils/constants/sizes.dart';

class RoundedContainer extends StatelessWidget {
  RoundedContainer({
    super.key,
    this.child,
    this.width,
    this.height,
    this.margin,
    this.showBorder = false,
    EdgeInsetsGeometry? padding,
    this.borderColor = AppColors.borderPrimary,
    double? radius,
    this.backgroundColor = AppColors.white,
  })  : padding = padding ?? EdgeInsets.all(AppSizes.md),
        radius = radius ?? AppSizes.cardRadiusLg;

  final double? width;
  final double? height;
  final double radius;
  final EdgeInsetsGeometry padding;
  final EdgeInsets? margin;
  final Widget? child;
  final Color backgroundColor;
  final Color borderColor;
  final bool showBorder;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width?.w,
      height: height?.h,
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(radius.r),
        border: showBorder ? Border.all(color: borderColor) : null,
      ),
      child: child,
    );
  }
}