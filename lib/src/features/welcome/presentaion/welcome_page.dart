import 'package:devs/src/core/common/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/constants/app_colors.dart';
import '../../../core/common/constants/font_strings.dart';
import '../wiedgets/auth_buttons.dart';

class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 180.h),   // 🔥 ScreenUtil applied
          child: Column(
            children: [
              Center(
                child: Image(
                  image: AssetImage(
                    isDarkMode
                        ? AppImageStrings.logoTrLight
                        : AppImageStrings.logoTrDark,
                  ),
                  height: 100.h,                 // 🔥 ScreenUtil
                ),
              ),

              SizedBox(height: 40.h),            // 🔥 ScreenUtil

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 18.w),   // 🔥 ScreenUtil
                child: Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 33.9.sp,           // 🔥 ScreenUtil
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFontStrings.pjsBold,
                  ),
                ),
              ),

              SizedBox(height: 15.h),

              Text(
                'Heaven of Nerds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 33.9.sp,            // 🔥 ScreenUtil
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontStrings.pjsBold,
                ),
              ),

              SizedBox(height: 20.h),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
              ),

              SizedBox(height: 40.h),

              // 🔥 LOGIN BUTTON
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: SizedBox(
                  height: 60.h,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Colors.white
                          : AppColors.darkBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Log In",
                      style: TextStyle(
                        color: isDarkMode ? Colors.black : Colors.white,
                        fontSize: 18.sp,
                        fontFamily: AppFontStrings.pjsBold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 22.h),

              // 🔥 SIGNUP BUTTON
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.w),
                child: SizedBox(
                  height: 60.h,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? AppColors.backButtonColor
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16.r),
                      ),
                    ),
                    child: Text(
                      "Sign up",
                      style: TextStyle(
                        color: isDarkMode ? Colors.white : Colors.black,
                        fontSize: 18.sp,
                        fontFamily: AppFontStrings.pjsBold,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 42.h),

              Text(
                'Continue With Accounts',
                style: GoogleFonts.poppins(
                  color: Color(0xffACADB9),
                  fontSize: 16.sp,
                ),
              ),

              SizedBox(height: 32.h),

              Padding(
                padding: EdgeInsets.only(left: 23.w),
                child: AuthButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
