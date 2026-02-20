import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

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
// FADE + SLIDE ANIMATION HELPER
// ─────────────────────────────────────────────────────────────────────────────
class _FadeSlide extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;
  const _FadeSlide({required this.ctrl, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final end   = (delay + 0.5).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
        parent: ctrl, curve: Interval(delay, end, curve: Curves.easeOut));
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero).animate(curve),
        child: child,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GLOW BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _GlowButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final _Palette p;
  const _GlowButton({required this.label, required this.enabled, required this.p, this.onTap});

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double>   _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _s = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return GestureDetector(
      onTapDown:   (_) { if (widget.enabled) _c.forward(); },
      onTapUp:     (_) { _c.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: double.infinity, height: 54.h,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? const LinearGradient(
                begin: Alignment.topLeft, end: Alignment.bottomRight,
                colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)])
                : null,
            color: widget.enabled ? null : p.hint.withOpacity(0.2),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: widget.enabled
                ? [BoxShadow(color: p.accent.withOpacity(0.38),
                blurRadius: 16, offset: const Offset(0, 7))]
                : [],
          ),
          child: Center(
            child: Text(widget.label,
                style: GoogleFonts.dmMono(
                  fontSize: 14.sp, color: widget.enabled ? Colors.white : p.hint,
                  fontWeight: FontWeight.w700, letterSpacing: 0.3,
                )),
          ),
        ),
      ),
    );
  }
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
    _blob(canvas, Offset(size.width * 0.9 + d, size.height * 0.08),
        size.width * 0.70, const Color(0xFF7C6EF5).withOpacity(0.12 * mul));
    _blob(canvas, Offset(size.width * 0.05, size.height * 0.75 + d * 0.6),
        size.width * 0.60, const Color(0xFF3DD68C).withOpacity(0.08 * mul));
    _blob(canvas, Offset(size.width * 0.5, size.height * 0.5 - d * 0.4),
        size.width * 0.45, const Color(0xFFE8A83E).withOpacity(0.06 * mul));
  }

  void _blob(Canvas c, Offset center, double r, Color color) =>
      c.drawCircle(center, r, Paint()
        ..shader = RadialGradient(colors: [color, Colors.transparent])
            .createShader(Rect.fromCircle(center: center, radius: r)));

  @override
  bool shouldRepaint(covariant _MeshPainter old) => old.t != t || old.isDark != isDark;
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL CHIPS ROW  (replaces AuthButtons)
// ─────────────────────────────────────────────────────────────────────────────
class _SocialRow extends StatelessWidget {
  final _Palette p;
  const _SocialRow({required this.p});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _SocialChip(label: 'Google',  symbol: 'G', color: const Color(0xFFEA4335), p: p),
      SizedBox(width: 12.w),
      _SocialChip(label: 'Apple',   symbol: '🍎', color: p.text, p: p),
      SizedBox(width: 12.w),
      _SocialChip(label: 'Twitter', symbol: '𝕏',  color: p.text, p: p),
    ],
  );
}

class _SocialChip extends StatefulWidget {
  final String label, symbol;
  final Color color;
  final _Palette p;
  const _SocialChip({required this.label, required this.symbol, required this.color, required this.p});

  @override
  State<_SocialChip> createState() => _SocialChipState();
}

class _SocialChipState extends State<_SocialChip> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double>   _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 100));
    _s = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return GestureDetector(
      onTapDown:   (_) => _c.forward(),
      onTapUp:     (_) { _c.reverse(); HapticFeedback.selectionClick(); },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: p.hint.withOpacity(0.25)),
            boxShadow: [BoxShadow(
                color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 3))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.symbol,
                style: TextStyle(fontSize: 15.sp,
                    color: widget.symbol == 'G' ? widget.color : null)),
            SizedBox(width: 7.w),
            Text(widget.label,
                style: GoogleFonts.dmMono(
                    fontSize: 11.sp, color: p.text, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// DIVIDER ROW
// ─────────────────────────────────────────────────────────────────────────────
class _DividerRow extends StatelessWidget {
  final _Palette p;
  final String label;
  const _DividerRow({required this.p, required this.label});

  @override
  Widget build(BuildContext context) => Row(children: [
    Expanded(child: Divider(color: p.hint.withOpacity(0.3), thickness: 1)),
    Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Text(label,
          style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub, letterSpacing: 0.3)),
    ),
    Expanded(child: Divider(color: p.hint.withOpacity(0.3), thickness: 1)),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// WELCOME PAGE
// ─────────────────────────────────────────────────────────────────────────────
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with TickerProviderStateMixin {
  late final AnimationController _meshCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double>   _meshAnim;
  late final Animation<double>   _floatAnim;

  @override
  void initState() {
    super.initState();
    _meshCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))
      ..forward();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);

    _meshAnim  = CurvedAnimation(parent: _meshCtrl, curve: Curves.easeInOut);
    _floatAnim = Tween<double>(begin: 0, end: 7)
        .animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _meshCtrl.dispose(); _entryCtrl.dispose(); _floatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p      = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(children: [

        // ── Animated mesh ────────────────────────────────────────────────
        AnimatedBuilder(
          animation: _meshAnim,
          builder: (_, __) => CustomPaint(
            size: MediaQuery.of(context).size,
            painter: _MeshPainter(_meshAnim.value, isDark),
          ),
        ),

        SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(children: [

              const Spacer(),

              // ── Floating logo + headline ────────────────────────────────
              _FadeSlide(ctrl: _entryCtrl, delay: 0.0,
                child: AnimatedBuilder(
                  animation: _floatAnim,
                  builder: (_, child) => Transform.translate(
                      offset: Offset(0, -_floatAnim.value), child: child),
                  child: Column(children: [

                    // Logo box
                    Container(
                      width: 100.w, height: 100.w,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(28.r),
                        boxShadow: [BoxShadow(
                          color: p.accent.withOpacity(0.45),
                          blurRadius: 30, offset: const Offset(0, 12),
                        )],
                      ),
                      child: Center(child: Text('👾', style: TextStyle(fontSize: 44.sp))),
                    ),

                    SizedBox(height: 30.h),

                    Text('Welcome to',
                        style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.sub, letterSpacing: 0.4)),
                    SizedBox(height: 6.h),
                    Text('Heaven of Nerds',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.dmSerifDisplay(fontSize: 36.sp, color: p.text)),
                    SizedBox(height: 14.h),

                    // Gold tagline chip
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: p.goldSoft,
                        borderRadius: BorderRadius.circular(10.r),
                        border: Border.all(color: p.gold.withOpacity(0.3)),
                      ),
                      child: Text('Battle. Level up. Dominate. 👑',
                          style: GoogleFonts.dmMono(
                              fontSize: 10.sp, color: p.gold, fontWeight: FontWeight.w600)),
                    ),
                  ]),
                ),
              ),

              const Spacer(),

              // ── Buttons ─────────────────────────────────────────────────
              _FadeSlide(ctrl: _entryCtrl, delay: 0.30,
                child: Column(children: [

                  _GlowButton(
                    label: '⚔️  Log In',
                    enabled: true, p: p,
                    onTap: () { HapticFeedback.lightImpact(); context.push('/login'); },
                  ),

                  SizedBox(height: 14.h),

                  // Outlined secondary button
                  GestureDetector(
                    onTap: () { HapticFeedback.lightImpact(); context.push('/signup'); },
                    child: Container(
                      height: 54.h, width: double.infinity,
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(16.r),
                        border: Border.all(color: p.hint.withOpacity(0.3)),
                        boxShadow: [BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10, offset: const Offset(0, 4))],
                      ),
                      child: Center(
                        child: Text('Create Account',
                            style: GoogleFonts.dmMono(
                                fontSize: 14.sp, color: p.text, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),

                  SizedBox(height: 32.h),
                  _DividerRow(p: p, label: 'or continue with'),
                  SizedBox(height: 20.h),
                  _SocialRow(p: p),
                  SizedBox(height: 30.h),
                ]),
              ),

            ]),
          ),
        ),
      ]),
    );
  }
}