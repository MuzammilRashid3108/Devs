import 'package:devs/src/core/theme/custom_themes/text_theme.dart';
import 'package:flutter/material.dart';

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    scaffoldBackgroundColor: Colors.white,
    textTheme: AppTextTheme.lightTextTheme,
  );

  static ThemeData darkTheme = ThemeData(
    scaffoldBackgroundColor: Colors.black,
    textTheme: AppTextTheme.darkTextTheme,
  );
}
