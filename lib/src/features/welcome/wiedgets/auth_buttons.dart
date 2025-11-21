import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/constants/app_colors.dart';
import '../../auth/services/auth_services.dart';


class AuthButtons extends StatelessWidget {
  const AuthButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 0.0).r,
          child: SizedBox(
            height: 60.h,
            width: 165.w,
            child: ElevatedButton(
              onPressed: () async {
                final user = await AuthService().signInWithGoogle();
                if (user != null) {
                  print("Signed in as: ${user.displayName}");
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.googleButton.withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16).r,
                ),
              ),
              child: Text(
                "GOOGLE",
                style: GoogleFonts.poppins(
                  color: AppColors.googleButton,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ),
        SizedBox(width: 15,),
        Padding(
          padding: EdgeInsets.only(right: 25.0),
          child: SizedBox(
            height: 60.h,
            width: 165.w,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xff4267B2).withOpacity(0.25),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Text(
                "FACEBOOK",
                style: GoogleFonts.poppins(
                  color: AppColors.facebookButton,
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}