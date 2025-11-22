import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';

class CustomBackButton extends StatelessWidget {
  const CustomBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45.w,
        height: 45.h,
        padding: EdgeInsets.only(left: 5),
        decoration: BoxDecoration(
          color: isDarkMode ? AppColors.backButtonColor : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(15),
        ),
        child: Center(
          child: Icon(
            Icons.arrow_back_ios,
            size: 12.r,
            color: isDarkMode ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}