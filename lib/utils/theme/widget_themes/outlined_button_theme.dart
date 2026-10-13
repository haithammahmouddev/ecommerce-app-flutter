import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class OutlinedButtonThemeApp {
  OutlinedButtonThemeApp._();

  static final lightOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.secondary,
      side: BorderSide(color: AppColors.secondary),
      padding: EdgeInsets.symmetric(vertical: AppSizes.buttonHeight.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg.r),
      ),
    ),
  );

  static final darkOutlinedButtonTheme = OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.white,
      side: BorderSide(color: AppColors.white),
      padding: EdgeInsets.symmetric(vertical: AppSizes.buttonHeight.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg.r),
      ),
    ),
  );
}