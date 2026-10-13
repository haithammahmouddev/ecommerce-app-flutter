import 'package:flutter/material.dart';

import '../../constants/colors.dart';

class AppBarThemeApp{
  AppBarThemeApp._();

  static const lightAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(color: AppColors.dark, size: 18.0),
    actionsIconTheme: IconThemeData(color: AppColors.dark, size: 18.0),
  );
  static const darkAppBarTheme = AppBarTheme(
    elevation: 0,
    centerTitle: true,
    backgroundColor: Colors.transparent,
    iconTheme: IconThemeData(color: AppColors.white, size: 18.0),
    actionsIconTheme: IconThemeData(color: AppColors.white, size: 18.0),
  );
}