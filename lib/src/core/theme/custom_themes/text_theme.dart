import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../common/constants/font_strings.dart';

class AppTextTheme {
  static TextTheme lightTextTheme = TextTheme(
    titleLarge: TextStyle(
      color: Colors.black,
      fontSize: 25.sp,
      fontFamily: AppFontStrings.pjsBold,
      fontWeight: FontWeight.w700,
    ),
  );

  static TextTheme darkTextTheme = TextTheme(
    titleLarge: TextStyle(
      color: Colors.white,
      fontSize: 25.sp,
      fontFamily: AppFontStrings.pjsBold,
      fontWeight: FontWeight.w700,
    ),
  );

}