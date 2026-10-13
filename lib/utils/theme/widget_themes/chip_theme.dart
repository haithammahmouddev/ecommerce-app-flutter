import 'package:flutter/material.dart';

class ChipThemeApp {
  ChipThemeApp._();

  static final ChipThemeData rightChipTheme = ChipThemeData(
    labelStyle: const TextStyle(color: Colors.black),
    selectedColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    disabledColor: Colors.grey.withOpacity(0.4),
    checkmarkColor: Colors.white,
  );

  static final ChipThemeData darkChipTheme = ChipThemeData(
    labelStyle: const TextStyle(color: Colors.white),
    selectedColor: Colors.blue,
    padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 12),
    disabledColor: Colors.grey.withOpacity(0.4),
    checkmarkColor: Colors.white,
  );

}