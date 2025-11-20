import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/constants/app_colors.dart';
import '../wiedgets/auth_buttons.dart';


class WelcomePage extends StatelessWidget {
  const WelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 137.0),
          child: Column(
            children: [
              Center(
              ),
              SizedBox(height: 30),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18.0),
                child: Text(
                  'Welcome to BrainBox',
                  style: Theme.of(context).textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
              ),
              SizedBox(height: 75),
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
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Log in",
                      style: Theme.of(context).textTheme.bodyMedium,
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
                      side: BorderSide(
                        color: isDarkMode
                            ? Color(0xffFFFFFF)
                            : AppColors.darkBackground,
                        width: 2,
                      ),
                      backgroundColor: isDarkMode
                          ? Colors.transparent
                          : Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Text(
                      "Sign up",
                      style: Theme.of(context).textTheme.labelMedium,
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
                padding: const EdgeInsets.only(left: 25.0),
                child: AuthButtons(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}