import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/data/level_service.dart';
import '../../../home/data/progress_service.dart';
import '../../services/auth_services.dart';

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
        position: Tween<Offset>(
            begin: const Offset(0, 0.06), end: Offset.zero).animate(curve),
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

  const _GlowButton(
      {required this.label, required this.enabled, required this.p, this.onTap});

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double>   _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 120));
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
                  fontSize: 14.sp,
                  color: widget.enabled ? Colors.white : p.hint,
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
  bool shouldRepaint(covariant _MeshPainter old) =>
      old.t != t || old.isDark != isDark;
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
                _hidden
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                size: 18.sp, color: _focused ? p.accent : p.hint,
              ),
              onPressed: () => setState(() => _hidden = !_hidden),
            )
                : null,
            border: InputBorder.none,
            contentPadding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 15.h),
          ),
        ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SOCIAL CHIPS ROW  — accepts an onGoogleTap callback
// ─────────────────────────────────────────────────────────────────────────────
class _SocialRow extends StatelessWidget {
  final _Palette p;
  final VoidCallback onGoogleTap;   // ← NEW

  const _SocialRow({required this.p, required this.onGoogleTap});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      _SocialChip(
        label: 'Google', symbol: 'G',
        color: const Color(0xFFEA4335), p: p,
        onTap: onGoogleTap,           // ← wired up
      ),
      SizedBox(width: 12.w),
      _SocialChip(label: 'Apple',   symbol: '🍎', color: p.text, p: p, onTap: () {}),
      SizedBox(width: 12.w),
      _SocialChip(label: 'Twitter', symbol: '𝕏',  color: p.text, p: p, onTap: () {}),
    ],
  );
}

class _SocialChip extends StatefulWidget {
  final String label, symbol;
  final Color color;
  final _Palette p;
  final VoidCallback onTap;         // ← NEW

  const _SocialChip({
    required this.label, required this.symbol,
    required this.color, required this.p,
    required this.onTap,            // ← NEW
  });

  @override
  State<_SocialChip> createState() => _SocialChipState();
}

class _SocialChipState extends State<_SocialChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double>   _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 100));
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
      onTapUp: (_) {
        _c.reverse();
        HapticFeedback.selectionClick();
        widget.onTap();             // ← actually calls the handler
      },
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
          style: GoogleFonts.dmMono(
              fontSize: 10.sp, color: p.sub, letterSpacing: 0.3)),
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
// SIGNUP PAGE
// ─────────────────────────────────────────────────────────────────────────────
class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> with TickerProviderStateMixin {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _focusName    = FocusNode();
  final _focusEmail   = FocusNode();
  final _focusPass    = FocusNode();

  late final AnimationController _meshCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double>   _meshAnim;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _meshCtrl = AnimationController(
        vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _meshAnim = CurvedAnimation(parent: _meshCtrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
    _focusName.dispose(); _focusEmail.dispose(); _focusPass.dispose();
    _meshCtrl.dispose(); _entryCtrl.dispose();
    super.dispose();
  }

  // ── Email signup ─────────────────────────────────────────────────────────────
  Future<void> _signup() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final result = await AuthService().signUpWithEmail(
        email:    _emailCtrl.text.trim(),
        password: _passwordCtrl.text.trim(),
        username: _nameCtrl.text.trim(),
      );
      if (!mounted) return;
      if (result.isSuccess) {
        try {
          final levels = await LevelService().getLevels();
          await ProgressService().initProgress(result.user!.uid, levels);
          if (mounted) context.go('/home');
        } catch (e) {
          _snack('Progress init failed: $e');
        }
      } else {
        _snack(result.error ?? 'Signup failed');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Google signup / login ─────────────────────────────────────────────────────
  // Google auth doesn't have a separate "signup" — signInWithGoogle handles both
  // new and returning users. For new Google users, the Firestore doc is created
  // inside AuthService.signInWithGoogle (isNewUser check). We still init progress
  // here so that new Google users get their level progress set up correctly.
  Future<void> _signupWithGoogle() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final user = await AuthService().signInWithGoogle();
      if (!mounted) return;
      if (user != null) {
        // Init progress for new Google users (safe to call — check inside service
        // or guard with a try/catch if already initialised)
        try {
          final levels = await LevelService().getLevels();
          await ProgressService().initProgress(user.uid, levels);
        } catch (_) {
          // progress may already exist for returning Google users — that's fine
        }
        if (mounted) context.go('/home');
      } else {
        _snack('Google sign-in was cancelled or failed. Please try again.');
      }
    } catch (e) {
      if (mounted) _snack('Google sign-in error: $e');
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
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    SizedBox(height: 14.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.0,
                        child: _BackBtn(p: p, onTap: () => context.go('/welcome'))),

                    SizedBox(height: 36.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.08,
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Create Your',
                                  style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 38.sp, color: p.text)),
                              Text('Account',
                                  style: GoogleFonts.dmSerifDisplay(
                                      fontSize: 38.sp, color: p.accent)),
                              SizedBox(height: 8.h),
                              Text('Join the arena. Prove your code. 🏆',
                                  style: GoogleFonts.dmMono(
                                      fontSize: 12.sp, color: p.sub)),
                            ])),

                    SizedBox(height: 40.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.14,
                        child: _Field(
                          controller: _nameCtrl, focusNode: _focusName,
                          label: 'Full Name', hint: 'Ada Lovelace',
                          icon: Icons.person_outline_rounded, p: p,
                        )),

                    SizedBox(height: 16.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.20,
                        child: _Field(
                          controller: _emailCtrl, focusNode: _focusEmail,
                          label: 'Email', hint: 'your@email.com',
                          icon: Icons.alternate_email_rounded,
                          keyboard: TextInputType.emailAddress, p: p,
                        )),

                    SizedBox(height: 16.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.26,
                        child: _Field(
                          controller: _passwordCtrl, focusNode: _focusPass,
                          label: 'Password', hint: '••••••••',
                          icon: Icons.lock_outline_rounded,
                          obscure: true, showToggle: true, p: p,
                        )),

                    SizedBox(height: 32.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.32,
                        child: _isLoading
                            ? Center(child: SizedBox(
                            width: 24.w, height: 24.w,
                            child: CircularProgressIndicator(
                                strokeWidth: 2.5, color: p.accent)))
                            : _GlowButton(
                            label: '🚀  Register',
                            enabled: true, p: p, onTap: _signup)),

                    SizedBox(height: 28.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.36,
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('Already have an account? ',
                                  style: GoogleFonts.dmMono(
                                      fontSize: 13.sp, color: p.sub)),
                              GestureDetector(
                                onTap: () => context.push('/login'),
                                child: Text('Log In',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 13.sp, color: p.accent,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ])),

                    SizedBox(height: 28.h),

                    _FadeSlide(ctrl: _entryCtrl, delay: 0.40,
                        child: _DividerRow(p: p, label: 'or continue with')),

                    SizedBox(height: 20.h),

                    // ── SocialRow now receives the real Google handler ──────────
                    _FadeSlide(ctrl: _entryCtrl, delay: 0.44,
                        child: _SocialRow(p: p, onGoogleTap: _signupWithGoogle)),

                    SizedBox(height: 36.h),
                  ]),
            ),
          ),
        ),
      ]),
    );
  }
}