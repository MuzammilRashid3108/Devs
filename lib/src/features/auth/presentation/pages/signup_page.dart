import 'package:devs/src/core/common/constants/app_colors.dart';
import 'package:devs/src/core/common/widgets/custom_back_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';


import '../../../../core/common/constants/font_strings.dart';
import '../../../welcome/wiedgets/auth_buttons.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0).r,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    top: 45,
                    left: 25,
                    right: 25,
                  ).r,
                  child: CustomBackButton(
                    onTap: () {
                      context.go('/welcome');
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 74).r,
                  child: Column(
                    children: [
                      SizedBox(height: 74),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25).r,
                        child: Text(
                          'Create Your\nAccount',
                          style: TextStyle(fontSize: 38,fontFamily: AppFontStrings.pjsBold,fontWeight: FontWeight.w600),

                        ),
                      ),
                      SizedBox(height: 48),
                    ],
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 308,
                        left: 25,
                        right: 25,
                      ),
                      child: TextField(
                        obscureText: _obscureText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 16,
                            ),
                            child: Icon(
                              Icons.person_2_outlined,
                              // 🔒 password icon on the left
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          hintText: 'Full Name',
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.backButtonColor
                              : AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 19),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: TextField(
                        obscureText: _obscureText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 16,
                            ),
                            child: Icon(
                              Icons.mail_outlined,
                              // 🔒 password icon on the left
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          hintText: 'Enter Your Email',
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.backButtonColor
                              : AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: 19),

                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),

                      child: TextField(
                        obscureText: _obscureText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 16,
                            ),
                            child: Icon(
                              Icons.lock_outline,
                              // 🔒 password icon on the left
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: isDarkMode
                                  ? Colors.white70
                                  : Colors.black54,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureText = !_obscureText;
                              });
                            },
                          ),
                          hintText: 'Password',
                          filled: true,
                          fillColor: isDarkMode
                              ? AppColors.backButtonColor
                              : AppColors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle: Theme.of(context).textTheme.labelSmall
                              ?.copyWith(
                            color: isDarkMode
                                ? Colors.white70
                                : Colors.black54,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 19),

                    Padding(
                      padding: const EdgeInsets.only(left: 25, right: 25),
                    ),
                    SizedBox(height: 20),

                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ElevatedButton(
                          onPressed: () {
                            context.push('/login');
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
                            "Register",
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
                    SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already Have An Account? ',
                          style: GoogleFonts.poppins(color: Color(0xffACADB9)),
                        ),
                        Text(
                          'Signin',
                          style: GoogleFonts.poppins(
                            color: isDarkMode
                                ? AppColors.lightBackground
                                : Colors.grey.shade700,
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 25),
                    Divider(),
                    SizedBox(height: 25),
                    Text(
                      'Continue new account',
                      style: GoogleFonts.poppins(color: Color(0xffACADB9)),
                    ),
                    SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.only(left: 23.0),
                      child: AuthButtons(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}