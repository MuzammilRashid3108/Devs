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
          padding: const EdgeInsets.only(top: 180.0),
          child: Column(
            children: [
              Center(
                child: Image(
                  image: AssetImage(
                    isDarkMode
                        ? AppImageStrings.logoTrLight
                        : AppImageStrings.logoTrDark,
                  ),
                  height: 100,
                ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Welcome to',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: isDarkMode ? Colors.white : Colors.black,
                    fontSize: 33.9,
                    fontWeight: FontWeight.w600,
                    fontFamily: AppFontStrings.pjsBold,
                  ),
                ),
              ),
              SizedBox(height: 15,),
              Text(
                'Heaven of Nerds',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDarkMode ? Colors.white : Colors.black,
                  fontSize: 33.9,
                  fontWeight: FontWeight.w600,
                  fontFamily: AppFontStrings.pjsBold,
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                // child: Text(
                //   "Where ideas evolve into real applications.Empowering you to code smarter, faster, and better.",
                //   textAlign: TextAlign.center,
                //   style: TextStyle(
                //     color: const Color(0xff787878),
                //     fontSize: 16.sp,
                //     fontFamily: AppFontStrings.pjsBold,
                //   ),
                // ),
              ),
              SizedBox(height: 40),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/login');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isDarkMode
                          ? Color(0xffFFFFFF)
                          : AppColors.darkBackground,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
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
              SizedBox(height: 22),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 25.0),
                child: SizedBox(
                  height: 60,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      context.push('/signup');
                    },
                    style: ElevatedButton.styleFrom(
                      // side: BorderSide(
                      //   color: isDarkMode
                      //       ? Color(0xffFFFFFF)
                      //       : AppColors.darkBackground,
                      //   width: 2,
                      // ),
                      backgroundColor: isDarkMode
                          ? Colors.grey.shade900
                          : Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(60),
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
              SizedBox(height: 42),
              Text(
                'Continue With Accounts',
                style: GoogleFonts.poppins(
                  color: Color(0xffACADB9),
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 32.r),
              Padding(
                padding: const EdgeInsets.only(left: 23.0),
                child: AuthButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
