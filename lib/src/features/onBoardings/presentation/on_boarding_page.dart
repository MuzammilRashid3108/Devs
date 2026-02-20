import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:devs/src/features/onBoardings/presentation/page_view/page_view1.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADAPTIVE PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _Palette {
  final Color bg, surface, surface2;
  final Color accent, accentSoft, accentMid;
  final Color win, winSoft, loss, lossSoft, gold, goldSoft;
  final Color text, sub, hint;

  const _Palette({
    required this.bg, required this.surface, required this.surface2,
    required this.accent, required this.accentSoft, required this.accentMid,
    required this.win, required this.winSoft, required this.loss,
    required this.lossSoft, required this.gold, required this.goldSoft,
    required this.text, required this.sub, required this.hint,
  });

  static const _light = _Palette(
    bg: Color(0xFFF6F4F9), surface: Color(0xFFFFFFFF), surface2: Color(0xFFF0EDF6),
    accent: Color(0xFF7C6EF5), accentSoft: Color(0xFFEBE8FD), accentMid: Color(0xFFBBB4F9),
    win: Color(0xFF4FC995), winSoft: Color(0xFFDFF5EC),
    loss: Color(0xFFF47B7B), lossSoft: Color(0xFFFDECEC),
    gold: Color(0xFFE8A83E), goldSoft: Color(0xFFFDF3E1),
    text: Color(0xFF1C1830), sub: Color(0xFF8A85A0), hint: Color(0xFFB8B4CC),
  );

  static const _dark = _Palette(
    bg: Color(0xFF0E0C15), surface: Color(0xFF16131F), surface2: Color(0xFF1E1A2E),
    accent: Color(0xFF9D8FF7), accentSoft: Color(0xFF1E1A38), accentMid: Color(0xFF4A3F8A),
    win: Color(0xFF3DD68C), winSoft: Color(0xFF0D2B1F),
    loss: Color(0xFFFF6B6B), lossSoft: Color(0xFF2B1212),
    gold: Color(0xFFFFB82E), goldSoft: Color(0xFF2A1F07),
    text: Color(0xFFF0EDF9), sub: Color(0xFF8A85A0), hint: Color(0xFF3E3A52),
  );

  static _Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

// ─────────────────────────────────────────────────────────────────────────────
// ANIMATED MESH BACKGROUND PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _MeshPainter extends CustomPainter {
  final double t;
  final bool isDark;
  const _MeshPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final d   = math.sin(t * math.pi) * 35;
    final mul = isDark ? 1.6 : 1.0;
    _blob(canvas, Offset(size.width * 0.9 + d,  size.height * 0.08),
        size.width * 0.70, const Color(0xFF7C6EF5).withOpacity(0.12 * mul));
    _blob(canvas, Offset(size.width * 0.05, size.height * 0.75 + d * 0.6),
        size.width * 0.60, const Color(0xFF3DD68C).withOpacity(0.08 * mul));
    _blob(canvas, Offset(size.width * 0.5,  size.height * 0.5  - d * 0.4),
        size.width * 0.45, const Color(0xFFE8A83E).withOpacity(0.06 * mul));
  }

  void _blob(Canvas c, Offset center, double r, Color color) =>
      c.drawCircle(center, r, Paint()
        ..shader = RadialGradient(colors: [color, Colors.transparent])
            .createShader(Rect.fromCircle(center: center, radius: r)));

  @override
  bool shouldRepaint(covariant _MeshPainter old) =>
      old.t != t || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE DATA  (identical to your original)
// ─────────────────────────────────────────────────────────────────────────────
final List<Widget> _pages = [
  const PageView1(
    image: 'assets/onBoarding/ob2.png',
    title: 'Start your journey',
    subTitle:
    'You can start your journey in the field you love, no need to be afraid '
        'of getting lost, we will help you reach the finish line',
  ),
  const PageView1(
    image: 'assets/onBoarding/ob3.png',
    title: 'You can be anything, the world is in your hands',
    subTitle:
    'By learning & increasing knowledge you will become a wise person and '
        'can change things around you and even the world',
  ),
  const PageView1(
    height: 348,
    image: 'assets/onBoarding/ob1.png',
    title: 'Find a field that you like',
    subTitle:
    'There are many fields that you can find here, and you can learn all of them',
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// ONBOARDING PAGE
// ─────────────────────────────────────────────────────────────────────────────
class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

class _OnBoardingPageState extends State<OnBoardingPage>
    with TickerProviderStateMixin {

  late final PageController      _pageCtrl;
  late final AnimationController _meshCtrl;
  late final Animation<double>   _meshAnim;

  bool _isLastPage = false;

  @override
  void initState() {
    super.initState();

    _pageCtrl = PageController();

    _meshCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _meshAnim = CurvedAnimation(parent: _meshCtrl, curve: Curves.easeInOut);

    _pageCtrl.addListener(() {
      final last = _pageCtrl.page!.round() == _pages.length - 1;
      if (last != _isLastPage) setState(() => _isLastPage = last);
    });
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    _meshCtrl.dispose();
    super.dispose();
  }

  void _advance() {
    HapticFeedback.lightImpact();
    if (!_isLastPage) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    } else {
      context.push('/welcome');
    }
  }

  void _skip() {
    HapticFeedback.selectionClick();
    context.push('/welcome');
  }

  @override
  Widget build(BuildContext context) {
    final p      = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(
        children: [

          // ── Animated mesh background ──────────────────────────────────
          AnimatedBuilder(
            animation: _meshAnim,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _MeshPainter(_meshAnim.value, isDark),
            ),
          ),

          // ── Pages ─────────────────────────────────────────────────────
          PageView(
            controller: _pageCtrl,
            children: _pages,
          ),

          // ── Skip button (top-right) ────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topRight,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _isLastPage ? 0.0 : 1.0,
                child: Padding(
                  padding: EdgeInsets.only(top: 12.h, right: 20.w),
                  child: GestureDetector(
                    onTap: _skip,
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 7.h),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: p.hint.withOpacity(0.25)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Skip',
                        style: GoogleFonts.dmMono(
                          fontSize: 11.sp,
                          color: p.sub,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // ── Dot indicator ──────────────────────────────────────────────
          Positioned(
            bottom: 130.h, left: 0, right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageCtrl,
                count: _pages.length,
                effect: WormEffect(
                  dotHeight: 8.h,
                  dotWidth:  8.w,
                  spacing:   8.w,
                  activeDotColor: p.accent,
                  dotColor: p.hint.withOpacity(0.35),
                ),
              ),
            ),
          ),

          // ── Morphing CTA button ────────────────────────────────────────
          Positioned(
            bottom: 40.h, left: 24.w, right: 24.w,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 420),
              curve: Curves.easeInOut,
              height: 54.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16.r),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: p.accent.withOpacity(0.40),
                    blurRadius: 18,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16.r),
                  onTap: _advance,
                  child: Center(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      transitionBuilder: (child, anim) => FadeTransition(
                        opacity: anim,
                        child: ScaleTransition(scale: anim, child: child),
                      ),
                      child: _isLastPage
                          ? Text(
                        'Get Started  ⚔️',
                        key: const ValueKey('text'),
                        style: GoogleFonts.dmMono(
                          fontSize: 15.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
                      )
                          : Icon(
                        Icons.arrow_forward_rounded,
                        key: const ValueKey('icon'),
                        color: Colors.white,
                        size: 26.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

        ],
      ),
    );
  }
}