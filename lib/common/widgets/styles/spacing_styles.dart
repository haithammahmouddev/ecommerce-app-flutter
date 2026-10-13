import 'package:flutter/material.dart';

import '../../../utils/constants/sizes.dart';

class SpacingStyle {
  static final EdgeInsetsGeometry paddingWithAppBarHeight = EdgeInsets.only(
    top: AppSizes.appBarHeight,
    left: AppSizes.defaultSpace,
    bottom: AppSizes.defaultSpace,
    right: AppSizes.defaultSpace,
  );

  static final EdgeInsetsGeometry paddingWithDefaultWidth = EdgeInsets.only(
    left: AppSizes.defaultSpace,
    right: AppSizes.defaultSpace,
  );

  static final EdgeInsetsGeometry paddingOnlyVertical = EdgeInsets.symmetric(
    vertical: AppSizes.defaultSpace,
  );

  static final EdgeInsetsGeometry paddingWithDefaultHeight = EdgeInsets.only(
    top: AppSizes.defaultSpace,
    left: AppSizes.defaultSpace,
    bottom: AppSizes.defaultSpace,
    right: AppSizes.defaultSpace,
  );
}