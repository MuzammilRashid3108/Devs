import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE (identical to the rest of the app)
// ─────────────────────────────────────────────────────────────────────────────
class _Palette {
  final Color bg, surface, surface2;
  final Color accent, accentSoft, accentMid;
  final Color win, winSoft, loss, lossSoft, gold, goldSoft;
  final Color text, sub, hint;

  const _Palette({
    required this.bg, required this.surface, required this.surface2,
    required this.accent, required this.accentSoft, required this.accentMid,
    required this.win, required this.winSoft,
    required this.loss, required this.lossSoft,
    required this.gold, required this.goldSoft,
    required this.text, required this.sub, required this.hint,
  });

  static const _light = _Palette(
    bg: Color(0xFFF0EDF9), surface: Color(0xFFFFFFFF), surface2: Color(0xFFE4E0F5),
    accent: Color(0xFF7C6EF5), accentSoft: Color(0xFFEBE8FD), accentMid: Color(0xFFBBB4F9),
    win: Color(0xFF4FC995), winSoft: Color(0xFFDFF5EC),
    loss: Color(0xFFF47B7B), lossSoft: Color(0xFFFDECEC),
    gold: Color(0xFFE8A83E), goldSoft: Color(0xFFFDF3E1),
    text: Color(0xFF1C1830), sub: Color(0xFF8A85A0), hint: Color(0xFFB8B4CC),
  );

  static const _dark = _Palette(
    bg: Color(0xFF080611), surface: Color(0xFF13101C), surface2: Color(0xFF1B1727),
    accent: Color(0xFF9D8FF7), accentSoft: Color(0xFF1E1A38), accentMid: Color(0xFF4A3F8A),
    win: Color(0xFF3DD68C), winSoft: Color(0xFF0D2B1F),
    loss: Color(0xFFFF6B6B), lossSoft: Color(0xFF2B1212),
    gold: Color(0xFFFFB82E), goldSoft: Color(0xFF2A1F07),
    text: Color(0xFFF0EDF9), sub: Color(0xFF8A85A0), hint: Color(0xFF2A2640),
  );

  static _Palette of(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? _dark : _light;
}

// ─────────────────────────────────────────────────────────────────────────────
// FORGET PASSWORD PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ForgetPsPage extends StatefulWidget {
  const ForgetPsPage({super.key});
  @override
  State<ForgetPsPage> createState() => _ForgetPsPageState();
}

class _ForgetPsPageState extends State<ForgetPsPage>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entryCtrl;

  // 0 = none, 1 = email, 2 = phone
  int _selected = 0;

  @override
  void initState() {
    super.initState();
    _bgCtrl   = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  // ── helpers ───────────────────────────────────────────────────────────────
  Animation<double> _stagger(double start, double end) => CurvedAnimation(
    parent: _entryCtrl,
    curve: Interval(start, end, curve: Curves.easeOutCubic),
  );

  @override
  Widget build(BuildContext context) {
    final p      = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(children: [

        // ── Starfield background ───────────────────────────────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _StarfieldPainter(
              CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value,
              isDark,
            ),
          ),
        ),

        // ── Content ───────────────────────────────────────────────────────
        SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),

                // ── Back button ──────────────────────────────────────────
                FadeTransition(
                  opacity: _stagger(0.0, 0.3),
                  child: _BackBtn(p: p, onTap: () => context.go('/login')),
                ),

                SizedBox(height: 44.h),

                // ── Lock icon + title ────────────────────────────────────
                FadeTransition(
                  opacity: _stagger(0.05, 0.4),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.3),
                      end: Offset.zero,
                    ).animate(_stagger(0.05, 0.4)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon badge
                        Container(
                          width: 54.w, height: 54.w,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [p.accent, Color.lerp(p.accent, p.accentMid, 0.5)!],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: p.accent.withOpacity(0.35),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text('🔐', style: TextStyle(fontSize: 24.sp)),
                          ),
                        ),
                        SizedBox(height: 20.h),
                        Text(
                          'Forgot\nPassword?',
                          style: GoogleFonts.dmSerifDisplay(
                            fontSize: 36.sp,
                            color: p.text,
                            height: 1.1,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          'Select how you want to receive\nyour reset code.',
                          style: GoogleFonts.dmMono(
                            fontSize: 12.sp,
                            color: p.sub,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 40.h),

                // ── Email option ─────────────────────────────────────────
                FadeTransition(
                  opacity: _stagger(0.25, 0.65),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(_stagger(0.25, 0.65)),
                    child: _ContactOption(
                      p: p,
                      emoji: '📧',
                      title: 'Email',
                      subtitle: 'Code sent to your email',
                      selected: _selected == 1,
                      accentColor: p.accent,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selected = 1);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 14.h),

                // ── Phone option ─────────────────────────────────────────
                FadeTransition(
                  opacity: _stagger(0.35, 0.75),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.25),
                      end: Offset.zero,
                    ).animate(_stagger(0.35, 0.75)),
                    child: _ContactOption(
                      p: p,
                      emoji: '📱',
                      title: 'Phone',
                      subtitle: 'Code sent to your phone',
                      selected: _selected == 2,
                      accentColor: p.win,
                      onTap: () {
                        HapticFeedback.lightImpact();
                        setState(() => _selected = 2);
                      },
                    ),
                  ),
                ),

                SizedBox(height: 44.h),

                // ── Continue button ──────────────────────────────────────
                FadeTransition(
                  opacity: _stagger(0.55, 0.90),
                  child: SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, 0.2),
                      end: Offset.zero,
                    ).animate(_stagger(0.55, 0.90)),
                    child: _ContinueBtn(
                      p: p,
                      enabled: _selected != 0,
                      onTap: () {
                        if (_selected == 0) return;
                        HapticFeedback.heavyImpact();
                        context.push('/verification');
                      },
                    ),
                  ),
                ),

                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTACT OPTION CARD
// ─────────────────────────────────────────────────────────────────────────────
class _ContactOption extends StatefulWidget {
  final _Palette p;
  final String emoji, title, subtitle;
  final bool selected;
  final Color accentColor;
  final VoidCallback onTap;

  const _ContactOption({
    required this.p,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.accentColor,
    required this.onTap,
  });

  @override
  State<_ContactOption> createState() => _ContactOptionState();
}

class _ContactOptionState extends State<_ContactOption>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
    _scale = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _pressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final sel = widget.selected;

    return GestureDetector(
      onTapDown: (_) => _pressCtrl.forward(),
      onTapUp: (_) {
        _pressCtrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: sel
                ? widget.accentColor.withOpacity(0.10)
                : p.surface,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: sel
                  ? widget.accentColor.withOpacity(0.55)
                  : p.hint.withOpacity(0.13),
              width: sel ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: sel
                    ? widget.accentColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.06),
                blurRadius: sel ? 18 : 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(children: [

            // Icon circle
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 50.w, height: 50.w,
              decoration: BoxDecoration(
                color: sel
                    ? widget.accentColor.withOpacity(0.18)
                    : p.surface2,
                shape: BoxShape.circle,
                border: Border.all(
                  color: sel
                      ? widget.accentColor.withOpacity(0.4)
                      : p.hint.withOpacity(0.12),
                ),
              ),
              child: Center(
                child: Text(widget.emoji, style: TextStyle(fontSize: 20.sp)),
              ),
            ),

            SizedBox(width: 16.w),

            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: GoogleFonts.dmSerifDisplay(
                      fontSize: 15.sp,
                      color: sel ? widget.accentColor : p.text,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    widget.subtitle,
                    style: GoogleFonts.dmMono(
                      fontSize: 10.sp,
                      color: p.sub,
                    ),
                  ),
                ],
              ),
            ),

            // Check indicator
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 22.w, height: 22.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: sel
                    ? widget.accentColor
                    : Colors.transparent,
                border: Border.all(
                  color: sel
                      ? widget.accentColor
                      : p.hint.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: sel
                  ? Icon(Icons.check_rounded,
                  size: 13.sp, color: Colors.white)
                  : null,
            ),

          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CONTINUE BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _ContinueBtn extends StatefulWidget {
  final _Palette p;
  final bool enabled;
  final VoidCallback onTap;
  const _ContinueBtn({required this.p, required this.enabled, required this.onTap});
  @override State<_ContinueBtn> createState() => _ContinueBtnState();
}

class _ContinueBtnState extends State<_ContinueBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.97)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return GestureDetector(
      onTapDown: widget.enabled ? (_) => _c.forward() : null,
      onTapUp: widget.enabled ? (_) { _c.reverse(); widget.onTap(); } : null,
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: 58.h,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? LinearGradient(
              colors: [p.accent, Color.lerp(p.accent, const Color(0xFF6B5CE7), 0.5)!],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )
                : null,
            color: widget.enabled ? null : p.surface2,
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: widget.enabled
                ? [
              BoxShadow(
                color: p.accent.withOpacity(0.35),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Continue',
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 16.sp,
                  color: widget.enabled
                      ? Colors.white
                      : p.hint,
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_rounded,
                size: 16.sp,
                color: widget.enabled
                    ? Colors.white.withOpacity(0.85)
                    : p.hint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// BACK BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _BackBtn extends StatelessWidget {
  final _Palette p;
  final VoidCallback onTap;
  const _BackBtn({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      width: 42.w, height: 42.w,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: p.hint.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.07),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(
        Icons.arrow_back_ios_new_rounded,
        size: 15.sp,
        color: p.text,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STARFIELD PAINTER (identical to rest of app)
// ─────────────────────────────────────────────────────────────────────────────
class _StarfieldPainter extends CustomPainter {
  final double t;
  final bool isDark;
  const _StarfieldPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final drift = math.sin(t * math.pi) * 32;
    final mul   = isDark ? 1.0 : 0.55;

    _blob(canvas, Offset(size.width * 0.88 + drift, size.height * 0.10),
        size.width * 0.65, const Color(0xFF7C6EF5).withOpacity(0.13 * mul));
    _blob(canvas, Offset(size.width * 0.07, size.height * 0.55 + drift * 0.6),
        size.width * 0.55, const Color(0xFF3DD68C).withOpacity(0.08 * mul));
    _blob(canvas, Offset(size.width * 0.60, size.height * 0.78 - drift * 0.4),
        size.width * 0.50, const Color(0xFFFF6B6B).withOpacity(0.07 * mul));
    _blob(canvas, Offset(size.width * 0.28, size.height * 0.33 + drift * 0.3),
        size.width * 0.40, const Color(0xFFFFB82E).withOpacity(0.06 * mul));

    if (isDark) {
      final rng = math.Random(42);
      for (var i = 0; i < 90; i++) {
        final sx = rng.nextDouble() * size.width;
        final sy = rng.nextDouble() * size.height;
        final sr = rng.nextDouble() * 1.3 + 0.2;
        final op = (0.15 + rng.nextDouble() * 0.5
            + math.sin(t * math.pi * 2 + i) * 0.18).clamp(0.0, 0.85);
        canvas.drawCircle(Offset(sx, sy), sr,
            Paint()..color = Colors.white.withOpacity(op));
      }
    }
  }

  void _blob(Canvas c, Offset centre, double r, Color color) =>
      c.drawCircle(centre, r, Paint()
        ..shader = RadialGradient(colors: [color, Colors.transparent])
            .createShader(Rect.fromCircle(center: centre, radius: r)));

  @override
  bool shouldRepaint(covariant _StarfieldPainter o) =>
      o.t != t || o.isDark != isDark;
}