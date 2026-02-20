import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
// PAGE VIEW 1  —  individual onboarding slide
// ─────────────────────────────────────────────────────────────────────────────
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
  late Animation<double>   _fade;
  late Animation<Offset>   _slide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();

    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);

    _slide = Tween<Offset>(
      begin: const Offset(0, 0.18),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);

    return Padding(
      // mirrors your original AppSizes.tPob / AppSizes.hP values
      padding: EdgeInsets.only(top: 100.h, left: 24.w, right: 24.w),
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Column(
            children: [

              // ── Illustration ───────────────────────────────────────────
              AnimatedContainer(
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [
                    BoxShadow(
                      // accent-tinted glow instead of plain black/white
                      color: p.accent.withOpacity(0.18),
                      blurRadius: 36,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: Image(
                    image: AssetImage(widget.image),
                    height: widget.height != null ? widget.height!.h : 300.h,
                    width:  widget.width  != null ? widget.width!.w  : double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

              SizedBox(height: 48.h),

              // ── Title ──────────────────────────────────────────────────
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmSerifDisplay(
                  fontSize: 26.sp,
                  color: p.text,
                  height: 1.25,
                ),
              ),

              SizedBox(height: 16.h),

              // ── Subtitle ───────────────────────────────────────────────
              Text(
                widget.subTitle,
                textAlign: TextAlign.center,
                style: GoogleFonts.dmMono(
                  fontSize: 13.sp,
                  color: p.sub,
                  height: 1.6,
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}