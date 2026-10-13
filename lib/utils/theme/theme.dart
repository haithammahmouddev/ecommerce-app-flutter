
import 'package:fit_store/utils/theme/widget_themes/bottom_sheet_theme.dart';
import 'package:fit_store/utils/theme/widget_themes/checkbox_theme.dart';
import 'package:fit_store/utils/theme/widget_themes/chip_theme.dart';
import 'package:flutter/material.dart';
import 'widget_themes/appbar_theme.dart';
import 'widget_themes/elevated_button_theme.dart';
import 'widget_themes/outlined_button_theme.dart';
import 'widget_themes/text_field_theme.dart';
import 'widget_themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    brightness: Brightness.light,
    textTheme: TextThemeApp.lightTextTheme,
    appBarTheme: AppBarThemeApp.lightAppBarTheme,
    elevatedButtonTheme: ElevatedButtonThemeApp.lightElevatedButtonTheme,
    outlinedButtonTheme: OutlinedButtonThemeApp.lightOutlinedButtonTheme,
    inputDecorationTheme: TextFormFieldThemeApp.lightInputDecorationTheme,
    checkboxTheme: CheckboxThemeApp.rightCheckboxTheme,
    chipTheme: ChipThemeApp.rightChipTheme,
    bottomSheetTheme: BottomSheetThemeApp.rightBottomSheetTheme,
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    textTheme: TextThemeApp.darkTextTheme,
    appBarTheme: AppBarThemeApp.darkAppBarTheme,
    elevatedButtonTheme: ElevatedButtonThemeApp.darkElevatedButtonTheme,
    outlinedButtonTheme: OutlinedButtonThemeApp.darkOutlinedButtonTheme,
    inputDecorationTheme: TextFormFieldThemeApp.darkInputDecorationTheme,
    checkboxTheme: CheckboxThemeApp.darkCheckboxTheme,
    chipTheme: ChipThemeApp.darkChipTheme,
    bottomSheetTheme: BottomSheetThemeApp.darkBottomSheetTheme,
  );
}
