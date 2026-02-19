import 'package:devs/src/core/common/constants/image_strings.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../core/common/constants/app_colors.dart';
import '../../../core/common/constants/font_strings.dart';
import '../../home/presentation/pages/home_page.dart';
import '../wiedgets/auth_buttons.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage>
    with TickerProviderStateMixin {

  late final AnimationController _meshCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double> _meshAnim;

  @override
  void initState() {
    super.initState();

    _meshCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();

    _meshAnim =
        CurvedAnimation(parent: _meshCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _meshCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(
        children: [

          // 🔥 Animated Mesh Background
          AnimatedBuilder(
            animation: _meshAnim,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: BuilderMeshPainter(_meshAnim.value, isDark),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [

                  const Spacer(),

                  // 🔥 Logo + Title Fade Slide
                  FadeSlide(
                    ctrl: _entryCtrl,
                    delay: 0.0,
                    child: Column(
                      children: [

                        // Logo container styled like avatar box
                        Container(
                          width: 100.w,
                          height: 100.w,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(28.r),
                            boxShadow: [
                              BoxShadow(
                                color: p.accent.withOpacity(0.4),
                                blurRadius: 28,
                                offset: const Offset(0, 10),
                              )
                            ],
                          ),
                          child: Center(
                            child: Text(
                              "👾",
                              style: TextStyle(fontSize: 44.sp),
                            ),
                          ),
                        ),

                        SizedBox(height: 28.h),

                        Text(
                          "Welcome to",
                          style: GoogleFonts.dmMono(
                            fontSize: 14.sp,
                            color: p.sub,
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          "Heaven of Nerds",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 34.sp,
                            color: p.text,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // 🔥 Buttons Section
                  FadeSlide(
                    ctrl: _entryCtrl,
                    delay: 0.3,
                    child: Column(
                      children: [

                        GlowButton(
                          label: "Log In",
                          enabled: true,
                          palette: p,
                          onTap: () => context.push('/login'),
                        ),

                        SizedBox(height: 16.h),

                        // Secondary button styled like rank tile surface
                        GestureDetector(
                          onTap: () => context.push('/signup'),
                          child: Container(
                            height: 54.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: p.surface,
                              borderRadius: BorderRadius.circular(16.r),
                              border: Border.all(
                                color: p.hint.withOpacity(0.3),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.dmMono(
                                  fontSize: 14.sp,
                                  color: p.text,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 36.h),

                        Text(
                          "Continue with accounts",
                          style: GoogleFonts.dmMono(
                            fontSize: 11.sp,
                            color: p.sub,
                          ),
                        ),

                        SizedBox(height: 20.h),

                        AuthButtons(),
                      ],
                    ),
                  ),

                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
