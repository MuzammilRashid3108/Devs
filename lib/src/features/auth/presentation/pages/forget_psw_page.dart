import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/font_strings.dart';
import '../../../../core/common/widgets/custom_back_button.dart';

class ForgetPsPage extends StatefulWidget {
  const ForgetPsPage({super.key});

  @override
  State<ForgetPsPage> createState() => _ForgetPsPageState();
}

class _ForgetPsPageState extends State<ForgetPsPage> {
  bool isSelected = false;
  bool ifSelected = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 45.0, left: 25).r,
              child: CustomBackButton(
                onTap: () {
                  context.go('/login');
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 163.0, left: 25, right: 25).r,
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Forget Password',
                        style: TextStyle(fontSize: 38,fontFamily: AppFontStrings.pjsBold,fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Select which contact details should we use to reset your password',
                    style: GoogleFonts.poppins(
                      color: Color(0xffACADB9),
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  SizedBox(height: 45),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected = true;
                        ifSelected = false; // toggle selection
                      });
                    },
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,width: 2
                        ),

                        color: isDarkMode
                            ? AppColors.backButtonColor
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Container(
                              width: 50.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade900
                                    : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(Icons.email),
                            ),
                          ),
                          SizedBox(width: 24),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                style: GoogleFonts.poppins(
                                  color: isDarkMode
                                      ? AppColors.white
                                      : AppColors.darkBackground,
                                ),
                              ),
                              Text(
                                'Code Send to your email',
                                style: GoogleFonts.poppins(
                                  color: Color(0xffACADB9),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      setState(() {
                        isSelected = false;
                        ifSelected = true;
                      });
                    },
                    child: Container(
                      height: 80,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: ifSelected ? Colors.white : Colors.transparent,width: 2
                        ),

                        color: isDarkMode
                            ? AppColors.backButtonColor
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 16.0),
                            child: Container(
                              width: 50.w,
                              height: 50.h,
                              decoration: BoxDecoration(
                                color: isDarkMode
                                    ? Colors.grey.shade900
                                    : AppColors.lightBackground,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(Icons.phone),
                            ),
                          ),
                          SizedBox(width: 24),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Phone",
                                style: GoogleFonts.poppins(
                                  color: isDarkMode
                                      ? AppColors.white
                                      : AppColors.darkBackground,
                                ),
                              ),
                              Text(
                                'Code Send to your phone',
                                style: GoogleFonts.poppins(
                                  color: Color(0xffACADB9),
                                  fontWeight: FontWeight.normal,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40),
                  SizedBox(
                    height: 60,
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 0.0),
                      child: ElevatedButton(
                        onPressed: () {
                          context.push('/emailOtp');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDarkMode
                              ? AppColors.backButtonColor
                              : AppColors.darkBackground,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Text(
                          "Next",
                          style: GoogleFonts.poppins(
                            color: isDarkMode
                                ? AppColors.lightBackground
                                : AppColors.lightBackground,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}