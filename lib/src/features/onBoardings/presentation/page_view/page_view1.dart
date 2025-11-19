import 'package:devs/src/core/common/constants/app_sizes.dart';
import 'package:devs/src/core/common/constants/font_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageView1 extends StatelessWidget {
  const PageView1({
    super.key,
    required this.title,
    required this.subTitle,
    required this.image,
    this.height,
    this.width,
  });

  final String title;
  final String subTitle;
  final String image;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        top: AppSizes.tPob.h,
        right: AppSizes.hP.w,
        left: AppSizes.hP.w,
      ),
      child: Column(
        children: [
          Image(
            image: AssetImage(image),
            height: height?.h,
            width: width?.w,
          ),

          SizedBox(height: 50.h),

          Center(
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25.sp,
                fontFamily: AppFontStrings.pjsBold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),

          SizedBox(height: AppSizes.sB2.h),

          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: const Color(0xff787878),
              fontSize: 16.sp,
              fontFamily: AppFontStrings.pjsBold,
            ),
          ),
        ],
      ),
    );
  }
}
