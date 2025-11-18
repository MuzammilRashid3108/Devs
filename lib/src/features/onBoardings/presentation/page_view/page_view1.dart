import 'dart:ffi';

import 'package:devs/src/core/common/constants/app_sizes.dart';
import 'package:devs/src/core/common/constants/font_strings.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class PageView1 extends StatelessWidget {
  const PageView1({super.key, required this.title, required this.subTitle, required this.image,  this.height,  this.width});

  final String title;
  final String subTitle;
  final String image;
  final double? height;
  final double? width;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSizes.tPob,
        right: AppSizes.hP,
        left: AppSizes.hP,
      ),
      child: Column(
        children: [
          Image(image: AssetImage(image),height: height,width: width,),
          SizedBox(height: 50),
          Center(
            child: Text(
              title,

              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontFamily: AppFontStrings.pjsBold,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          SizedBox(height: AppSizes.sB2),
          Text(
            subTitle,
            textAlign: TextAlign.center,
            style: TextStyle(color: Color(0xff787878), fontSize: 16,fontFamily: AppFontStrings.pjsBold,),
          ),
        ],
      ),
    );
  }
}
