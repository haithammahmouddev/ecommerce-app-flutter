import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class ElevatedButtonThemeApp {
  ElevatedButtonThemeApp._();

  static final lightElevatedButtonTheme  = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.white,
      backgroundColor: AppColors.dark,
      side: BorderSide(color: AppColors.dark),
      padding: EdgeInsets.symmetric(vertical: AppSizes.buttonHeight.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg.r),
      ),
    ),
  );

  static final darkElevatedButtonTheme = ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      elevation: 0,
      foregroundColor: AppColors.dark,
      backgroundColor: AppColors.primary,
      side: BorderSide(color: AppColors.primary),
      padding: EdgeInsets.symmetric(vertical: AppSizes.buttonHeight.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg.r),
      ),
    ),
  );
}