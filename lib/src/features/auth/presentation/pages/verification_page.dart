import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/common/constants/app_colors.dart';
import '../../../../core/common/constants/font_strings.dart';
import '../../../../core/common/widgets/custom_back_button.dart';

// Assuming you have AppColors and AppFontStrings defined in your constants files.

class EmailOtpPage extends StatelessWidget {
  const EmailOtpPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine if the current theme is dark mode.
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define the color for the main card background (dark gray/black)
    final cardColor = isDarkMode ? Colors.black : Colors.white;
    // Define the color for the text and icons
    final textColor = isDarkMode ? Colors.white : Colors.black;
    // Define the color for the button/accent color
    final primaryColor = isDarkMode
        ? AppColors.backButtonColor
        : AppColors.darkBackground;
    // Define the color for the disabled/secondary text
    const secondaryTextColor = Color(0xffACADB9);

    // Define the email for display (should be passed in a real app)
    const displayEmail = "muzammilrashid51@gmail.com";

    return Scaffold(
      // The background of the entire screen is the dark theme color
      body: Stack(
        children: [
          // Custom back button
          Padding(
            padding: const EdgeInsets.only(top: 45.0, left: 25).r,
            child: CustomBackButton(
              onTap: () {
                // Navigate back to the previous screen (ForgetPsPage)
                context.pop();
              },
            ),
          ),

          // Centered content card
          Padding(
            padding: const EdgeInsets.only(top: 150.0),
            child: Padding(
              padding: const EdgeInsets.only(right: 25.0, left: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title: Verify Email
                  Text(
                    'Verify Email',
                    style: TextStyle(
                      fontSize: 38,
                      fontFamily: AppFontStrings.pjsBold,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  // Subtitle/Instruction
                  Text(
                    'We Have Sent Code To Your Phone Email',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFontStrings.pjsBold,
                    ),
                  ),
                  Text(
                    displayEmail,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      fontFamily: AppFontStrings.pjsBold,
                    ),
                  ),
                  SizedBox(height: 30.h),

                  // Display Email
                  SizedBox(height: 25.h),

                  // OTP Input Fields
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(
                      4,
                      (index) => OtpInput(
                        isDarkMode: isDarkMode,
                        first: index == 0, // Mark the first field
                        last: index == 3, // Mark the last field
                      ),
                    ),
                  ),
                  SizedBox(height: 35.h),

                  // Verify Button
                  SizedBox(
                    height: 55.h,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement OTP verification logic
                        // context.push('/setNewPassword');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor, // Dark button background
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "Verify",
                        style: GoogleFonts.poppins(
                          color: AppColors.lightBackground,
                          // Light text for contrast
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 15.h),

                  // Send Again Button
                  SizedBox(
                    height: 55.h,
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // TODO: Implement Send Again logic
                      },
                      style: OutlinedButton.styleFrom(
                        side: BorderSide.none,
                        // No visible border for a text-like button
                        backgroundColor: primaryColor,
                        // Same color as Verify button for the design
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        "Send Again",
                        style: GoogleFonts.poppins(
                          color: AppColors.lightBackground.withOpacity(0.8),
                          // Slightly subdued color
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom Widget for a single OTP input field
class OtpInput extends StatelessWidget {
  final bool isDarkMode;
  final bool first;
  final bool last;

  const OtpInput({
    super.key,
    required this.isDarkMode,
    required this.first,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    // Define the style for the input field
    final inputStyle = TextStyle(
      fontSize: 24.sp,
      fontWeight: FontWeight.w600,
      color: isDarkMode ? Colors.white : Colors.black,
      fontFamily: AppFontStrings.pjsBold,
    );

    // Define the color for the box/border
    final boxBorderColor = isDarkMode
        ? Colors.white.withOpacity(0.7)
        : Colors.grey.shade400;

    return SizedBox(
      height: 60.h,
      width: 80.w,
      child: TextFormField(
        autofocus: first,
        // Auto-focus the first field
        onChanged: (value) {
          if (value.length == 1 && !last) {
            // Move focus to the next field when a digit is entered
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && !first) {
            // Move focus to the previous field when backspace is pressed
            FocusScope.of(context).previousFocus();
          }
        },
        style: inputStyle,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        inputFormatters: [
          LengthLimitingTextInputFormatter(1), // Allow only one character
          FilteringTextInputFormatter.digitsOnly, // Allow only digits
        ],
        decoration: InputDecoration(
          // Match the square-box look from the image
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: boxBorderColor, width: 2),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: boxBorderColor, width: 2),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(
              color: boxBorderColor,
              width: 2,
            ), // Example focus color
          ),
          fillColor: Colors.transparent,
          // Keep the inside transparent
          filled: true,
        ),
      ),
    );
  }
}
