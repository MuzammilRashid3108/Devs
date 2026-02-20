import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NAV DESTINATIONS
// ─────────────────────────────────────────────────────────────────────────────
enum NavDest { battle, rank, home, profile, settings }

extension NavDestX on NavDest {
  String get route {
    switch (this) {
      case NavDest.battle:   return '/battle';
      case NavDest.rank:     return '/rank';
      case NavDest.home:     return '/level';
      case NavDest.profile:  return '/profile';
      case NavDest.settings: return '/settings';
    }
  }

  IconData get icon {
    switch (this) {
      case NavDest.battle:   return Icons.flash_on_rounded;
      case NavDest.rank:     return Icons.emoji_events_rounded;
      case NavDest.home:     return Icons.home_rounded;
      case NavDest.profile:  return Icons.person_rounded;
      case NavDest.settings: return Icons.settings_rounded;
    }
  }

  String get label {
    switch (this) {
      case NavDest.battle:   return 'Battle';
      case NavDest.rank:     return 'Rank';
      case NavDest.home:     return 'Home';
      case NavDest.profile:  return 'Profile';
      case NavDest.settings: return 'Settings';
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED BOTTOM NAV BAR
// Usage: AppNavBar(current: NavDest.home)
// ─────────────────────────────────────────────────────────────────────────────
class AppNavBar extends StatelessWidget {
  final NavDest current;
  const AppNavBar({super.key, required this.current});

  // Inline palette so this file has zero external dependencies
  static Color _bg(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF13101C)
          : const Color(0xFFFFFFFF);

  static Color _hint(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF2A2640)
          : const Color(0xFFB8B4CC);

  static Color _accent(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF9D8FF7)
          : const Color(0xFF7C6EF5);

  static Color _accentSoft(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark
          ? const Color(0xFF1E1A38)
          : const Color(0xFFEBE8FD);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(top: 12.h, bottom: 26.h, left: 18.w, right: 18.w),
      decoration: BoxDecoration(
        color: _bg(context).withOpacity(0.96),
        border: Border(top: BorderSide(color: _hint(context).withOpacity(0.10))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 30,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: NavDest.values.map((dest) {
          final isActive = dest == current;
          return _NavBtn(
            dest: dest,
            active: isActive,
            accentColor: _accent(context),
            accentSoft: _accentSoft(context),
            hintColor: _hint(context),
            onTap: () {
              if (!isActive) {
                HapticFeedback.lightImpact();
                context.go(dest.route);
              }
            },
          );
        }).toList(),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// NAV BUTTON (private to this file)
// ─────────────────────────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  final NavDest dest;
  final bool active;
  final Color accentColor, accentSoft, hintColor;
  final VoidCallback onTap;

  const _NavBtn({
    required this.dest,
    required this.active,
    required this.accentColor,
    required this.accentSoft,
    required this.hintColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.symmetric(
        horizontal: active ? 13.w : 8.w,
        vertical: 7.h,
      ),
      decoration: BoxDecoration(
        color: active ? accentSoft : Colors.transparent,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(dest.icon, size: 20.sp, color: active ? accentColor : hintColor),
        if (active) ...[
          SizedBox(width: 5.w),
          Text(
            dest.label,
            style: GoogleFonts.dmMono(
              fontSize: 11.sp,
              color: accentColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ]),
    ),
  );
}