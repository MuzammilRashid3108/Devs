import 'package:devs/src/core/common/constants/font_strings.dart';
import 'package:devs/src/core/common/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/widgets/custom_back_button.dart';
import '../../../welcome/wiedgets/auth_buttons.dart';
import '../../services/auth_services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscureText = true;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

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
                      SizedBox(height: 50),
                      Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25).r,
                      ),
                      SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.only(left: 25),
                        child: Text(
                          'Login Your\nAccount',

                          style: TextStyle(
                            fontSize: 38,
                            fontFamily: AppFontStrings.pjsBold,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
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
                        controller: emailController,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.only(
                              left: 24.0,
                              right: 16,
                            ),
                            child: Icon(
                              Icons.email_outlined,
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
                              : Colors.grey.shade100,
                          // transparent background
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),

                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),

                          // hint style uses labelSmall from theme
                          hintStyle:
                              TextStyle(
                                fontSize: 13,
                                fontFamily: AppFontStrings.pjsBold,
                              ).copyWith(
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
                        controller: passwordController,
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
                              : Colors.grey.shade100,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 20,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                          hintStyle:
                              TextStyle(
                                fontSize: 13,
                                fontFamily: AppFontStrings.pjsBold,
                              ).copyWith(
                                color: isDarkMode
                                    ? Colors.white70
                                    : Colors.black54,
                              ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 56.r,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 25.0),
                            child: GestureDetector(
                              onTap: () {
                                context.push('/forgetPs');
                              },
                              child: Text(
                                'Forget Password ?',
                                style: TextStyle(
                                  color: isDarkMode
                                      ? Colors.grey
                                      : Colors.grey.shade600,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: AppFontStrings.pjsBold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 60,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 25.0),
                        child: ElevatedButton(
                          onPressed: _isLoading
                              ? null
                              : () async {
                                  final email = emailController.text.trim();
                                  final password = passwordController.text
                                      .trim();

                                  if (email.isEmpty || password.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text("Please fill all fields"),
                                      ),
                                    );
                                    return;
                                  }

                                  setState(() {
                                    _isLoading = true;
                                  });

                                  try {
                                    final user = await AuthService()
                                        .signInWithEmail(email, password);
                                    if (user != null && context.mounted) {
                                      context.go('/home');
                                    } else if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Login Failed: Incorrect email or password",
                                          ),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text("Error: $e")),
                                      );
                                    }
                                  } finally {
                                    if (context.mounted) {
                                      setState(() {
                                        _isLoading = false;
                                      });
                                    }
                                  }
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isDarkMode
                                ? AppColors.backButtonColor
                                : AppColors.darkBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  "Log in",
                                  style: TextStyle(
                                    color: isDarkMode
                                        ? AppColors.lightBackground
                                        : AppColors.lightBackground,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: AppFontStrings.pjsBold,
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
                          'Create new account? ',
                          style: GoogleFonts.poppins(
                            color: isDarkMode
                                ? Color(0xffACADB9)
                                : Colors.grey.shade600,
                          ),
                        ),
                        Text(
                          'Signup',
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
                      'Continue with these accounts',
                      style: GoogleFonts.poppins(
                        color: isDarkMode
                            ? Color(0xffACADB9)
                            : Colors.grey.shade600,
                      ),
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
