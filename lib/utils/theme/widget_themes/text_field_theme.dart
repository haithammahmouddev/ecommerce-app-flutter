import 'package:flutter/material.dart';

import '../../constants/colors.dart';
import '../../constants/sizes.dart';

class TextFormFieldThemeApp {
  TextFormFieldThemeApp._();

  static final InputDecorationTheme lightInputDecorationTheme = InputDecorationTheme(
    prefixIconColor: AppColors.secondary,
    floatingLabelStyle: const TextStyle(color: AppColors.secondary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      borderSide: const BorderSide(width: 2, color: AppColors.secondary),
    ),
  );

  static final InputDecorationTheme darkInputDecorationTheme = InputDecorationTheme(
    prefixIconColor: AppColors.primary,
    floatingLabelStyle: const TextStyle(color: AppColors.primary),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.borderRadiusLg),
      borderSide: const BorderSide(width: 2, color: AppColors.primary),
    ),
  );
}
