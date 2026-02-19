import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../home/presentation/pages/home_page.dart';

class SocialButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;
  final Palette palette;

  const SocialButton({
    required this.label,
    required this.color,
    required this.onTap,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 60.h,
          decoration: BoxDecoration(
            color: palette.surface,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: color.withOpacity(0.4),
            ),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.25),
                blurRadius: 18,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.dmMono(
                color: color,
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
