import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
// DATA
// ─────────────────────────────────────────────────────────────────────────────
enum _State { done, active, locked }

class _Level {
  final int number;
  final String title, tag, emoji;
  final _State state;
  final int stars;
  final Color nodeColor;
  const _Level({required this.number, required this.title, required this.tag,
    required this.emoji, required this.state, required this.stars,
    required this.nodeColor});
}

const _levels = [
  _Level(number: 1,  title: 'Two Sum',           tag: 'Easy',   emoji: '🍎', state: _State.done,   stars: 3, nodeColor: Color(0xFF3DD68C)),
  _Level(number: 2,  title: 'Palindrome Check',  tag: 'Easy',   emoji: '🍊', state: _State.done,   stars: 3, nodeColor: Color(0xFF3DD68C)),
  _Level(number: 3,  title: 'Linked List Cycle', tag: 'Easy',   emoji: '🍋', state: _State.done,   stars: 2, nodeColor: Color(0xFFFFB82E)),
  _Level(number: 4,  title: 'Binary Search',     tag: 'Easy',   emoji: '🍇', state: _State.done,   stars: 3, nodeColor: Color(0xFF3DD68C)),
  _Level(number: 5,  title: 'Stack Min',         tag: 'Medium', emoji: '🫐', state: _State.done,   stars: 2, nodeColor: Color(0xFFFFB82E)),
  _Level(number: 6,  title: 'Merge Intervals',   tag: 'Medium', emoji: '🍓', state: _State.done,   stars: 1, nodeColor: Color(0xFFFF6B6B)),
  _Level(number: 7,  title: 'BFS Shortest Path', tag: 'Medium', emoji: '🎃', state: _State.active, stars: 0, nodeColor: Color(0xFF9D8FF7)),
  _Level(number: 8,  title: 'LRU Cache',         tag: 'Medium', emoji: '🔮', state: _State.locked, stars: 0, nodeColor: Color(0xFF3A3558)),
  _Level(number: 9,  title: 'Trie Search',       tag: 'Hard',   emoji: '💀', state: _State.locked, stars: 0, nodeColor: Color(0xFF3A3558)),
  _Level(number: 10, title: 'Segment Tree',      tag: 'Hard',   emoji: '🔥', state: _State.locked, stars: 0, nodeColor: Color(0xFF3A3558)),
  _Level(number: 11, title: 'Dijkstra\'s Algo',  tag: 'Hard',   emoji: '⚡', state: _State.locked, stars: 0, nodeColor: Color(0xFF3A3558)),
  _Level(number: 12, title: 'BOSS: DP Marathon', tag: 'BOSS',   emoji: '👑', state: _State.locked, stars: 0, nodeColor: Color(0xFFFFB82E)),
];

// Snake path — (xFrac, yFrac) of the scrollable canvas.
// y=1.0 is bottom (lv 1), y=0.0 is top (boss lv 12)
const _snake = [
  (x: 0.28, y: 0.96), // 1
  (x: 0.58, y: 0.88), // 2
  (x: 0.76, y: 0.79), // 3
  (x: 0.62, y: 0.70), // 4
  (x: 0.34, y: 0.62), // 5
  (x: 0.16, y: 0.53), // 6
  (x: 0.36, y: 0.44), // 7 — active
  (x: 0.64, y: 0.36), // 8
  (x: 0.80, y: 0.27), // 9
  (x: 0.60, y: 0.18), // 10
  (x: 0.28, y: 0.11), // 11
  (x: 0.50, y: 0.03), // 12 — boss
];

// Zone info: which levels belong, tint colour, label
const _zones = [
  (range: (0, 3),  color: Color(0xFF0D3018), label: '🌲 Greenwood Forest'),
  (range: (4, 7),  color: Color(0xFF0E0C28), label: '💎 Crystal Caverns'),
  (range: (8, 10), color: Color(0xFF2E0C0C), label: '🌋 Inferno Peaks'),
  (range: (11, 11),color: Color(0xFF1E1600), label: '☠️  Shadow Sanctum'),
];

int _zoneOf(int i) {
  for (var z = 0; z < _zones.length; z++) {
    if (i >= _zones[z].range.$1 && i <= _zones[z].range.$2) return z;
  }
  return 0;
}

// ─────────────────────────────────────────────────────────────────────────────
// LEVEL MAP PAGE
// ─────────────────────────────────────────────────────────────────────────────
class LevelMapPage extends StatefulWidget {
  const LevelMapPage({super.key});
  @override
  State<LevelMapPage> createState() => _LevelMapPageState();
}

class _LevelMapPageState extends State<LevelMapPage> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _floatCtrl;
  late final ScrollController    _scrollCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl    = AnimationController(vsync: this, duration: const Duration(seconds: 14))..repeat(reverse: true);
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..forward();
    _floatCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..repeat(reverse: true);
    _scrollCtrl = ScrollController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ai = _levels.indexWhere((l) => l.state == _State.active);
      if (ai != -1 && _scrollCtrl.hasClients) {
        final frac  = _snake[ai].y;
        final total = _scrollCtrl.position.maxScrollExtent;
        final dest  = (frac * total - 220).clamp(0.0, total);
        _scrollCtrl.animateTo(dest,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic);
      }
    });
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); _pulseCtrl.dispose();
    _entryCtrl.dispose(); _floatCtrl.dispose();
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

        // ── Deep starfield background ────────────────────────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _StarfieldPainter(
                CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value,
                isDark),
          ),
        ),

        SafeArea(child: Column(children: [
          _buildHeader(p),
          _buildActionRow(p),
          Expanded(child: _buildMap(context, p, isDark, size)),
        ])),

        Positioned(bottom: 0, left: 0, right: 0, child: _buildNav(p)),
      ]),
    );
  }

  // ── Header ────────────────────────────────────────────────────────────────
  Widget _buildHeader(_Palette p) => Padding(
    padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 0),
    child: Row(children: [
      Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: p.hint.withOpacity(0.15)),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.09),
              blurRadius: 14, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 32.w, height: 32.w,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                  colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Center(child: Text('🧑‍💻', style: TextStyle(fontSize: 16.sp))),
          ),
          SizedBox(width: 9.w),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('ByteSlayer',
                style: GoogleFonts.dmSerifDisplay(fontSize: 14.sp, color: p.text)),
            Text('Grandmaster  👑',
                style: GoogleFonts.dmMono(
                    fontSize: 8.5.sp, color: p.gold, fontWeight: FontWeight.w700)),
          ]),
        ]),
      ),
      const Spacer(),
      _Chip(emoji: '⚡', label: '8,250 XP', fg: p.accent, bg: p.accentSoft),
      SizedBox(width: 7.w),
      _Chip(emoji: '🔥', label: '17',       fg: p.loss,   bg: p.lossSoft),
    ]),
  );

  // ── Action row ────────────────────────────────────────────────────────────
  Widget _buildActionRow(_Palette p) {
    final items = [
      (e: '⚔️',  l: 'Challenge',   c: p.loss,   b: p.lossSoft),
      (e: '🏆',  l: 'Leaderboard', c: p.gold,   b: p.goldSoft),
      (e: '👥',  l: 'Friends',     c: p.win,    b: p.winSoft),
      (e: '🎯',  l: 'Daily',       c: p.accent, b: p.accentSoft),
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

  // ── Map ───────────────────────────────────────────────────────────────────
  Widget _buildMap(BuildContext ctx, _Palette p, bool isDark, Size screenSize) {
    final canvasH = screenSize.height * 2.2;
    final canvasW = screenSize.width;
    final positions = _snake.map((s) => Offset(s.x * canvasW, s.y * canvasH)).toList();

    return SingleChildScrollView(
      controller: _scrollCtrl,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(bottom: 130.h),
      child: SizedBox(
        width: canvasW, height: canvasH,
        child: Stack(clipBehavior: Clip.none, children: [

          // Zone tint layers
          ..._zoneTints(canvasW, canvasH, positions, isDark),

          // Road lines
          CustomPaint(
            size: Size(canvasW, canvasH),
            painter: _RoadPainter(positions, _levels, p, isDark),
          ),

          // Floating sparkles
          AnimatedBuilder(
            animation: _bgCtrl,
            builder: (_, __) => CustomPaint(
              size: Size(canvasW, canvasH),
              painter: _SparkPainter(
                  CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value,
                  isDark),
            ),
          ),

          // Level nodes
          for (var i = 0; i < _levels.length; i++)
            _buildNode(ctx, i, positions[i], p, canvasW),

          // Zone label chips
          ..._zoneLabels(canvasW, positions, p),
        ]),
      ),
    );
  }

  List<Widget> _zoneTints(double w, double h, List<Offset> pos, bool isDark) {
    return _zones.map((z) {
      final ys = [
        for (var i = z.range.$1; i <= z.range.$2; i++) pos[i].dy
      ];
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
  }

  List<Widget> _zoneLabels(double w, List<Offset> pos, _Palette p) {
    final placed = <int>{};
    return List.generate(_levels.length, (i) {
      final z = _zoneOf(i);
      if (placed.contains(z)) return const SizedBox.shrink();
      placed.add(z);
      final onLeft = z.isEven;
      return Positioned(
        top: pos[i].dy - 58,
        left:  onLeft ? 12.w : null,
        right: onLeft ? null : 12.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: p.surface.withOpacity(0.75),
            borderRadius: BorderRadius.circular(9.r),
            border: Border.all(color: p.hint.withOpacity(0.18)),
          ),
          child: Text(_zones[z].label,
              style: GoogleFonts.dmMono(
                  fontSize: 8.5.sp, color: p.sub, fontWeight: FontWeight.w600)),
        ),
      );
    });
  }

  Widget _buildNode(BuildContext ctx, int i, Offset pos, _Palette p, double w) {
    final level   = _levels[i];
    final isBoss  = level.tag == 'BOSS';
    final platW   = isBoss ? 108.w : 80.w;
    final platH   = platW * 0.52;
    final nodeH   = platH + 50.h;

    return AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, child) {
        final t = CurvedAnimation(
          parent: _entryCtrl,
          curve: Interval(
            (i * 0.055).clamp(0.0, 0.65),
            ((i * 0.055) + 0.38).clamp(0.0, 1.0),
            curve: Curves.elasticOut,
          ),
        ).value;
        return Positioned(
          left: pos.dx - platW / 2,
          top:  pos.dy - platH / 2 - 6,
          width: platW, height: nodeH,
          child: Transform.scale(scale: t, child: child),
        );
      },
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          level.state == _State.locked
              ? _openLockedSheet(ctx, p)
              : _openLevelSheet(ctx, level, p);
        },
        child: level.state == _State.active
            ? _ActivePlatform(level: level, platW: platW, platH: platH,
            pulseCtrl: _pulseCtrl, floatCtrl: _floatCtrl, p: p)
            : _StaticPlatform(level: level, platW: platW, platH: platH, p: p),
      ),
    );
  }

  // ── Nav ───────────────────────────────────────────────────────────────────
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
      _NavBtn(icon: Icons.home_rounded,         label: 'Home',     active: true,  p: p),
      _NavBtn(icon: Icons.person_rounded,       label: 'Profile',  active: false, p: p),
      _NavBtn(icon: Icons.settings_rounded,     label: 'Settings', active: false, p: p),
    ]),
  );

  void _openLevelSheet(BuildContext ctx, _Level l, _Palette p) =>
      showModalBottomSheet(context: ctx, backgroundColor: Colors.transparent,
          isScrollControlled: true,
          builder: (_) => _LevelSheet(level: l, p: p));

  void _openLockedSheet(BuildContext ctx, _Palette p) =>
      showModalBottomSheet(context: ctx, backgroundColor: Colors.transparent,
          builder: (_) => _LockedSheet(p: p));

  void _openSheet(BuildContext ctx, String title, _Palette p) =>
      showModalBottomSheet(context: ctx, backgroundColor: Colors.transparent,
          builder: (_) => _GenericSheet(title: title, p: p));
}

// ─────────────────────────────────────────────────────────────────────────────
// ISO PLATFORM PAINTER — draws a 3-face isometric block
// ─────────────────────────────────────────────────────────────────────────────
class _IsoBlock extends CustomPainter {
  final Color topFace, leftFace, rightFace, edgeColor;
  final double depth;
  const _IsoBlock({required this.topFace, required this.leftFace,
    required this.rightFace, required this.edgeColor, this.depth = 14});

  @override
  void paint(Canvas canvas, Size size) {
    final w  = size.width;
    final th = size.height * 0.48; // height of top face
    final d  = depth;

    // ── Top face (diamond / parallelogram) ──────────────────────────────
    final top = Path()
      ..moveTo(w * 0.5, 0)          // top-centre peak
      ..lineTo(w, th * 0.55)        // right
      ..lineTo(w * 0.5, th)         // bottom-centre
      ..lineTo(0, th * 0.55)        // left
      ..close();

    // ── Left side face ───────────────────────────────────────────────────
    final left = Path()
      ..moveTo(0, th * 0.55)
      ..lineTo(w * 0.5, th)
      ..lineTo(w * 0.5, th + d)
      ..lineTo(0, th * 0.55 + d)
      ..close();

    // ── Right side face ──────────────────────────────────────────────────
    final right = Path()
      ..moveTo(w * 0.5, th)
      ..lineTo(w, th * 0.55)
      ..lineTo(w, th * 0.55 + d)
      ..lineTo(w * 0.5, th + d)
      ..close();

    final edge = Paint()
      ..color = edgeColor
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    canvas.drawPath(top,   Paint()..color = topFace);
    canvas.drawPath(left,  Paint()..color = leftFace);
    canvas.drawPath(right, Paint()..color = rightFace);
    canvas.drawPath(top,   edge);
    canvas.drawPath(left,  edge);
    canvas.drawPath(right, edge);
  }

  @override
  bool shouldRepaint(covariant _IsoBlock o) => o.topFace != topFace;
}

// ─────────────────────────────────────────────────────────────────────────────
// ACTIVE PLATFORM (floating + pulsing glow)
// ─────────────────────────────────────────────────────────────────────────────
class _ActivePlatform extends StatelessWidget {
  final _Level level;
  final double platW, platH;
  final AnimationController pulseCtrl, floatCtrl;
  final _Palette p;
  const _ActivePlatform({required this.level, required this.platW,
    required this.platH, required this.pulseCtrl,
    required this.floatCtrl, required this.p});

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([pulseCtrl, floatCtrl]),
    builder: (_, __) {
      final pulse = CurvedAnimation(parent: pulseCtrl, curve: Curves.easeInOut).value;
      final dy    = CurvedAnimation(parent: floatCtrl, curve: Curves.easeInOut).value * 5.0;
      final depth = 14.0;

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ── Glow + floating iso block ────────────────────────────────
          Transform.translate(
            offset: Offset(0, -dy),
            child: Stack(alignment: Alignment.center, children: [
              // Outer pulse ring
              Container(
                width: platW + 18 + pulse * 16,
                height: platW + 18 + pulse * 16,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: p.accent.withOpacity(0.07 + pulse * 0.07),
                ),
              ),
              SizedBox(
                width: platW,
                height: platH + depth,
                child: Stack(children: [
                  CustomPaint(
                    size: Size(platW, platH + depth),
                    painter: _IsoBlock(
                      topFace:   p.accent,
                      leftFace:  Color.lerp(p.accent, Colors.black, 0.38)!,
                      rightFace: Color.lerp(p.accent, Colors.black, 0.58)!,
                      edgeColor: Colors.white.withOpacity(0.25),
                      depth: depth,
                    ),
                  ),
                  // Content centred on top face
                  Positioned(
                    top: 0, left: 0, right: 0,
                    height: platH * 0.72,
                    child: Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(level.emoji, style: TextStyle(fontSize: 18.sp)),
                        SizedBox(height: 1.h),
                        Text('LV ${level.number}',
                            style: GoogleFonts.dmMono(
                                fontSize: 7.sp, color: Colors.white,
                                fontWeight: FontWeight.w800)),
                      ]),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
          SizedBox(height: 5.h),
          // ── Label pill ─────────────────────────────────────────────────
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: p.accent.withOpacity(0.18),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(color: p.accent.withOpacity(0.45)),
            ),
            child: Text(level.title,
                maxLines: 1, overflow: TextOverflow.ellipsis,
                style: GoogleFonts.dmMono(
                    fontSize: 8.sp, color: p.accent, fontWeight: FontWeight.w700)),
          ),
        ],
      );
    },
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STATIC PLATFORM (done / locked)
// ─────────────────────────────────────────────────────────────────────────────
class _StaticPlatform extends StatelessWidget {
  final _Level level;
  final double platW, platH;
  final _Palette p;
  const _StaticPlatform({required this.level, required this.platW,
    required this.platH, required this.p});

  @override
  Widget build(BuildContext context) {
    final done   = level.state == _State.done;
    final locked = level.state == _State.locked;
    final isBoss = level.tag == 'BOSS';
    final depth  = isBoss ? 18.0 : locked ? 7.0 : 13.0;

    final base   = done ? level.nodeColor : isBoss ? p.gold : p.surface2;
    final topFace  = done
        ? Color.lerp(base, Colors.white, 0.18)!
        : isBoss ? Color.lerp(p.gold, Colors.white, 0.22)!
        : p.surface2;
    final leftFace = Color.lerp(topFace, Colors.black,
        done ? 0.32 : isBoss ? 0.38 : 0.15)!;
    final rightFace = Color.lerp(topFace, Colors.black,
        done ? 0.52 : isBoss ? 0.55 : 0.28)!;
    final edgeColor = done
        ? base.withOpacity(0.55)
        : isBoss ? p.gold.withOpacity(0.5)
        : p.hint.withOpacity(0.2);

    return Column(mainAxisSize: MainAxisSize.min, children: [
      // ── Iso block ──────────────────────────────────────────────────────
      SizedBox(
        width: platW, height: platH + depth,
        child: Stack(children: [
          CustomPaint(
            size: Size(platW, platH + depth),
            painter: _IsoBlock(
              topFace: topFace, leftFace: leftFace, rightFace: rightFace,
              edgeColor: edgeColor, depth: depth,
            ),
          ),
          // Content
          Positioned(
            top: 0, left: 0, right: 0,
            height: (platH + depth) * 0.60,
            child: Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                locked && !isBoss
                    ? Icon(Icons.lock_rounded, size: 16.sp,
                    color: p.hint.withOpacity(0.5))
                    : Text(level.emoji,
                    style: TextStyle(fontSize: isBoss ? 22.sp : 15.sp)),
                if (done) ...[
                  SizedBox(height: 2.h),
                  Row(mainAxisSize: MainAxisSize.min,
                      children: List.generate(3, (i) => Icon(
                        i < level.stars
                            ? Icons.star_rounded : Icons.star_outline_rounded,
                        size: 7.5.sp,
                        color: i < level.stars
                            ? p.gold : Colors.white.withOpacity(0.22),
                      ))),
                ],
              ]),
            ),
          ),
          // Boss shimmer overlay
          if (isBoss)
            Positioned.fill(child: CustomPaint(painter: _GlowRim(p.gold))),
        ]),
      ),
      SizedBox(height: 4.h),
      // ── Title label ────────────────────────────────────────────────────
      if (done || isBoss)
        Text(level.title,
            maxLines: 1, overflow: TextOverflow.ellipsis,
            style: GoogleFonts.dmMono(
              fontSize: 7.5.sp,
              color: isBoss ? p.gold : done ? level.nodeColor : p.sub,
              fontWeight: FontWeight.w700,
            )),
      if (locked && !isBoss)
        Text('LV ${level.number}',
            style: GoogleFonts.dmMono(
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
          Paint()
            ..color = color.withOpacity(0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12));
  @override bool shouldRepaint(_) => false;
}

// ─────────────────────────────────────────────────────────────────────────────
// ROAD PAINTER
// ─────────────────────────────────────────────────────────────────────────────
class _RoadPainter extends CustomPainter {
  final List<Offset> pts;
  final List<_Level> levels;
  final _Palette p;
  final bool isDark;
  const _RoadPainter(this.pts, this.levels, this.p, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    for (var i = 0; i < pts.length - 1; i++) {
      final a = pts[i], b = pts[i + 1];
      final done = levels[i].state == _State.done;

      if (done) {
        // broad glow
        canvas.drawLine(a, b, Paint()
          ..color = p.win.withOpacity(isDark ? 0.16 : 0.10)
          ..strokeWidth = 20
          ..strokeCap = StrokeCap.round);
        // core
        canvas.drawLine(a, b, Paint()
          ..color = p.win.withOpacity(0.60)
          ..strokeWidth = 3.5
          ..strokeCap = StrokeCap.round);
        // bright centre
        canvas.drawLine(a, b, Paint()
          ..color = Colors.white.withOpacity(0.18)
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round);
      } else {
        _dash(canvas, a, b, Paint()
          ..color = p.hint.withOpacity(0.28)
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round);
      }
    }
  }

  void _dash(Canvas c, Offset a, Offset b, Paint paint) {
    final total = (b - a).distance;
    final dir = (b - a) / total;
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
// STARFIELD PAINTER (ambient bg)
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

// ─────────────────────────────────────────────────────────────────────────────
// SPARKLE / EMBER PAINTER (floats on the map scroll layer)
// ─────────────────────────────────────────────────────────────────────────────
class _SparkPainter extends CustomPainter {
  final double t;
  final bool isDark;
  const _SparkPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    if (!isDark) return;
    final rng = math.Random(13);
    const cols = [Color(0xFF9D8FF7), Color(0xFF3DD68C), Color(0xFFFFB82E)];
    for (var i = 0; i < 28; i++) {
      final bx = rng.nextDouble() * size.width;
      final by = rng.nextDouble() * size.height;
      final phase = rng.nextDouble() * math.pi * 2;
      final dy  = math.sin(t * math.pi + phase) * 14;
      final op  = (0.25 + math.sin(t * math.pi * 2 + phase) * 0.3).clamp(0.0, 0.7);
      final r   = rng.nextDouble() * 1.6 + 0.4;
      canvas.drawCircle(Offset(bx, by + dy), r,
          Paint()..color = cols[i % cols.length].withOpacity(op));
    }
  }

  @override bool shouldRepaint(covariant _SparkPainter o) => o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String emoji, label;
  final Color fg, bg;
  const _Chip({required this.emoji, required this.label,
    required this.fg, required this.bg});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: fg.withOpacity(0.3))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Text(emoji, style: TextStyle(fontSize: 11.sp)),
      SizedBox(width: 5.w),
      Text(label, style: GoogleFonts.dmMono(
          fontSize: 10.sp, color: fg, fontWeight: FontWeight.w700)),
    ]),
  );
}

class _ActionChip extends StatefulWidget {
  final String emoji, label;
  final Color fg, bg;
  final VoidCallback onTap;
  const _ActionChip({required this.emoji, required this.label,
    required this.fg, required this.bg, required this.onTap});
  @override State<_ActionChip> createState() => _ActionChipState();
}
class _ActionChipState extends State<_ActionChip>
    with SingleTickerProviderStateMixin {
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
// BOTTOM SHEETS
// ─────────────────────────────────────────────────────────────────────────────
class _LevelSheet extends StatelessWidget {
  final _Level level; final _Palette p;
  const _LevelSheet({required this.level, required this.p});
  @override
  Widget build(BuildContext context) {
    final done  = level.state == _State.done;
    final color = done ? level.nodeColor : p.accent;
    return _Sheet(p: p, children: [
      Text(level.emoji, style: TextStyle(fontSize: 48.sp)),
      SizedBox(height: 8.h),
      Text(level.title,
          style: GoogleFonts.dmSerifDisplay(fontSize: 24.sp, color: p.text)),
      SizedBox(height: 6.h),
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        _Badge(label: level.tag, color: color),
        SizedBox(width: 8.w),
        _Badge(label: 'Level ${level.number}', color: p.sub),
      ]),
      if (done) ...[
        SizedBox(height: 12.h),
        Row(mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (i) => Icon(
              i < level.stars ? Icons.star_rounded : Icons.star_outline_rounded,
              size: 28.sp,
              color: i < level.stars ? p.gold : p.hint.withOpacity(0.3),
            ))),
      ],
      SizedBox(height: 26.h),
      _Btn(label: done ? '🔄  Play Again' : '⚔️  Start Battle', color: color,
          onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(context); }),
      SizedBox(height: 10.h),
      _Btn(label: '👥  Challenge a Friend', color: p.win,
          onTap: () { HapticFeedback.lightImpact(); Navigator.pop(context); }),
      SizedBox(height: 14.h),
      GestureDetector(onTap: () => Navigator.pop(context),
          child: Text('Cancel', style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.sub))),
    ]);
  }
}

class _LockedSheet extends StatelessWidget {
  final _Palette p;
  const _LockedSheet({required this.p});
  @override
  Widget build(BuildContext context) => _Sheet(p: p, children: [
    Text('🔒', style: TextStyle(fontSize: 48.sp)),
    SizedBox(height: 10.h),
    Text('Level Locked',
        style: GoogleFonts.dmSerifDisplay(fontSize: 22.sp, color: p.text)),
    SizedBox(height: 6.h),
    Text('Complete the previous level\nto unlock this one.',
        textAlign: TextAlign.center,
        style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.5)),
    SizedBox(height: 26.h),
    _Btn(label: '⚔️  Go to Current Level', color: p.accent,
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
    final info = _info[title] ?? ('🎮', title, 'Coming soon...');
    return _Sheet(p: p, children: [
      Text(info.$1, style: TextStyle(fontSize: 44.sp)),
      SizedBox(height: 10.h),
      Text(info.$2,
          style: GoogleFonts.dmSerifDisplay(fontSize: 22.sp, color: p.text)),
      SizedBox(height: 8.h),
      Text(info.$3, textAlign: TextAlign.center,
          style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.5)),
      SizedBox(height: 28.h),
      _Btn(label: 'Let\'s Go →', color: p.accent,
          onTap: () { HapticFeedback.heavyImpact(); Navigator.pop(context); }),
      SizedBox(height: 14.h),
      GestureDetector(onTap: () => Navigator.pop(context),
          child: Text('Maybe later',
              style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.sub))),
    ]);
  }
}

// Shared sheet wrapper
class _Sheet extends StatelessWidget {
  final _Palette p;
  final List<Widget> children;
  const _Sheet({required this.p, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 40.h),
    decoration: BoxDecoration(
      color: p.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 40.w, height: 4.h,
          decoration: BoxDecoration(color: p.hint.withOpacity(0.35),
              borderRadius: BorderRadius.circular(99.r))),
      SizedBox(height: 20.h),
      ...children,
    ]),
  );
}

class _Badge extends StatelessWidget {
  final String label; final Color color;
  const _Badge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(8.r),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(label, style: GoogleFonts.dmMono(
        fontSize: 10.sp, color: color, fontWeight: FontWeight.w700)),
  );
}

class _Btn extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _Btn({required this.label, required this.color, required this.onTap});
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