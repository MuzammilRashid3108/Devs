import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/widgets/nav_bar.dart';
import '../../../home/data/level_service.dart';
import '../../../home/data/progress_service.dart';
import '../../../home/domain/level_model.dart';
import '../../../home/domain/progress_model.dart';
import '../../../profile/data/user-service.dart';
import '../../../profile/domain/user_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
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
// DISPLAY MODEL
// ─────────────────────────────────────────────────────────────────────────────
class _DisplayLevel {
  final Level level;
  final UserProgress progress;
  const _DisplayLevel({required this.level, required this.progress});

  int    get number   => level.number;
  String get title    => level.title;
  String get tag      => level.tag;
  String get emoji    => level.emoji;
  int    get stars    => progress.stars;
  bool   get isDone   => progress.status == LevelStatus.done;
  bool   get isActive => progress.status == LevelStatus.active;
  bool   get isLocked => progress.status == LevelStatus.locked;
  bool   get isBoss   => level.tag == 'BOSS';

  Color get nodeColor {
    if (isLocked) return const Color(0xFF3A3558);
    switch (tag.toLowerCase()) {
      case 'easy':   return const Color(0xFF3DD68C);
      case 'medium': return stars == 1 ? const Color(0xFFFF6B6B) : const Color(0xFFFFB82E);
      case 'hard':   return const Color(0xFFFF6B6B);
      default:       return const Color(0xFFFFB82E);
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SNAKE PATH
// ─────────────────────────────────────────────────────────────────────────────
const _snake = [
  (x: 0.28, y: 0.96), (x: 0.58, y: 0.88), (x: 0.76, y: 0.79),
  (x: 0.62, y: 0.70), (x: 0.34, y: 0.62), (x: 0.16, y: 0.53),
  (x: 0.36, y: 0.44), (x: 0.64, y: 0.36), (x: 0.80, y: 0.27),
  (x: 0.60, y: 0.18), (x: 0.28, y: 0.11), (x: 0.50, y: 0.03),
];

// ─────────────────────────────────────────────────────────────────────────────
// ZONES
// ─────────────────────────────────────────────────────────────────────────────
const _zones = [
  (range: (0, 3),   color: Color(0xFF0D3018), label: '🌲 Greenwood Forest'),
  (range: (4, 7),   color: Color(0xFF0E0C28), label: '💎 Crystal Caverns'),
  (range: (8, 10),  color: Color(0xFF2E0C0C), label: '🌋 Inferno Peaks'),
  (range: (11, 11), color: Color(0xFF1E1600), label: '☠️  Shadow Sanctum'),
];
int _zoneOf(int i) {
  for (var z = 0; z < _zones.length; z++) {
    if (i >= _zones[z].range.$1 && i <= _zones[z].range.$2) return z;
  }
  return 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// PAGE
// ─────────────────────────────────────────────────────────────────────────────
class LevelMapPage extends StatefulWidget {
  const LevelMapPage({super.key});
  @override State<LevelMapPage> createState() => _LevelMapPageState();
}

class _LevelMapPageState extends State<LevelMapPage> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl, _pulseCtrl, _entryCtrl, _floatCtrl;
  late final ScrollController _scrollCtrl;

  AppUser?            _user;
  List<_DisplayLevel> _displayLevels = [];
  bool                _loading = true;
  String?             _error;

  final _lvlSvc  = LevelService();
  final _progSvc = ProgressService();
  final _usrSvc  = UserService();

  @override
  void initState() {
    super.initState();
    _bgCtrl    = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _scrollCtrl = ScrollController();
    _loadData();
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); _pulseCtrl.dispose();
    _entryCtrl.dispose(); _floatCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  // ── Load + auto-fix all-locked ───────────────────────────────────────────
  Future<void> _loadData() async {
    setState(() { _loading = true; _error = null; });
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) { if (mounted) context.go('/welcome'); return; }

      final results = await Future.wait([
        _usrSvc.getUser(uid),
        _lvlSvc.getLevels(),
        _progSvc.getUserProgress(uid),
      ]);

      final user   = results[0] as AppUser?;
      final levels = results[1] as List<Level>;
      var progMap  = results[2] as Map<String, UserProgress>;

      // ── If no progress docs exist yet → init now ─────────────────────────
      if (progMap.isEmpty && levels.isNotEmpty) {
        await _progSvc.initProgress(uid, levels);
        progMap = await _progSvc.getUserProgress(uid);
      }

      // ── If every single doc is locked → force level-1 to active ──────────
      // Covers: users created before initProgress existed, Firestore write
      // failures that left everyone locked, manual data wipes, etc.
      final allLocked = progMap.values.every((p) => p.status == LevelStatus.locked);
      if (allLocked && levels.isNotEmpty) {
        // Directly update the first level's document to 'active'
        await _progSvc.forceActivate(uid, levels.first.id);

        progMap = await _progSvc.getUserProgress(uid);
      }

      final displayLevels = levels.map((l) {
        final prog = progMap[l.id] ?? UserProgress.locked(l.id);
        return _DisplayLevel(level: l, progress: prog);
      }).toList();

      if (!mounted) return;
      setState(() { _user = user; _displayLevels = displayLevels; _loading = false; });
      _entryCtrl.forward();
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToActive());
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e.toString(); });
    }
  }

  void _scrollToActive() {
    if (!_scrollCtrl.hasClients) return;
    final ai = _displayLevels.indexWhere((l) => l.isActive);
    if (ai == -1 || ai >= _snake.length) return;
    final total = _scrollCtrl.position.maxScrollExtent;
    final dest  = (_snake[ai].y * total - 220).clamp(0.0, total);
    _scrollCtrl.animateTo(dest,
        duration: const Duration(milliseconds: 1000), curve: Curves.easeOutCubic);
  }

  // ── Build ────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p      = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(children: [
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _StarfieldPainter(
                CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value, isDark),
          ),
        ),
        SafeArea(
          child: _loading ? _buildLoading(p)
              : _error != null ? _buildError(p)
              : Column(children: [
            _buildHeader(p),
            _buildActionRow(p),
            Expanded(child: _buildMap(context, p, isDark, size)),
          ]),
        ),
        Positioned(bottom: 0, left: 0, right: 0,
            child: const AppNavBar(current: NavDest.home)),
      ]),
    );
  }

  // ── Loading / Error ───────────────────────────────────────────────────────
  Widget _buildLoading(_Palette p) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: 32.w, height: 32.w,
          child: CircularProgressIndicator(strokeWidth: 2.5, color: p.accent)),
      SizedBox(height: 16.h),
      Text('Loading your journey…',
          style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub)),
    ]),
  );

  Widget _buildError(_Palette p) => Center(
    child: Padding(padding: EdgeInsets.symmetric(horizontal: 32.w),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('⚠️', style: TextStyle(fontSize: 40.sp)),
        SizedBox(height: 12.h),
        Text('Failed to load', style: GoogleFonts.dmSerifDisplay(fontSize: 20.sp, color: p.text)),
        SizedBox(height: 6.h),
        Text(_error ?? '', textAlign: TextAlign.center,
            style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub)),
        SizedBox(height: 24.h),
        GestureDetector(
          onTap: _loadData,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            decoration: BoxDecoration(color: p.accentSoft,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: p.accent.withOpacity(0.4))),
            child: Text('Try Again', style: GoogleFonts.dmMono(
                fontSize: 13.sp, color: p.accent, fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    ),
  );

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(_Palette p) {
    final username = _user?.username ?? 'Warrior';
    final avatar   = _user?.avatar   ?? '🧑‍💻';
    final xp       = _user?.xp       ?? 0;
    final streak   = _user?.streak   ?? 0;
    return Padding(
      padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 0),
      child: Row(children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
          decoration: BoxDecoration(
            color: p.surface, borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: p.hint.withOpacity(0.15)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.09),
                blurRadius: 14, offset: const Offset(0, 3))],
          ),
          child: Row(children: [
            GestureDetector(
              onTap: () => context.go('/profile'),
              child: Container(
                width: 32.w, height: 32.w,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                      colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
                      begin: Alignment.topLeft, end: Alignment.bottomRight),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Center(child: Text(avatar, style: TextStyle(fontSize: 16.sp))),
              ),
            ),
            SizedBox(width: 9.w),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(username, style: GoogleFonts.dmSerifDisplay(fontSize: 14.sp, color: p.text)),
              Text(_rankLabel(xp), style: GoogleFonts.dmMono(
                  fontSize: 8.5.sp, color: p.gold, fontWeight: FontWeight.w700)),
            ]),
          ]),
        ),
        const Spacer(),
        _Chip(emoji: '⚡', label: '$xp XP', fg: p.accent, bg: p.accentSoft),
        SizedBox(width: 7.w),
        _Chip(emoji: '🔥', label: '$streak', fg: p.loss, bg: p.lossSoft),
      ]),
    );
  }

  String _rankLabel(int xp) {
    if (xp >= 10000) return 'Grandmaster  👑';
    if (xp >= 5000)  return 'Master  💎';
    if (xp >= 2000)  return 'Expert  🔮';
    if (xp >= 500)   return 'Apprentice  ⚔️';
    return 'Novice  🌱';
  }

  // ── Action row ────────────────────────────────────────────────────────────
  Widget _buildActionRow(_Palette p) {
    final items = [
      (e: '⚔️', l: 'Challenge',   c: p.loss,   b: p.lossSoft),
      (e: '🏆', l: 'Leaderboard', c: p.gold,   b: p.goldSoft),
      (e: '👥', l: 'Friends',     c: p.win,    b: p.winSoft),
      (e: '🎯', l: 'Daily',       c: p.accent, b: p.accentSoft),
    ];
    return SizedBox(
      height: 76.h,
      child: ListView.separated(
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 11.h),
        scrollDirection: Axis.horizontal,
        separatorBuilder: (_, __) => SizedBox(width: 9.w),
        itemCount: items.length,
        itemBuilder: (ctx, i) {
          final it = items[i];
          return FadeTransition(
            opacity: CurvedAnimation(parent: _entryCtrl,
                curve: Interval(i * 0.06, i * 0.06 + 0.5, curve: Curves.easeOut)),
            child: _ActionChip(
              emoji: it.e, label: it.l, fg: it.c, bg: it.b,
              onTap: () { HapticFeedback.lightImpact(); _openSheet(ctx, it.l, p); },
            ),
          );
        },
      ),
    );
  }

  // ── Map canvas ────────────────────────────────────────────────────────────
  Widget _buildMap(BuildContext ctx, _Palette p, bool isDark, Size screen) {
    final canvasH   = screen.height * 2.2;
    final canvasW   = screen.width;
    final count     = math.min(_displayLevels.length, _snake.length);
    final positions = List.generate(count,
            (i) => Offset(_snake[i].x * canvasW, _snake[i].y * canvasH));

    return SingleChildScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 130.h),
      child: SizedBox(width: canvasW, height: canvasH,
        child: Stack(clipBehavior: Clip.none, children: [
          ..._zoneTints(canvasW, canvasH, positions, isDark),
          CustomPaint(size: Size(canvasW, canvasH),
              painter: _RoadPainter(positions, _displayLevels, p, isDark)),
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              size: Size(canvasW, canvasH),
              painter: _SparkPainter(
                  CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value, isDark),
            ),
          ),
          for (var i = 0; i < count; i++)
            _buildNode(ctx, i, positions[i], p, canvasW),
          ..._zoneLabels(canvasW, positions, p),
        ]),
      ),
    );
  }

  List<Widget> _zoneTints(double w, double h, List<Offset> pos, bool isDark) =>
      _zones.map((z) {
        final maxI = math.min(z.range.$2, pos.length - 1);
        if (z.range.$1 >= pos.length) return const SizedBox.shrink();
        final ys  = [for (var i = z.range.$1; i <= maxI; i++) pos[i].dy];
        final top = ys.reduce(math.min) - 90;
        final bot = ys.reduce(math.max) + 90;
        return Positioned(
          left: 0, right: 0, top: top, height: bot - top,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter, end: Alignment.bottomCenter,
                colors: [
                  z.color.withOpacity(isDark ? 0.60 : 0.20),
                  z.color.withOpacity(isDark ? 0.25 : 0.07),
                ],
              ),
            ),
          ),
        );
      }).toList();

  List<Widget> _zoneLabels(double w, List<Offset> pos, _Palette p) {
    final placed = <int>{};
    return List.generate(_displayLevels.length, (i) {
      if (i >= pos.length) return const SizedBox.shrink();
      final z = _zoneOf(i);
      if (placed.contains(z)) return const SizedBox.shrink();
      placed.add(z);
      final onLeft = z.isEven;
      return Positioned(
        top: pos[i].dy - 58,
        left: onLeft ? 12.w : null, right: onLeft ? null : 12.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: p.surface.withOpacity(0.75), borderRadius: BorderRadius.circular(9.r),
            border: Border.all(color: p.hint.withOpacity(0.18)),
          ),
          child: Text(_zones[z].label, style: GoogleFonts.dmMono(
              fontSize: 8.5.sp, color: p.sub, fontWeight: FontWeight.w600)),
        ),
      );
    });
  }

  Widget _buildNode(BuildContext ctx, int i, Offset pos, _Palette p, double w) {
    final dl    = _displayLevels[i];
    final platW = dl.isBoss ? 108.w : 80.w;
    final platH = platW * 0.52;
    final nodeH = platH + 56.h;

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, child) {
        final t = CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval((i * 0.055).clamp(0.0, 0.65),
              ((i * 0.055) + 0.38).clamp(0.0, 1.0), curve: Curves.elasticOut),
        ).value;
        return Positioned(
          left: pos.dx - platW / 2, top: pos.dy - platH / 2 - 6,
          width: platW, height: nodeH,
          child: Transform.scale(scale: t, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (dl.isLocked) {
            _openLockedSheet(ctx, p);
          } else {
            // ── Push to full LevelScreen ─────────────────────────────────
            Navigator.of(ctx).push(
              PageRouteBuilder(
                transitionDuration: const Duration(milliseconds: 500),
                pageBuilder: (_, anim, __) => LevelScreen(
                  level: dl.level,
                  progress: dl.progress,
                ),
                transitionsBuilder: (_, anim, __, child) {
                  return FadeTransition(
                    opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
                    child: SlideTransition(
                      position: Tween<Offset>(
                          begin: const Offset(0, 0.04), end: Offset.zero)
                          .animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                      child: child,
                    ),
                  );
                },
              ),
            );
          }
        },
        child: dl.isActive
            ? _ActivePlatform(dl: dl, platW: platW, platH: platH,
            pulseCtrl: _pulseCtrl, floatCtrl: _floatCtrl, p: p)
            : _StaticPlatform(dl: dl, platW: platW, platH: platH, p: p),
      ),
    );
  }

  void _openLockedSheet(BuildContext ctx, _Palette p) =>
      showModalBottomSheet(context: ctx, backgroundColor: Colors.transparent,
          builder: (_) => _LockedSheet(p: p));

  void _openSheet(BuildContext ctx, String title, _Palette p) =>
      showModalBottomSheet(context: ctx, backgroundColor: Colors.transparent,
          builder: (_) => _GenericSheet(title: title, p: p));
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL SCREEN  ← the new page that opens when tapping a level node
// ─────────────────────────────────────────────────────────────────────────────
class LevelScreen extends StatefulWidget {
  final Level        level;
  final UserProgress progress;
  const LevelScreen({super.key, required this.level, required this.progress});
  @override State<LevelScreen> createState() => _LevelScreenState();
}

class _LevelScreenState extends State<LevelScreen> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _shimmerCtrl;

  bool   get _isDone   => widget.progress.status == LevelStatus.done;
  bool   get _isActive => widget.progress.status == LevelStatus.active;
  bool   get _isBoss   => widget.level.tag == 'BOSS';
  int    get _stars    => widget.progress.stars;

  // Accent colour per tag
  Color _tagColor(_Palette p) {
    switch (widget.level.tag.toLowerCase()) {
      case 'easy':   return p.win;
      case 'medium': return p.gold;
      case 'hard':   return p.loss;
      default:       return p.gold; // boss
    }
  }

  @override
  void initState() {
    super.initState();
    _bgCtrl     = AnimationController(vsync: this, duration: const Duration(seconds: 10))..repeat(reverse: true);
    _entryCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..forward();
    _shimmerCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 2))..repeat();
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); _entryCtrl.dispose(); _shimmerCtrl.dispose();
    super.dispose();
  }

  // ── Staggered fade+slide helper ──────────────────────────────────────────
  Widget _fs(Widget child, double delay) {
    final end   = (delay + 0.45).clamp(0.0, 1.0);
    final curve = CurvedAnimation(parent: _entryCtrl,
        curve: Interval(delay, end, curve: Curves.easeOut));
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
            .animate(curve),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p      = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tc     = _tagColor(p);
    final size   = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(children: [

        // ── Animated mesh bg ──────────────────────────────────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _LevelBgPainter(
                CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value,
                tc, isDark),
          ),
        ),

        // ── Content ───────────────────────────────────────────────────────
        SafeArea(
          child: Column(children: [

            // ── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(18.w, 12.h, 18.w, 0),
              child: Row(children: [
                _fs(
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40.w, height: 40.w,
                      decoration: BoxDecoration(
                        color: p.surface, borderRadius: BorderRadius.circular(13.r),
                        border: Border.all(color: p.hint.withOpacity(0.2)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.07),
                            blurRadius: 10, offset: const Offset(0, 3))],
                      ),
                      child: Icon(Icons.arrow_back_ios_new_rounded, size: 15.sp, color: p.text),
                    ),
                  ),
                  0.0,
                ),
                const Spacer(),
                _fs(
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: tc.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: tc.withOpacity(0.35)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.bolt_rounded, size: 12.sp, color: tc),
                      SizedBox(width: 4.w),
                      Text('${widget.level.xpReward} XP',
                          style: GoogleFonts.dmMono(fontSize: 11.sp,
                              color: tc, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  0.05,
                ),
              ]),
            ),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 40.h),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                  // ── Hero card ─────────────────────────────────────────────
                  _fs(_HeroCard(
                    level: widget.level, progress: widget.progress,
                    tagColor: tc, p: p, isDark: isDark,
                    bgCtrl: _bgCtrl, shimmerCtrl: _shimmerCtrl,
                  ), 0.08),

                  SizedBox(height: 24.h),

                  // ── Description ───────────────────────────────────────────
                  _fs(
                    Text('Challenge',
                        style: GoogleFonts.dmSerifDisplay(fontSize: 18.sp, color: p.text)),
                    0.16,
                  ),
                  SizedBox(height: 8.h),
                  _fs(
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: p.surface,
                        borderRadius: BorderRadius.circular(18.r),
                        border: Border.all(color: p.hint.withOpacity(0.12)),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05),
                            blurRadius: 12, offset: const Offset(0, 4))],
                      ),
                      child: Text(widget.level.description,
                          style: GoogleFonts.dmMono(
                              fontSize: 12.sp, color: p.sub, height: 1.65)),
                    ),
                    0.20,
                  ),

                  SizedBox(height: 22.h),

                  // ── Starter code preview ──────────────────────────────────
                  if (widget.level.starterCode.isNotEmpty) ...[
                    _fs(
                      Text('Starter Code',
                          style: GoogleFonts.dmSerifDisplay(fontSize: 18.sp, color: p.text)),
                      0.26,
                    ),
                    SizedBox(height: 8.h),
                    _fs(
                      _CodePreview(starterCode: widget.level.starterCode, p: p, isDark: isDark),
                      0.30,
                    ),
                    SizedBox(height: 22.h),
                  ],

                  // ── Test cases ────────────────────────────────────────────
                  _fs(
                    Text('Test Cases',
                        style: GoogleFonts.dmSerifDisplay(fontSize: 18.sp, color: p.text)),
                    0.36,
                  ),
                  SizedBox(height: 8.h),
                  ..._visibleTestCases().asMap().entries.map((e) =>
                      _fs(_TestCaseCard(tc: e.value, index: e.key, color: tc, p: p),
                          0.38 + e.key * 0.04)),

                  SizedBox(height: 32.h),

                  // ── CTA button ────────────────────────────────────────────
                  _fs(_StartButton(
                    isDone: _isDone, tagColor: tc, p: p,
                    onTap: () {
                      HapticFeedback.heavyImpact();
                      // context.push('/battle/${widget.level.id}');
                    },
                  ), 0.50),

                  SizedBox(height: 16.h),
                ]),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  List<TestCase> _visibleTestCases() =>
      widget.level.testCases.where((t) => !t.isHidden).toList();
}

// ─────────────────────────────────────────────────────────────────────────────
// HERO CARD  — the big animated card at the top of LevelScreen
// ─────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Level        level;
  final UserProgress progress;
  final Color        tagColor;
  final _Palette     p;
  final bool         isDark;
  final AnimationController bgCtrl, shimmerCtrl;

  const _HeroCard({
    required this.level, required this.progress,
    required this.tagColor, required this.p,
    required this.isDark, required this.bgCtrl, required this.shimmerCtrl,
  });

  bool get _isDone  => progress.status == LevelStatus.done;
  bool get _isBoss  => level.tag == 'BOSS';
  int  get _stars   => progress.stars;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([bgCtrl, shimmerCtrl]),
      builder: (_, __) {
        final t       = CurvedAnimation(parent: bgCtrl, curve: Curves.easeInOut).value;
        final shimmer = shimmerCtrl.value;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: tagColor.withOpacity(0.25)),
            boxShadow: [
              BoxShadow(color: tagColor.withOpacity(isDark ? 0.18 : 0.10),
                  blurRadius: 24, offset: const Offset(0, 8)),
              BoxShadow(color: Colors.black.withOpacity(0.06),
                  blurRadius: 12, offset: const Offset(0, 4)),
            ],
          ),
          child: Stack(children: [

            // Shimmer sweep for boss levels
            if (_isBoss)
              Positioned.fill(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24.r),
                  child: CustomPaint(
                    painter: _ShimmerPainter(shimmer, tagColor),
                  ),
                ),
              ),

            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              // Emoji + level number
              Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                  width: 72.w, height: 72.w,
                  decoration: BoxDecoration(
                    color: tagColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: tagColor.withOpacity(0.25)),
                  ),
                  child: Center(
                    child: Text(level.emoji,
                        style: TextStyle(fontSize: _isBoss ? 36.sp : 30.sp)),
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Level ${level.number}',
                        style: GoogleFonts.dmMono(
                            fontSize: 10.sp, color: p.sub, fontWeight: FontWeight.w600)),
                    SizedBox(height: 3.h),
                    Text(level.title,
                        style: GoogleFonts.dmSerifDisplay(
                            fontSize: 20.sp, color: p.text, height: 1.2)),
                    SizedBox(height: 8.h),
                    // Tags row
                    Wrap(spacing: 6.w, runSpacing: 4.h, children: [
                      _TagPill(label: level.tag, color: tagColor),
                      _TagPill(label: '${level.xpReward} XP', color: p.gold),
                      if (_isDone)
                        _TagPill(label: '✓ Solved', color: p.win),
                    ]),
                  ]),
                ),
              ]),

              // Stars (done levels)
              if (_isDone) ...[
                SizedBox(height: 16.h),
                const Divider(height: 1, color: Color(0x18FFFFFF)),
                SizedBox(height: 14.h),
                Row(children: [
                  Text('Your Score',
                      style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub)),
                  const Spacer(),
                  Row(
                    children: List.generate(3, (i) => Padding(
                      padding: EdgeInsets.only(left: 2.w),
                      child: AnimatedContainer(
                        duration: Duration(milliseconds: 200 + i * 80),
                        child: Icon(
                          i < _stars ? Icons.star_rounded : Icons.star_outline_rounded,
                          size: 22.sp,
                          color: i < _stars ? p.gold : p.hint.withOpacity(0.3),
                        ),
                      ),
                    )),
                  ),
                ]),
              ],

              // Progress bar / "active" indicator for active levels
              if (!_isDone) ...[
                SizedBox(height: 16.h),
                const Divider(height: 1, color: Color(0x18FFFFFF)),
                SizedBox(height: 14.h),
                Row(children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: tagColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: tagColor.withOpacity(0.3)),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      // Pulsing dot
                      AnimatedBuilder(
                        animation: bgCtrl,
                        builder: (_, __) => Container(
                          width: 7.w, height: 7.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: tagColor.withOpacity(
                                0.5 + math.sin(t * math.pi * 2) * 0.4),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text('Ready to Battle',
                          style: GoogleFonts.dmMono(
                              fontSize: 10.sp, color: tagColor, fontWeight: FontWeight.w700)),
                    ]),
                  ),
                  const Spacer(),
                  Text('Attempts: ${progress.attempts}',
                      style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub)),
                ]),
              ],
            ]),
          ]),
        );
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CODE PREVIEW  — tabbed starter code snippet
// ─────────────────────────────────────────────────────────────────────────────
class _CodePreview extends StatefulWidget {
  final Map<String, String> starterCode;
  final _Palette p;
  final bool isDark;
  const _CodePreview({required this.starterCode, required this.p, required this.isDark});
  @override State<_CodePreview> createState() => _CodePreviewState();
}

class _CodePreviewState extends State<_CodePreview> {
  late String _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.starterCode.keys.first;
  }

  @override
  Widget build(BuildContext context) {
    final p      = widget.p;
    final isDark = widget.isDark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D0A18) : const Color(0xFF1A1730),
        borderRadius: BorderRadius.circular(18.r),
        border: Border.all(color: p.hint.withOpacity(0.12)),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18),
            blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Tab bar
        Padding(
          padding: EdgeInsets.fromLTRB(12.w, 10.h, 12.w, 0),
          child: Row(children: [
            ...widget.starterCode.keys.map((lang) => GestureDetector(
              onTap: () => setState(() => _selected = lang),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: EdgeInsets.only(right: 8.w),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: _selected == lang
                      ? p.accent.withOpacity(0.22) : Colors.transparent,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: _selected == lang
                      ? p.accent.withOpacity(0.45) : Colors.transparent),
                ),
                child: Text(lang.toUpperCase(),
                    style: GoogleFonts.dmMono(
                      fontSize: 9.sp,
                      color: _selected == lang ? p.accent : p.hint,
                      fontWeight: FontWeight.w700,
                    )),
              ),
            )),
          ]),
        ),
        // Code body
        Padding(
          padding: EdgeInsets.all(14.w),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Text(
              widget.starterCode[_selected] ?? '',
              style: GoogleFonts.dmMono(
                fontSize: 11.5.sp,
                color: const Color(0xFFB8D0FF),
                height: 1.65,
              ),
            ),
          ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST CASE CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TestCaseCard extends StatelessWidget {
  final TestCase tc;
  final int      index;
  final Color    color;
  final _Palette p;
  const _TestCaseCard({required this.tc, required this.index,
    required this.color, required this.p});

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(14.w),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: p.hint.withOpacity(0.10)),
      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04),
          blurRadius: 8, offset: const Offset(0, 3))],
    ),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Container(
          width: 22.w, height: 22.w,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12), shape: BoxShape.circle,
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Center(child: Text('${index + 1}',
              style: GoogleFonts.dmMono(
                  fontSize: 9.sp, color: color, fontWeight: FontWeight.w800))),
        ),
        SizedBox(width: 8.w),
        Text('Test Case ${index + 1}', style: GoogleFonts.dmMono(
            fontSize: 10.sp, color: p.sub, fontWeight: FontWeight.w600)),
      ]),
      SizedBox(height: 10.h),
      _CodeRow(label: 'Input', value: tc.input, color: color, p: p),
      SizedBox(height: 6.h),
      _CodeRow(label: 'Expected', value: tc.expectedOutput, color: p.win, p: p),
    ]),
  );
}

class _CodeRow extends StatelessWidget {
  final String label, value;
  final Color color;
  final _Palette p;
  const _CodeRow({required this.label, required this.value,
    required this.color, required this.p});

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(
        width: 58.w,
        child: Text(label, style: GoogleFonts.dmMono(
            fontSize: 9.sp, color: p.hint, fontWeight: FontWeight.w600)),
      ),
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(7.r),
            border: Border.all(color: color.withOpacity(0.18)),
          ),
          child: Text(value, style: GoogleFonts.dmMono(
              fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
        ),
      ),
    ],
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// START BUTTON
// ─────────────────────────────────────────────────────────────────────────────
class _StartButton extends StatefulWidget {
  final bool isDone;
  final Color tagColor;
  final _Palette p;
  final VoidCallback onTap;
  const _StartButton({required this.isDone, required this.tagColor,
    required this.p, required this.onTap});
  @override State<_StartButton> createState() => _StartButtonState();
}

class _StartButtonState extends State<_StartButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double>   _s;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 130));
    _s = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }

  @override void dispose() { _c.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tc = widget.tagColor;
    return GestureDetector(
      onTapDown:   (_) => _c.forward(),
      onTapUp:     (_) { _c.reverse(); widget.onTap(); },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Container(
          width: double.infinity, height: 58.h,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [
                Color.lerp(tc, Colors.white, 0.10)!,
                tc,
              ],
            ),
            borderRadius: BorderRadius.circular(18.r),
            boxShadow: [
              BoxShadow(color: tc.withOpacity(0.40),
                  blurRadius: 20, offset: const Offset(0, 8)),
            ],
          ),
          child: Center(
            child: Text(
              widget.isDone ? '🔄  Play Again' : '⚔️  Start Battle',
              style: GoogleFonts.dmMono(
                  fontSize: 15.sp, color: Colors.white,
                  fontWeight: FontWeight.w800, letterSpacing: 0.3),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL SHARED WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _TagPill extends StatelessWidget {
  final String label;
  final Color  color;
  const _TagPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: color.withOpacity(0.28)),
    ),
    child: Text(label, style: GoogleFonts.dmMono(
        fontSize: 9.5.sp, color: color, fontWeight: FontWeight.w700)),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

/// Background for LevelScreen — tinted by the level's tag colour
class _LevelBgPainter extends CustomPainter {
  final double t;
  final Color  accent;
  final bool   isDark;
  const _LevelBgPainter(this.t, this.accent, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final d   = math.sin(t * math.pi) * 40;
    final mul = isDark ? 1.4 : 0.7;

    _blob(canvas, Offset(size.width * 0.85 + d, size.height * 0.12),
        size.width * 0.70, accent.withOpacity(0.14 * mul));
    _blob(canvas, Offset(size.width * 0.08, size.height * 0.60 + d * 0.5),
        size.width * 0.55, accent.withOpacity(0.08 * mul));
    _blob(canvas, Offset(size.width * 0.55, size.height * 0.85 - d * 0.3),
        size.width * 0.48, const Color(0xFF9D8FF7).withOpacity(0.07 * mul));

    if (isDark) {
      final rng = math.Random(77);
      for (var i = 0; i < 70; i++) {
        final op = (0.10 + rng.nextDouble() * 0.45
            + math.sin(t * math.pi * 2 + i) * 0.15).clamp(0.0, 0.75);
        canvas.drawCircle(
          Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
          rng.nextDouble() * 1.2 + 0.15,
          Paint()..color = Colors.white.withOpacity(op),
        );
      }
    }
  }

  void _blob(Canvas c, Offset centre, double r, Color color) =>
      c.drawCircle(centre, r, Paint()
        ..shader = RadialGradient(colors: [color, Colors.transparent])
            .createShader(Rect.fromCircle(center: centre, radius: r)));

  @override
  bool shouldRepaint(covariant _LevelBgPainter o) => o.t != t;
}

/// Shimmer sweep for boss-level hero card
class _ShimmerPainter extends CustomPainter {
  final double t;
  final Color  color;
  const _ShimmerPainter(this.t, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final x = -size.width + t * size.width * 2.5;
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: const [0.0, 0.45, 0.55, 1.0],
          colors: [
            Colors.transparent,
            color.withOpacity(0.06),
            color.withOpacity(0.10),
            Colors.transparent,
          ],
        ).createShader(Rect.fromLTWH(x, 0, size.width * 1.5, size.height)),
    );
  }

  @override
  bool shouldRepaint(covariant _ShimmerPainter o) => o.t != t;
}

class _StarfieldPainter extends CustomPainter {
  final double t; final bool isDark;
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
        final op = (0.15 + rng.nextDouble() * 0.5
            + math.sin(t * math.pi * 2 + i) * 0.18).clamp(0.0, 0.85);
        canvas.drawCircle(
          Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
          rng.nextDouble() * 1.3 + 0.2,
          Paint()..color = Colors.white.withOpacity(op),
        );
      }
    }
  }

  void _blob(Canvas c, Offset centre, double r, Color color) =>
      c.drawCircle(centre, r, Paint()
        ..shader = RadialGradient(colors: [color, Colors.transparent])
            .createShader(Rect.fromCircle(center: centre, radius: r)));

  @override
  bool shouldRepaint(covariant _StarfieldPainter o) => o.t != t || o.isDark != isDark;
}

class _SparkPainter extends CustomPainter {
  final double t; final bool isDark;
  const _SparkPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isDark) return;
    final rng  = math.Random(13);
    const cols = [Color(0xFF9D8FF7), Color(0xFF3DD68C), Color(0xFFFFB82E)];
    for (var i = 0; i < 28; i++) {
      final bx = rng.nextDouble() * size.width, by = rng.nextDouble() * size.height;
      final phase = rng.nextDouble() * math.pi * 2;
      final dy = math.sin(t * math.pi + phase) * 14;
      final op = (0.25 + math.sin(t * math.pi * 2 + phase) * 0.3).clamp(0.0, 0.7);
      canvas.drawCircle(Offset(bx, by + dy), rng.nextDouble() * 1.6 + 0.4,
          Paint()..color = cols[i % cols.length].withOpacity(op));
    }
  }

  @override bool shouldRepaint(covariant _SparkPainter o) => o.t != t;
}

class _RoadPainter extends CustomPainter {
  final List<Offset> pts;
  final List<_DisplayLevel> levels;
  final _Palette p;
  final bool isDark;
  const _RoadPainter(this.pts, this.levels, this.p, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < pts.length - 1; i++) {
      if (i >= levels.length) break;
      final a = pts[i], b = pts[i + 1];
      if (levels[i].isDone) {
        canvas.drawLine(a, b, Paint()..color = p.win.withOpacity(isDark ? 0.16 : 0.10)
          ..strokeWidth = 20 ..strokeCap = StrokeCap.round);
        canvas.drawLine(a, b, Paint()..color = p.win.withOpacity(0.60)
          ..strokeWidth = 3.5 ..strokeCap = StrokeCap.round);
        canvas.drawLine(a, b, Paint()..color = Colors.white.withOpacity(0.18)
          ..strokeWidth = 1.0 ..strokeCap = StrokeCap.round);
      } else {
        _dash(canvas, a, b, Paint()..color = p.hint.withOpacity(0.28)
          ..strokeWidth = 2.0 ..strokeCap = StrokeCap.round);
      }
    }
  }

  void _dash(Canvas c, Offset a, Offset b, Paint paint) {
    final total = (b - a).distance;
    final dir   = (b - a) / total;
    var d = 0.0; var on = true;
    while (d < total) {
      final seg = on ? 9.0 : 6.0;
      final end = (d + seg).clamp(0.0, total);
      if (on) c.drawLine(a + dir * d, a + dir * end, paint);
      d += seg; on = !on;
    }
  }

  @override bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL MAP SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String emoji, label; final Color fg, bg;
  const _Chip({required this.emoji, required this.label, required this.fg, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: fg.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: TextStyle(fontSize: 11.sp)),
      SizedBox(width: 5.w),
      Text(label, style: GoogleFonts.dmMono(fontSize: 10.sp, color: fg, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _ActionChip extends StatefulWidget {
  final String emoji, label; final Color fg, bg; final VoidCallback onTap;
  const _ActionChip({required this.emoji, required this.label,
    required this.fg, required this.bg, required this.onTap});
  @override State<_ActionChip> createState() => _ActionChipState();
}
class _ActionChipState extends State<_ActionChip> with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 110));
    _s = Tween<double>(begin: 1.0, end: 0.92)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
  }
  @override void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _c.forward(),
    onTapUp:   (_) { _c.reverse(); widget.onTap(); },
    onTapCancel: () => _c.reverse(),
    child: ScaleTransition(scale: _s,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 9.h),
          decoration: BoxDecoration(
            color: widget.bg, borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: widget.fg.withOpacity(0.25)),
            boxShadow: [BoxShadow(color: widget.fg.withOpacity(0.10),
                blurRadius: 7, offset: const Offset(0, 3))],
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Text(widget.emoji, style: TextStyle(fontSize: 14.sp)),
            SizedBox(width: 6.w),
            Text(widget.label, style: GoogleFonts.dmMono(
                fontSize: 11.sp, color: widget.fg, fontWeight: FontWeight.w700)),
          ]),
        )),
  );
}

class _IsoBlock extends CustomPainter {
  final Color topFace, leftFace, rightFace, edgeColor;
  final double depth;
  const _IsoBlock({required this.topFace, required this.leftFace,
    required this.rightFace, required this.edgeColor, this.depth = 14});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, th = size.height * 0.48, d = depth;
    final top = Path()
      ..moveTo(w * .5, 0) ..lineTo(w, th * .55)
      ..lineTo(w * .5, th) ..lineTo(0, th * .55) ..close();
    final left = Path()
      ..moveTo(0, th * .55) ..lineTo(w * .5, th)
      ..lineTo(w * .5, th + d) ..lineTo(0, th * .55 + d) ..close();
    final right = Path()
      ..moveTo(w * .5, th) ..lineTo(w, th * .55)
      ..lineTo(w, th * .55 + d) ..lineTo(w * .5, th + d) ..close();
    final edge = Paint()..color = edgeColor ..strokeWidth = 1.0 ..style = PaintingStyle.stroke;
    canvas.drawPath(top,   Paint()..color = topFace);
    canvas.drawPath(left,  Paint()..color = leftFace);
    canvas.drawPath(right, Paint()..color = rightFace);
    canvas.drawPath(top, edge); canvas.drawPath(left, edge); canvas.drawPath(right, edge);
  }

  @override bool shouldRepaint(covariant _IsoBlock o) => o.topFace != topFace;
}

class _ActivePlatform extends StatelessWidget {
  final _DisplayLevel dl;
  final double platW, platH;
  final AnimationController pulseCtrl, floatCtrl;
  final _Palette p;
  const _ActivePlatform({required this.dl, required this.platW, required this.platH,
    required this.pulseCtrl, required this.floatCtrl, required this.p});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([pulseCtrl, floatCtrl]),
    builder: (_, __) {
      final pulse = CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut).value;
      final dy    = CurvedAnimation(parent: floatCtrl,  curve: Curves.easeInOut).value * 5.0;
      const depth = 14.0;
      return Column(mainAxisSize: MainAxisSize.min, children: [
        SizedBox(
          width: platW + 36, height: platH + depth + 16,
          child: Stack(clipBehavior: Clip.none, alignment: Alignment.center, children: [
            Container(
              width: platW + 18 + pulse * 16, height: platW + 18 + pulse * 16,
              decoration: BoxDecoration(shape: BoxShape.circle,
                  color: p.accent.withOpacity(0.07 + pulse * 0.07)),
            ),
            Transform.translate(
              offset: Offset(0, -dy),
              child: SizedBox(width: platW, height: platH + depth,
                child: Stack(clipBehavior: Clip.none, children: [
                  CustomPaint(size: Size(platW, platH + depth),
                    painter: _IsoBlock(
                      topFace: p.accent,
                      leftFace: Color.lerp(p.accent, Colors.black, 0.38)!,
                      rightFace: Color.lerp(p.accent, Colors.black, 0.58)!,
                      edgeColor: Colors.white.withOpacity(0.25), depth: depth,
                    ),
                  ),
                  Positioned.fill(child: Align(
                    alignment: const Alignment(0, -0.25),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(dl.emoji, style: TextStyle(fontSize: 16.sp)),
                      SizedBox(height: 1.h),
                      Text('LV ${dl.number}', style: GoogleFonts.dmMono(
                          fontSize: 6.5.sp, color: Colors.white, fontWeight: FontWeight.w800)),
                    ]),
                  )),
                ]),
              ),
            ),
          ]),
        ),
        SizedBox(height: 5.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
          decoration: BoxDecoration(
            color: p.accent.withOpacity(0.18), borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: p.accent.withOpacity(0.45)),
          ),
          child: Text(dl.title, maxLines: 1, overflow: TextOverflow.ellipsis,
              style: GoogleFonts.dmMono(fontSize: 8.sp, color: p.accent, fontWeight: FontWeight.w700)),
        ),
      ]);
    },
  );
}

class _StaticPlatform extends StatelessWidget {
  final _DisplayLevel dl;
  final double platW, platH;
  final _Palette p;
  const _StaticPlatform({required this.dl, required this.platW, required this.platH, required this.p});

  @override
  Widget build(BuildContext context) {
    final depth     = dl.isBoss ? 18.0 : dl.isLocked ? 7.0 : 13.0;
    final base      = dl.isDone ? dl.nodeColor : dl.isBoss ? p.gold : p.surface2;
    final topFace   = dl.isDone ? Color.lerp(base, Colors.white, 0.18)!
        : dl.isBoss ? Color.lerp(p.gold, Colors.white, 0.22)! : p.surface2;
    final leftFace  = Color.lerp(topFace, Colors.black, dl.isDone ? 0.32 : dl.isBoss ? 0.38 : 0.15)!;
    final rightFace = Color.lerp(topFace, Colors.black, dl.isDone ? 0.52 : dl.isBoss ? 0.55 : 0.28)!;
    final edgeColor = dl.isDone ? base.withOpacity(0.55)
        : dl.isBoss ? p.gold.withOpacity(0.5) : p.hint.withOpacity(0.2);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      SizedBox(width: platW, height: platH + depth,
        child: Stack(children: [
          CustomPaint(size: Size(platW, platH + depth),
              painter: _IsoBlock(topFace: topFace, leftFace: leftFace,
                  rightFace: rightFace, edgeColor: edgeColor, depth: depth)),
          Positioned.fill(child: Align(
            alignment: const Alignment(0, -0.2),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (dl.isLocked && !dl.isBoss)
                Icon(Icons.lock_rounded, size: 14.sp, color: p.hint.withOpacity(0.5))
              else
                Text(dl.emoji, style: TextStyle(fontSize: dl.isBoss ? 20.sp : 13.sp)),
              if (dl.isDone) ...[
                SizedBox(height: 2.h),
                Row(mainAxisSize: MainAxisSize.min,
                    children: List.generate(3, (i) => Icon(
                      i < dl.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 6.5.sp,
                      color: i < dl.stars ? p.gold : Colors.white.withOpacity(0.22),
                    ))),
              ],
            ]),
          )),
          if (dl.isBoss) Positioned.fill(child: CustomPaint(painter: _GlowRim(p.gold))),
        ]),
      ),
      SizedBox(height: 4.h),
      if (dl.isDone || dl.isBoss)
        Text(dl.title, maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmMono(fontSize: 7.5.sp, fontWeight: FontWeight.w700,
                color: dl.isBoss ? p.gold : dl.isDone ? dl.nodeColor : p.sub)),
      if (dl.isLocked && !dl.isBoss)
        Text('LV ${dl.number}', style: GoogleFonts.dmMono(
            fontSize: 7.sp, color: p.hint, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _GlowRim extends CustomPainter {
  final Color color;
  const _GlowRim(this.color);
  @override
  void paint(Canvas canvas, Size size) =>
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height),
          Paint()..color = color.withOpacity(0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
  @override bool shouldRepaint(_) => false;
}

class _LockedSheet extends StatelessWidget {
  final _Palette p;
  const _LockedSheet({required this.p});
  @override
  Widget build(BuildContext context) => _Sheet(p: p, children: [
    Text('🔒', style: TextStyle(fontSize: 48.sp)),
    SizedBox(height: 10.h),
    Text('Level Locked', style: GoogleFonts.dmSerifDisplay(fontSize: 22.sp, color: p.text)),
    SizedBox(height: 6.h),
    Text('Complete the previous level\nto unlock this one.',
        textAlign: TextAlign.center,
        style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.5)),
    SizedBox(height: 26.h),
    _SheetBtn(label: '⚔️  Go to Current Level', color: p.accent,
        onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); }),
    SizedBox(height: 14.h),
    GestureDetector(onTap: () => Navigator.pop(context),
        child: Text('Close', style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.sub))),
  ]);
}

class _GenericSheet extends StatelessWidget {
  final String title; final _Palette p;
  const _GenericSheet({required this.title, required this.p});
  static const _info = {
    'Challenge':   ('⚔️', 'Challenge a Friend', 'Pick a friend and duel them live in real time!'),
    'Leaderboard': ('🏆', 'Global Rankings',    'See where you stand among coders worldwide.'),
    'Friends':     ('👥', 'Your Squad',         'Race your friends to the next level.'),
    'Daily':       ('🎯', 'Daily Challenge',    'One special problem per day — extra XP awaits!'),
  };
  @override
  Widget build(BuildContext context) {
    final info = _info[title] ?? ('🎮', title, 'Coming soon…');
    return _Sheet(p: p, children: [
      Text(info.$1, style: TextStyle(fontSize: 44.sp)),
      SizedBox(height: 10.h),
      Text(info.$2, style: GoogleFonts.dmSerifDisplay(fontSize: 22.sp, color: p.text)),
      SizedBox(height: 8.h),
      Text(info.$3, textAlign: TextAlign.center,
          style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.5)),
      SizedBox(height: 28.h),
      _SheetBtn(label: 'Let\'s Go →', color: p.accent,
          onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(context); }),
      SizedBox(height: 14.h),
      GestureDetector(onTap: () => Navigator.pop(context),
          child: Text('Maybe later', style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.sub))),
    ]);
  }
}

class _Sheet extends StatelessWidget {
  final _Palette p; final List<Widget> children;
  const _Sheet({required this.p, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
    decoration: BoxDecoration(color: p.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.r))),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40.w, height: 4.h,
          decoration: BoxDecoration(color: p.hint.withOpacity(0.35),
              borderRadius: BorderRadius.circular(99.r))),
      SizedBox(height: 20.h),
      ...children,
    ]),
  );
}

class _SheetBtn extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _SheetBtn({required this.label, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: double.infinity, height: 50.h,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Center(child: Text(label, style: GoogleFonts.dmMono(
          fontSize: 13.sp, color: color, fontWeight: FontWeight.w700))),
    ),
  );
}