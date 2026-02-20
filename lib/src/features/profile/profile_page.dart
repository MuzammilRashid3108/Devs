import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADAPTIVE PALETTE (same as LevelMapPage)
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

  static _Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA MODELS
// ─────────────────────────────────────────────────────────────────────────────
class _Badge {
  final String emoji, label, sublabel;
  final Color color;
  final bool earned;
  const _Badge({
    required this.emoji, required this.label,
    required this.sublabel, required this.color, required this.earned,
  });
}

class _StatItem {
  final String label, value, emoji;
  final Color color;
  const _StatItem({required this.label, required this.value,
    required this.emoji, required this.color});
}

const _badges = [
  _Badge(emoji: '⚡', label: 'Speed Demon',    sublabel: 'Solved in <60s',      color: Color(0xFFFFB82E), earned: true),
  _Badge(emoji: '🔥', label: 'On Fire',        sublabel: '7-day streak',         color: Color(0xFFFF6B6B), earned: true),
  _Badge(emoji: '🧠', label: 'Big Brain',      sublabel: '10 Hard problems',     color: Color(0xFF9D8FF7), earned: true),
  _Badge(emoji: '🌟', label: 'All-Star',       sublabel: 'Triple star × 5',      color: Color(0xFF3DD68C), earned: true),
  _Badge(emoji: '👑', label: 'Grandmaster',    sublabel: 'Top 1% global',        color: Color(0xFFFFB82E), earned: true),
  _Badge(emoji: '💎', label: 'Perfectionist',  sublabel: '20 perfect runs',      color: Color(0xFF9D8FF7), earned: false),
  _Badge(emoji: '🌋', label: 'Inferno Coder',  sublabel: 'Beat Inferno Peaks',   color: Color(0xFFFF6B6B), earned: false),
  _Badge(emoji: '☠️',  label: 'Shadow Slayer',  sublabel: 'Beat Shadow Sanctum',  color: Color(0xFF8A85A0), earned: false),
];

const _stats = [
  _StatItem(label: 'Solved',    value: '127',    emoji: '✅', color: Color(0xFF3DD68C)),
  _StatItem(label: 'Win Rate',  value: '73%',    emoji: '⚔️',  color: Color(0xFF9D8FF7)),
  _StatItem(label: 'Streak',    value: '17',     emoji: '🔥', color: Color(0xFFFF6B6B)),
  _StatItem(label: 'Rank',      value: '#284',   emoji: '🏆', color: Color(0xFFFFB82E)),
];

const _activityGrid = [
  // 1 = low, 2 = med, 3 = high, 0 = none — 10 weeks × 7 days
  [0,1,2,1,0,2,3], [1,3,2,0,1,1,2], [0,0,1,2,3,2,1],
  [2,1,0,3,2,1,0], [1,2,3,2,1,0,1], [0,1,2,1,3,2,0],
  [3,2,1,0,1,2,3], [1,0,2,3,1,2,1], [2,1,1,2,0,3,2],
  [1,2,0,1,3,2,1],
];

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _floatCtrl;
  late final ScrollController    _scrollCtrl;

  bool _editMode = false;
  String _username  = 'ByteSlayer';
  String _title     = 'Grandmaster  👑';
  String _bio       = 'I speak in Big-O. Recursion is my religion. 🧠';
  String _country   = '🇵🇰 Pakistan';

  @override
  void initState() {
    super.initState();
    _bgCtrl    = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _scrollCtrl = ScrollController();
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); _entryCtrl.dispose();
    _pulseCtrl.dispose(); _floatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p      = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(children: [
        // ── Ambient starfield background (same as map) ──────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _StarfieldPainter(
                CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value,
                isDark),
          ),
        ),

        SafeArea(
          child: Column(children: [
            _buildTopBar(p),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollCtrl,
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.only(bottom: 110.h),
                child: Column(children: [
                  _buildHeroCard(p, isDark),
                  SizedBox(height: 16.h),
                  _buildStatsRow(p),
                  SizedBox(height: 16.h),
                  _buildActivityHeatmap(p, isDark),
                  SizedBox(height: 16.h),
                  _buildBadgesSection(p),
                  SizedBox(height: 16.h),
                  _buildLanguagesCard(p),
                  SizedBox(height: 16.h),
                  _buildRecentBattles(p),
                ]),
              ),
            ),
          ]),
        ),

        Positioned(bottom: 0, left: 0, right: 0, child: _buildNav(p)),
      ]),
    );
  }

  // ── Top Bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(_Palette p) => Padding(
    padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 0),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.maybePop(context),
        child: Container(
          padding: EdgeInsets.all(9.w),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: p.hint.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08),
                blurRadius: 12, offset: const Offset(0, 3))],
          ),
          child: Icon(Icons.arrow_back_ios_new_rounded,
              size: 16.sp, color: p.sub),
        ),
      ),
      SizedBox(width: 12.w),
      Text('Profile',
          style: GoogleFonts.dmSerifDisplay(fontSize: 20.sp, color: p.text)),
      const Spacer(),
      _editToggleBtn(p),
    ]),
  );

  Widget _editToggleBtn(_Palette p) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      setState(() => _editMode = !_editMode);
    },
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: _editMode ? p.accent : p.accentSoft,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: p.accent.withOpacity(0.35)),
        boxShadow: _editMode
            ? [BoxShadow(color: p.accent.withOpacity(0.35), blurRadius: 12)]
            : [],
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(_editMode ? Icons.check_rounded : Icons.edit_rounded,
            size: 14.sp,
            color: _editMode ? Colors.white : p.accent),
        SizedBox(width: 5.w),
        Text(_editMode ? 'Save' : 'Edit',
            style: GoogleFonts.dmMono(
                fontSize: 11.sp,
                color: _editMode ? Colors.white : p.accent,
                fontWeight: FontWeight.w700)),
      ]),
    ),
  );

  // ── Hero Card ─────────────────────────────────────────────────────────────
  Widget _buildHeroCard(_Palette p, bool isDark) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -0.12), end: Offset.zero)
            .animate(CurvedAnimation(parent: _entryCtrl,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut))),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 18.w),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: p.hint.withOpacity(0.12)),
            boxShadow: [
              BoxShadow(color: p.accent.withOpacity(isDark ? 0.08 : 0.06),
                  blurRadius: 32, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.07),
                  blurRadius: 16, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(children: [
            // Top banner strip with gradient
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
              child: Container(
                height: 72.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      p.accent.withOpacity(0.85),
                      const Color(0xFF3DD68C).withOpacity(0.6),
                      p.gold.withOpacity(0.4),
                    ],
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                  ),
                ),
                child: CustomPaint(
                  painter: _BannerSparkPainter(isDark),
                ),
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 0, 18.w, 18.h),
              child: Column(children: [
                // Avatar row — overlaps banner
                Transform.translate(
                  offset: Offset(0, -28.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Avatar
                      AnimatedBuilder(
                        animation: _pulseCtrl,
                        builder: (_, child) {
                          final pulse = CurvedAnimation(
                              parent: _pulseCtrl, curve: Curves.easeInOut).value;
                          return Stack(alignment: Alignment.center, children: [
                            Container(
                              width: 72.w + pulse * 6,
                              height: 72.w + pulse * 6,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: p.accent.withOpacity(0.10 + pulse * 0.08),
                              ),
                            ),
                            child!,
                          ]);
                        },
                        child: _editMode
                            ? GestureDetector(
                          onTap: () => _showAvatarPicker(context, p),
                          child: Stack(children: [
                            _avatarContainer(p),
                            Positioned(
                              bottom: 0, right: 0,
                              child: Container(
                                padding: EdgeInsets.all(4.w),
                                decoration: BoxDecoration(
                                  color: p.accent,
                                  shape: BoxShape.circle,
                                  border: Border.all(color: p.surface, width: 1.5),
                                ),
                                child: Icon(Icons.camera_alt_rounded,
                                    size: 10.sp, color: Colors.white),
                              ),
                            ),
                          ]),
                        )
                            : _avatarContainer(p),
                      ),
                      SizedBox(width: 10.w),
                      // XP bar column
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 4.h),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            SizedBox(height: 32.h), // push below banner
                            Row(children: [
                              Container(
                                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                                decoration: BoxDecoration(
                                  color: p.goldSoft,
                                  borderRadius: BorderRadius.circular(7.r),
                                  border: Border.all(color: p.gold.withOpacity(0.35)),
                                ),
                                child: Text('⭐ Season 3',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 7.5.sp, color: p.gold,
                                        fontWeight: FontWeight.w700)),
                              ),
                            ]),
                            SizedBox(height: 5.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('8,250 XP',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 9.sp, color: p.accent,
                                        fontWeight: FontWeight.w700)),
                                Text('10,000 XP',
                                    style: GoogleFonts.dmMono(
                                        fontSize: 9.sp, color: p.sub)),
                              ],
                            ),
                            SizedBox(height: 4.h),
                            _XpBar(progress: 0.825, p: p),
                          ]),
                        ),
                      ),
                    ],
                  ),
                ),

                // Username + title (pulled up due to negative translate above)
                Transform.translate(
                  offset: Offset(0, -22.h),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      Expanded(
                        child: _editMode
                            ? _EditField(
                          value: _username,
                          style: GoogleFonts.dmSerifDisplay(
                              fontSize: 22.sp, color: p.text),
                          onChanged: (v) => setState(() => _username = v),
                        )
                            : Text(_username,
                            style: GoogleFonts.dmSerifDisplay(
                                fontSize: 22.sp, color: p.text)),
                      ),
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
                        decoration: BoxDecoration(
                          color: p.winSoft,
                          borderRadius: BorderRadius.circular(7.r),
                        ),
                        child: Text('✔ Verified',
                            style: GoogleFonts.dmMono(
                                fontSize: 7.sp, color: p.win,
                                fontWeight: FontWeight.w700)),
                      ),
                    ]),
                    SizedBox(height: 3.h),
                    _editMode
                        ? _EditField(
                      value: _title,
                      style: GoogleFonts.dmMono(
                          fontSize: 10.sp, color: p.gold,
                          fontWeight: FontWeight.w700),
                      onChanged: (v) => setState(() => _title = v),
                    )
                        : Text(_title,
                        style: GoogleFonts.dmMono(
                            fontSize: 10.sp, color: p.gold,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 8.h),
                    _editMode
                        ? _EditField(
                      value: _bio,
                      style: GoogleFonts.dmMono(
                          fontSize: 10.5.sp, color: p.sub, height: 1.5),
                      onChanged: (v) => setState(() => _bio = v),
                      maxLines: 2,
                    )
                        : Text(_bio,
                        style: GoogleFonts.dmMono(
                            fontSize: 10.5.sp, color: p.sub, height: 1.5)),
                    SizedBox(height: 10.h),
                    // Meta row
                    Row(children: [
                      _MetaChip(icon: Icons.public_rounded,
                          label: _country, p: p,
                          onTap: _editMode ? () => _showCountryPicker(context, p) : null),
                      SizedBox(width: 6.w),
                      _MetaChip(icon: Icons.calendar_today_rounded,
                          label: 'Joined Jan 2024', p: p),
                      SizedBox(width: 6.w),
                      _MetaChip(icon: Icons.link_rounded,
                          label: 'byteslayer.dev', p: p),
                    ]),
                  ]),
                ),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _avatarContainer(_Palette p) => Container(
    width: 64.w, height: 64.w,
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
        begin: Alignment.topLeft, end: Alignment.bottomRight,
      ),
      shape: BoxShape.circle,
      border: Border.all(color: p.surface, width: 3),
      boxShadow: [
        BoxShadow(color: p.accent.withOpacity(0.4),
            blurRadius: 18, offset: const Offset(0, 4)),
      ],
    ),
    child: Center(child: Text('🧑‍💻', style: TextStyle(fontSize: 28.sp))),
  );

  // ── Stats Row ─────────────────────────────────────────────────────────────
  Widget _buildStatsRow(_Palette p) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 18.w),
        child: Row(
          children: List.generate(_stats.length, (i) {
            final s = _stats[i];
            return Expanded(
              child: AnimatedBuilder(
                animation: _entryCtrl,
                builder: (_, child) {
                  final t = CurvedAnimation(
                    parent: _entryCtrl,
                    curve: Interval(0.1 + i * 0.07, 0.1 + i * 0.07 + 0.4,
                        curve: Curves.elasticOut),
                  ).value;
                  return Transform.scale(scale: t, child: child);
                },
                child: Container(
                  margin: EdgeInsets.only(right: i < _stats.length - 1 ? 8.w : 0),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  decoration: BoxDecoration(
                    color: p.surface,
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(color: s.color.withOpacity(0.2)),
                    boxShadow: [
                      BoxShadow(color: s.color.withOpacity(0.08),
                          blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(s.emoji, style: TextStyle(fontSize: 16.sp)),
                    SizedBox(height: 4.h),
                    Text(s.value,
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 16.sp, color: s.color)),
                    SizedBox(height: 2.h),
                    Text(s.label,
                        style: GoogleFonts.dmMono(
                            fontSize: 7.5.sp, color: p.sub,
                            fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Activity Heatmap ──────────────────────────────────────────────────────
  Widget _buildActivityHeatmap(_Palette p, bool isDark) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.2, 0.7, curve: Curves.easeOut)),
      child: _SectionCard(
        p: p,
        title: '📅  Activity',
        trailing: Text('127 days solved',
            style: GoogleFonts.dmMono(fontSize: 9.sp, color: p.sub)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Day labels
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((d) =>
                SizedBox(
                  width: 22.w,
                  child: Center(
                    child: Text(d, style: GoogleFonts.dmMono(
                        fontSize: 7.sp, color: p.hint)),
                  ),
                )).toList(),
          ),
          SizedBox(height: 4.h),
          // Grid
          ..._activityGrid.map((week) => Padding(
            padding: EdgeInsets.only(bottom: 3.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: week.map((level) {
                final colors = [
                  p.hint.withOpacity(0.15),
                  p.win.withOpacity(0.25),
                  p.win.withOpacity(0.55),
                  p.win,
                ];
                return Container(
                  margin: EdgeInsets.only(left: 3.w),
                  width: 16.w, height: 16.w,
                  decoration: BoxDecoration(
                    color: colors[level],
                    borderRadius: BorderRadius.circular(3.r),
                    boxShadow: level == 3
                        ? [BoxShadow(color: p.win.withOpacity(0.5),
                        blurRadius: 6)]
                        : null,
                  ),
                );
              }).toList(),
            ),
          )).toList(),
          SizedBox(height: 6.h),
          // Legend
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            Text('Less', style: GoogleFonts.dmMono(fontSize: 7.sp, color: p.hint)),
            SizedBox(width: 4.w),
            ...List.generate(4, (i) {
              final colors = [
                p.hint.withOpacity(0.15),
                p.win.withOpacity(0.25),
                p.win.withOpacity(0.55),
                p.win,
              ];
              return Container(
                margin: EdgeInsets.only(left: 3.w),
                width: 9.w, height: 9.w,
                decoration: BoxDecoration(
                  color: colors[i],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              );
            }),
            SizedBox(width: 4.w),
            Text('More', style: GoogleFonts.dmMono(fontSize: 7.sp, color: p.hint)),
          ]),
        ]),
      ),
    );
  }

  // ── Badges ────────────────────────────────────────────────────────────────
  Widget _buildBadgesSection(_Palette p) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.25, 0.75, curve: Curves.easeOut)),
      child: _SectionCard(
        p: p,
        title: '🎖️  Badges',
        trailing: Text('${_badges.where((b) => b.earned).length}/${_badges.length}',
            style: GoogleFonts.dmMono(fontSize: 9.sp, color: p.sub)),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            childAspectRatio: 0.78,
          ),
          itemCount: _badges.length,
          itemBuilder: (_, i) {
            final b = _badges[i];
            return AnimatedBuilder(
              animation: _entryCtrl,
              builder: (_, child) {
                final t = CurvedAnimation(
                  parent: _entryCtrl,
                  curve: Interval(0.25 + i * 0.035, 0.25 + i * 0.035 + 0.35,
                      curve: Curves.elasticOut),
                ).value;
                return Transform.scale(scale: t, child: child);
              },
              child: _BadgeTile(badge: b, p: p),
            );
          },
        ),
      ),
    );
  }

  // ── Languages ─────────────────────────────────────────────────────────────
  Widget _buildLanguagesCard(_Palette p) {
    final langs = [
      (name: 'Python',     pct: 0.52, color: const Color(0xFF3DD68C)),
      (name: 'JavaScript', pct: 0.28, color: const Color(0xFFFFB82E)),
      (name: 'C++',        pct: 0.14, color: const Color(0xFF9D8FF7)),
      (name: 'Rust',       pct: 0.06, color: const Color(0xFFFF6B6B)),
    ];
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.3, 0.8, curve: Curves.easeOut)),
      child: _SectionCard(
        p: p,
        title: '💻  Languages',
        child: Column(children: [
          // Segmented bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Row(
              children: langs.map((l) => Flexible(
                flex: (l.pct * 100).toInt(),
                child: Container(
                  height: 10.h,
                  color: l.color,
                ),
              )).toList(),
            ),
          ),
          SizedBox(height: 14.h),
          ...langs.map((l) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: Row(children: [
              Container(
                  width: 10.w, height: 10.w,
                  decoration: BoxDecoration(
                      color: l.color, shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: l.color.withOpacity(0.5), blurRadius: 6)])),
              SizedBox(width: 8.w),
              Text(l.name, style: GoogleFonts.dmMono(
                  fontSize: 11.sp, color: p.text, fontWeight: FontWeight.w600)),
              const Spacer(),
              Text('${(l.pct * 100).toInt()}%',
                  style: GoogleFonts.dmMono(
                      fontSize: 11.sp, color: l.color, fontWeight: FontWeight.w700)),
              SizedBox(width: 8.w),
              SizedBox(
                width: 80.w,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4.r),
                  child: LinearProgressIndicator(
                    value: l.pct,
                    minHeight: 5.h,
                    backgroundColor: l.color.withOpacity(0.12),
                    valueColor: AlwaysStoppedAnimation(l.color),
                  ),
                ),
              ),
            ]),
          )).toList(),
        ]),
      ),
    );
  }

  // ── Recent Battles ────────────────────────────────────────────────────────
  Widget _buildRecentBattles(_Palette p) {
    final battles = [
      (opponent: 'CodeNinja42', result: true,  problem: 'Merge Intervals',  time: '1m 47s', diff: 'Medium'),
      (opponent: 'algo_wizard',  result: false, problem: 'LRU Cache',        time: '3m 12s', diff: 'Hard'),
      (opponent: 'Xeno_Dev',    result: true,  problem: 'Binary Search',    time: '0m 58s', diff: 'Easy'),
      (opponent: 'PixelCoder',  result: true,  problem: 'Two Sum',          time: '0m 43s', diff: 'Easy'),
    ];
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.35, 0.85, curve: Curves.easeOut)),
      child: _SectionCard(
        p: p,
        title: '⚔️  Recent Battles',
        trailing: GestureDetector(
          onTap: () {},
          child: Text('View all →',
              style: GoogleFonts.dmMono(
                  fontSize: 9.sp, color: p.accent, fontWeight: FontWeight.w700)),
        ),
        child: Column(
          children: List.generate(battles.length, (i) {
            final b = battles[i];
            final diffColors = {
              'Easy': p.win, 'Medium': p.gold, 'Hard': p.loss,
            };
            return AnimatedBuilder(
              animation: _entryCtrl,
              builder: (_, child) {
                final t = CurvedAnimation(
                  parent: _entryCtrl,
                  curve: Interval(0.35 + i * 0.05, 0.35 + i * 0.05 + 0.35,
                      curve: Curves.easeOut),
                ).value;
                return Opacity(opacity: t,
                  child: Transform.translate(
                      offset: Offset(20 * (1 - t), 0), child: child),
                );
              },
              child: Container(
                margin: EdgeInsets.only(bottom: i < battles.length - 1 ? 8.h : 0),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: b.result ? p.winSoft : p.lossSoft,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                      color: (b.result ? p.win : p.loss).withOpacity(0.2)),
                ),
                child: Row(children: [
                  Text(b.result ? '⚔️' : '🛡️',
                      style: TextStyle(fontSize: 18.sp)),
                  SizedBox(width: 10.w),
                  Expanded(child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(b.problem, style: GoogleFonts.dmMono(
                          fontSize: 10.sp, color: p.text,
                          fontWeight: FontWeight.w700)),
                      SizedBox(height: 2.h),
                      Text('vs ${b.opponent}',
                          style: GoogleFonts.dmMono(
                              fontSize: 8.5.sp, color: p.sub)),
                    ],
                  )),
                  Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: 6.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: diffColors[b.diff]!.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(5.r),
                      ),
                      child: Text(b.diff, style: GoogleFonts.dmMono(
                          fontSize: 7.sp,
                          color: diffColors[b.diff]!,
                          fontWeight: FontWeight.w700)),
                    ),
                    SizedBox(height: 3.h),
                    Text(b.time, style: GoogleFonts.dmMono(
                        fontSize: 8.5.sp, color: p.sub)),
                  ]),
                  SizedBox(width: 6.w),
                  Text(b.result ? '🏆' : '💀',
                      style: TextStyle(fontSize: 14.sp)),
                ]),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ── Nav (same as map) ─────────────────────────────────────────────────────
  Widget _buildNav(_Palette p) => Container(
    padding: EdgeInsets.only(top: 12.h, bottom: 26.h, left: 18.w, right: 18.w),
    decoration: BoxDecoration(
      color: p.surface.withOpacity(0.96),
      border: Border(top: BorderSide(color: p.hint.withOpacity(0.10))),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.10),
          blurRadius: 30, offset: const Offset(0, -4))],
    ),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      _NavBtn(icon: Icons.flash_on_rounded,     label: 'Battle',   active: false, p: p),
      _NavBtn(icon: Icons.emoji_events_rounded, label: 'Rank',     active: false, p: p),
      _NavBtn(icon: Icons.home_rounded,         label: 'Home',     active: false, p: p),
      _NavBtn(icon: Icons.person_rounded,       label: 'Profile',  active: true,  p: p),
      _NavBtn(icon: Icons.settings_rounded,     label: 'Settings', active: false, p: p),
    ]),
  );

  void _showAvatarPicker(BuildContext ctx, _Palette p) {
    final avatars = ['🧑‍💻', '🦊', '🐉', '🤖', '👾', '🦁', '🐺', '🎭',
      '🧙‍♂️', '⚡', '🔮', '💀'];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: p.hint.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(99.r))),
          SizedBox(height: 16.h),
          Text('Choose Avatar',
              style: GoogleFonts.dmSerifDisplay(fontSize: 20.sp, color: p.text)),
          SizedBox(height: 16.h),
          GridView.count(
            crossAxisCount: 6,
            shrinkWrap: true,
            crossAxisSpacing: 8.w,
            mainAxisSpacing: 8.h,
            children: avatars.map((a) => GestureDetector(
              onTap: () { HapticFeedback.lightImpact(); Navigator.pop(ctx); },
              child: Container(
                decoration: BoxDecoration(
                  color: p.accentSoft,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: p.accent.withOpacity(0.25)),
                ),
                child: Center(child: Text(a, style: TextStyle(fontSize: 22.sp))),
              ),
            )).toList(),
          ),
        ]),
      ),
    );
  }

  void _showCountryPicker(BuildContext ctx, _Palette p) {
    final countries = ['🇵🇰 Pakistan', '🇺🇸 USA', '🇮🇳 India', '🇧🇷 Brazil',
      '🇩🇪 Germany', '🇬🇧 UK', '🇯🇵 Japan', '🇨🇦 Canada'];
    showModalBottomSheet(
      context: ctx,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: p.hint.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(99.r))),
          SizedBox(height: 16.h),
          Text('Select Country',
              style: GoogleFonts.dmSerifDisplay(fontSize: 20.sp, color: p.text)),
          SizedBox(height: 12.h),
          ...countries.map((c) => GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _country = c);
              Navigator.pop(ctx);
            },
            child: Container(
              margin: EdgeInsets.only(bottom: 6.h),
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 11.h),
              decoration: BoxDecoration(
                color: c == _country ? p.accentSoft : p.surface2,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                    color: c == _country
                        ? p.accent.withOpacity(0.4)
                        : Colors.transparent),
              ),
              child: Text(c, style: GoogleFonts.dmMono(
                  fontSize: 12.sp,
                  color: c == _country ? p.accent : p.text,
                  fontWeight: c == _country
                      ? FontWeight.w700 : FontWeight.w500)),
            ),
          )).toList(),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL REUSABLE WIDGETS
// ─────────────────────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final _Palette p;
  final String title;
  final Widget? trailing;
  final Widget child;
  const _SectionCard({required this.p, required this.title,
    this.trailing, required this.child});
  @override
  Widget build(BuildContext context) => Container(
    margin: EdgeInsets.symmetric(horizontal: 18.w),
    padding: EdgeInsets.all(16.w),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: p.hint.withOpacity(0.10)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06),
          blurRadius: 14, offset: const Offset(0, 4))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Text(title, style: GoogleFonts.dmSerifDisplay(
            fontSize: 15.sp, color: p.text)),
        const Spacer(),
        if (trailing != null) trailing!,
      ]),
      SizedBox(height: 12.h),
      child,
    ]),
  );
}

class _BadgeTile extends StatelessWidget {
  final _Badge badge;
  final _Palette p;
  const _BadgeTile({required this.badge, required this.p});
  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.earned ? 1.0 : 0.35,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 4.w),
        decoration: BoxDecoration(
          color: badge.earned
              ? badge.color.withOpacity(0.08)
              : p.surface2,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
              color: badge.earned
                  ? badge.color.withOpacity(0.28)
                  : p.hint.withOpacity(0.15)),
          boxShadow: badge.earned
              ? [BoxShadow(color: badge.color.withOpacity(0.12),
              blurRadius: 8)]
              : null,
        ),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Text(badge.emoji, style: TextStyle(fontSize: badge.earned ? 20.sp : 16.sp)),
          SizedBox(height: 4.h),
          Text(badge.label, maxLines: 1, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmMono(
                  fontSize: 6.5.sp, color: badge.earned ? badge.color : p.hint,
                  fontWeight: FontWeight.w700)),
          SizedBox(height: 2.h),
          Text(badge.sublabel, maxLines: 1, overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: GoogleFonts.dmMono(fontSize: 5.5.sp, color: p.hint)),
        ]),
      ),
    );
  }
}

class _XpBar extends StatelessWidget {
  final double progress;
  final _Palette p;
  const _XpBar({required this.progress, required this.p});
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (_, c) => Stack(children: [
      Container(
        height: 7.h,
        decoration: BoxDecoration(
          color: p.accentSoft,
          borderRadius: BorderRadius.circular(99.r),
        ),
      ),
      Container(
        height: 7.h,
        width: c.maxWidth * progress,
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [p.accent, p.accentMid.withOpacity(0.6)]),
          borderRadius: BorderRadius.circular(99.r),
          boxShadow: [BoxShadow(color: p.accent.withOpacity(0.4), blurRadius: 6)],
        ),
      ),
    ]),
  );
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final _Palette p;
  final VoidCallback? onTap;
  const _MetaChip({required this.icon, required this.label,
    required this.p, this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: p.surface2,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: p.hint.withOpacity(0.2)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 9.sp, color: p.sub),
        SizedBox(width: 4.w),
        Text(label, style: GoogleFonts.dmMono(fontSize: 7.5.sp, color: p.sub,
            fontWeight: FontWeight.w600)),
        if (onTap != null) ...[
          SizedBox(width: 2.w),
          Icon(Icons.edit_rounded, size: 7.sp, color: p.accent),
        ],
      ]),
    ),
  );
}

class _EditField extends StatelessWidget {
  final String value;
  final TextStyle style;
  final ValueChanged<String> onChanged;
  final int maxLines;
  const _EditField({required this.value, required this.style,
    required this.onChanged, this.maxLines = 1});
  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    return TextFormField(
      initialValue: value,
      style: style,
      maxLines: maxLines,
      onChanged: onChanged,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        filled: true,
        fillColor: p.accentSoft,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: p.accent.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: p.accent, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.r),
          borderSide: BorderSide(color: p.accent.withOpacity(0.25)),
        ),
      ),
    );
  }
}

class _NavBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final _Palette p;
  const _NavBtn({required this.icon, required this.label,
    required this.active, required this.p});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 250),
    padding: EdgeInsets.symmetric(horizontal: active ? 13.w : 8.w, vertical: 7.h),
    decoration: BoxDecoration(
      color: active ? p.accentSoft : Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(icon, size: 20.sp, color: active ? p.accent : p.hint),
      if (active) ...[
        SizedBox(width: 5.w),
        Text(label, style: GoogleFonts.dmMono(
            fontSize: 11.sp, color: p.accent, fontWeight: FontWeight.w700)),
      ],
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS (matching map's style)
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

class _BannerSparkPainter extends CustomPainter {
  final bool isDark;
  const _BannerSparkPainter(this.isDark);
  @override
  void paint(Canvas canvas, Size size) {
    final rng  = math.Random(7);
    final cols = [Colors.white.withOpacity(0.20), Colors.white.withOpacity(0.10)];
    for (var i = 0; i < 18; i++) {
      canvas.drawCircle(
        Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
        rng.nextDouble() * 2.5 + 0.5,
        Paint()..color = cols[i % 2],
      );
    }
  }
  @override bool shouldRepaint(_) => false;
}