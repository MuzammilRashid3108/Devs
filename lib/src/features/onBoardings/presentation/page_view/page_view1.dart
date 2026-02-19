import 'package:devs/src/core/common/constants/app_sizes.dart';
import 'package:devs/src/core/common/constants/font_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PageView1 extends StatefulWidget {
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
  State<PageView1> createState() => _PageView1State();
}

class _PageView1State extends State<PageView1>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeInOut,
    );

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.only(
        top: AppSizes.tPob.h,
        right: AppSizes.hP.w,
        left: AppSizes.hP.w,
      ),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      color: isDark
                          ? Colors.white.withOpacity(0.1)
                          : Colors.black.withOpacity(0.1),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    )
                  ],
                ),
                child: Image(
                  image: AssetImage(widget.image),
                  height: widget.height?.h,
                  width: widget.width?.w,
                ),
              ),

              SizedBox(height: 50.h),

              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),

              SizedBox(height: AppSizes.sB2.h),

              Text(
                widget.subTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark
                      ? Colors.white70
                      : const Color(0xff787878),
                  fontSize: 16.sp,
                  fontFamily: AppFontStrings.pjsBold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
