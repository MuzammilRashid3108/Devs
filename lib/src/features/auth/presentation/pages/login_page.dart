import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/auth_services.dart'; // ← keep your original import

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
// ANIMATED TEXT FIELD
// ─────────────────────────────────────────────────────────────────────────────
class _Field extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label, hint;
  final IconData icon;
  final bool obscure, showToggle;
  final TextInputType keyboard;
  final _Palette p;

  const _Field({
    required this.controller, required this.focusNode,
    required this.label,      required this.hint,
    required this.icon,       required this.p,
    this.obscure = false, this.showToggle = false,
    this.keyboard = TextInputType.text,
  });

  @override
  State<_Field> createState() => _FieldState();
}

class _FieldState extends State<_Field> {
  bool _focused = false;
  bool _hidden  = true;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(
            () => setState(() => _focused = widget.focusNode.hasFocus));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(widget.label,
          style: GoogleFonts.dmMono(
            fontSize: 10.sp,
            color: _focused ? p.accent : p.sub,
            fontWeight: FontWeight.w600, letterSpacing: 0.5,
          )),
      SizedBox(height: 6.h),
      AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: _focused ? p.accentMid : p.hint.withOpacity(0.35),
            width: _focused ? 1.5 : 1,
          ),
          boxShadow: _focused
              ? [BoxShadow(color: p.accent.withOpacity(0.12),
              blurRadius: 14, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller:   widget.controller,
          focusNode:    widget.focusNode,
          obscureText:  widget.obscure && _hidden,
          keyboardType: widget.keyboard,
          style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.text),
          decoration: InputDecoration(
            hintText:  widget.hint,
            hintStyle: GoogleFonts.dmMono(fontSize: 12.sp, color: p.hint),
            prefixIcon: Icon(widget.icon, size: 18.sp,
                color: _focused ? p.accent : p.hint),
            suffixIcon: widget.showToggle
                ? IconButton(
              icon: Icon(
                _hidden ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                size: 18.sp, color: _focused ? p.accent : p.hint,
              ),
              onPressed: () => setState(() => _hidden = !_hidden),
            )
                : null,
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL CHIPS ROW
// ─────────────────────────────────────────────────────────────────────────────
class _SocialRow extends StatelessWidget {
  final _Palette p;
  const _SocialRow({required this.p});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _SocialChip(label: 'Google',  symbol: 'G',  color: const Color(0xFFEA4335), p: p),
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
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                blurRadius: 8, offset: const Offset(0, 3))],
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
// BACK BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _BackBtn extends StatelessWidget {
  final _Palette p;
  final VoidCallback onTap;
  const _BackBtn({required this.p, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40.w, height: 40.w,
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: p.hint.withOpacity(0.2)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
            blurRadius: 10, offset: const Offset(0, 3))],
      ),
      child: Icon(Icons.arrow_back_ios_new_rounded, size: 15.sp, color: p.text),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// LOGIN PAGE
// ─────────────────────────────────────────────────────────────────────────────
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _focusEmail   = FocusNode();
  final _focusPass    = FocusNode();

  late final AnimationController _meshCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double>   _meshAnim;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _meshCtrl  = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _meshAnim  = CurvedAnimation(parent: _meshCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose();
    _focusEmail.dispose(); _focusPass.dispose();
    _meshCtrl.dispose(); _entryCtrl.dispose();
    super.dispose();
  }

  // ── Auth logic — identical to your original ─────────────────────────────────
  Future<void> _login() async {
    final email    = _emailCtrl.text.trim();
    final password = _passwordCtrl.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _snack('Please fill all fields'); return;
    }
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInWithEmail(email, password);
      if (user != null && mounted) {
        context.go('/home');
      } else if (mounted) {
        _snack('Login Failed: Incorrect email or password');
      }
    } catch (e) {
      if (mounted) _snack('Error: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _snack(String msg) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(msg, style: GoogleFonts.dmMono())));

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

        GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                SizedBox(height: 14.h),

                // ── Back ──────────────────────────────────────────────────
                _FadeSlide(ctrl: _entryCtrl, delay: 0.0,
                    child: _BackBtn(p: p, onTap: () => context.go('/welcome'))),

                SizedBox(height: 36.h),

                // ── Heading ───────────────────────────────────────────────
                _FadeSlide(ctrl: _entryCtrl, delay: 0.08,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Login Your',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 38.sp, color: p.text)),
                      Text('Account',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 38.sp, color: p.accent)),
                      SizedBox(height: 8.h),
                      Text('Welcome back, warrior. 👾',
                          style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub)),
                    ])),

                SizedBox(height: 40.h),

                // ── Email ─────────────────────────────────────────────────
                _FadeSlide(ctrl: _entryCtrl, delay: 0.16,
                    child: _Field(
                      controller: _emailCtrl, focusNode: _focusEmail,
                      label: 'Email', hint: 'your@email.com',
                      icon: Icons.alternate_email_rounded,
                      keyboard: TextInputType.emailAddress, p: p,
                    )),

                SizedBox(height: 16.h),

                // ── Password ──────────────────────────────────────────────
                _FadeSlide(ctrl: _entryCtrl, delay: 0.22,
                    child: _Field(
                      controller: _passwordCtrl, focusNode: _focusPass,
                      label: 'Password', hint: '••••••••',
                      icon: Icons.lock_outline_rounded,
                      obscure: true, showToggle: true, p: p,
                    )),

                SizedBox(height: 12.h),

                // ── Forgot password ───────────────────────────────────────
                _FadeSlide(ctrl: _entryCtrl, delay: 0.26,
                    child: Align(alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => context.push('/forgetPs'),
                          child: Text('Forgot Password?',
                              style: GoogleFonts.dmMono(
                                  fontSize: 12.sp, color: p.accent, fontWeight: FontWeight.w600)),
                        ))),

                SizedBox(height: 30.h),

                // ── Login button ──────────────────────────────────────────
                _FadeSlide(ctrl: _entryCtrl, delay: 0.32,
                    child: _isLoading
                        ? Center(child: SizedBox(
                        width: 24.w, height: 24.w,
                        child: CircularProgressIndicator(strokeWidth: 2.5, color: p.accent)))
                        : _GlowButton(
                        label: '⚔️  Log In', enabled: true, p: p, onTap: _login)),

                SizedBox(height: 28.h),

                // ── Signup link ───────────────────────────────────────────
                _FadeSlide(ctrl: _entryCtrl, delay: 0.36,
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Text('New here? ',
                          style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.sub)),
                      GestureDetector(
                        onTap: () => context.push('/signup'),
                        child: Text('Create Account',
                            style: GoogleFonts.dmMono(
                                fontSize: 13.sp, color: p.accent, fontWeight: FontWeight.w700)),
                      ),
                    ])),

                SizedBox(height: 28.h),

                _FadeSlide(ctrl: _entryCtrl, delay: 0.40,
                    child: _DividerRow(p: p, label: 'or continue with')),
                SizedBox(height: 20.h),
                _FadeSlide(ctrl: _entryCtrl, delay: 0.44,
                    child: _SocialRow(p: p)),
                SizedBox(height: 36.h),

              ]),
            ),
          ),
        ),
      ]),
    );
  }
}