import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../home/data/progress_service.dart';
import '../../../home/data/level_service.dart';
import '../../../home/domain/level_model.dart';
import '../../../home/domain/progress_model.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _Palette {
  final Color bg, surface, surface2, surface3;
  final Color accent, accentSoft;
  final Color win, winSoft, loss, lossSoft, gold, goldSoft;
  final Color text, sub, hint, code;

  const _Palette({
    required this.bg, required this.surface, required this.surface2, required this.surface3,
    required this.accent, required this.accentSoft,
    required this.win, required this.winSoft, required this.loss, required this.lossSoft,
    required this.gold, required this.goldSoft,
    required this.text, required this.sub, required this.hint, required this.code,
  });

  static const _light = _Palette(
    bg: Color(0xFFF0EDF9), surface: Color(0xFFFFFFFF),
    surface2: Color(0xFFE4E0F5), surface3: Color(0xFFF8F6FF),
    accent: Color(0xFF7C6EF5), accentSoft: Color(0xFFEBE8FD),
    win: Color(0xFF4FC995), winSoft: Color(0xFFDFF5EC),
    loss: Color(0xFFF47B7B), lossSoft: Color(0xFFFDECEC),
    gold: Color(0xFFE8A83E), goldSoft: Color(0xFFFDF3E1),
    text: Color(0xFF1C1830), sub: Color(0xFF8A85A0), hint: Color(0xFFB8B4CC),
    code: Color(0xFF1A1730),
  );

  static const _dark = _Palette(
    bg: Color(0xFF080611), surface: Color(0xFF13101C),
    surface2: Color(0xFF1B1727), surface3: Color(0xFF0F0D1A),
    accent: Color(0xFF9D8FF7), accentSoft: Color(0xFF1E1A38),
    win: Color(0xFF3DD68C), winSoft: Color(0xFF0D2B1F),
    loss: Color(0xFFFF6B6B), lossSoft: Color(0xFF2B1212),
    gold: Color(0xFFFFB82E), goldSoft: Color(0xFF2A1F07),
    text: Color(0xFFF0EDF9), sub: Color(0xFF8A85A0), hint: Color(0xFF2A2640),
    code: Color(0xFF0A0815),
  );

  static _Palette of(BuildContext ctx) =>
      Theme.of(ctx).brightness == Brightness.dark ? _dark : _light;
}

// ─────────────────────────────────────────────────────────────────────────────
// SUBMISSION STATE
// ─────────────────────────────────────────────────────────────────────────────
enum _SubmitState { idle, running, passed, failed }

class _TestResult {
  final TestCase testCase;
  final bool     passed;
  final String   actualOutput;
  final int      index;
  const _TestResult({
    required this.testCase, required this.passed,
    required this.actualOutput, required this.index,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// BATTLE SCREEN
// ─────────────────────────────────────────────────────────────────────────────
class BattleScreen extends StatefulWidget {
  final Level        level;
  final UserProgress progress;

  const BattleScreen({super.key, required this.level, required this.progress});

  @override
  State<BattleScreen> createState() => _BattleScreenState();
}

class _BattleScreenState extends State<BattleScreen> with TickerProviderStateMixin {
  // ── Controllers ───────────────────────────────────────────────────────────
  late final AnimationController _bgCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _resultCtrl;
  late final AnimationController _runCtrl;   // spinning run indicator
  late final TextEditingController _codeCtrl;
  late final ScrollController _codeScroll;
  late final ScrollController _outputScroll;

  // ── State ─────────────────────────────────────────────────────────────────
  String          _lang         = 'python';
  _SubmitState    _submitState  = _SubmitState.idle;
  List<_TestResult> _results    = [];
  int             _activeTab    = 0; // 0 = editor, 1 = problem, 2 = results
  bool            _showOutput   = false;
  int             _elapsedSecs  = 0;
  bool            _timerRunning = false;

  // ── Services ──────────────────────────────────────────────────────────────
  final _progSvc = ProgressService();
  final _lvlSvc  = LevelService();

  // ── Timer ─────────────────────────────────────────────────────────────────
  late final Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _bgCtrl    = AnimationController(vsync: this, duration: const Duration(seconds: 12))..repeat(reverse: true);
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _resultCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _runCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat();
    _codeScroll  = ScrollController();
    _outputScroll = ScrollController();
    _stopwatch   = Stopwatch();

    // Determine initial language
    _lang = widget.level.starterCode.keys.contains('python') ? 'python'
        : widget.level.starterCode.keys.first;

    _codeCtrl = TextEditingController(text: widget.level.starterCode[_lang] ?? '');

    // Start timer when user loads battle screen
    _stopwatch.start();
    _timerRunning = true;
    _tickTimer();
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); _entryCtrl.dispose();
    _resultCtrl.dispose(); _runCtrl.dispose();
    _codeCtrl.dispose(); _codeScroll.dispose(); _outputScroll.dispose();
    _stopwatch.stop();
    super.dispose();
  }

  void _tickTimer() async {
    while (_timerRunning && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _timerRunning) setState(() => _elapsedSecs = _stopwatch.elapsed.inSeconds);
    }
  }

  String get _timerLabel {
    final m = _elapsedSecs ~/ 60;
    final s = _elapsedSecs % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  // ── Language switch ───────────────────────────────────────────────────────
  void _switchLang(String lang) {
    setState(() {
      _lang = lang;
      _codeCtrl.text = widget.level.starterCode[lang] ?? '';
    });
  }

  // ── Run / Submit ──────────────────────────────────────────────────────────
  // In production this would hit your code execution backend.
  // Here we simulate a realistic delay + mock pass/fail logic so the UI works
  // completely without a backend connection.
  Future<void> _runCode({required bool submitAll}) async {
    if (_submitState == _SubmitState.running) return;
    HapticFeedback.heavyImpact();

    setState(() {
      _submitState = _SubmitState.running;
      _showOutput  = true;
      _results     = [];
      _activeTab   = 2; // jump to results tab
    });

    // Simulate execution delay
    await Future.delayed(Duration(milliseconds: 900 + math.Random().nextInt(600)));
    if (!mounted) return;

    // ── Mock result logic ─────────────────────────────────────────────────
    // Checks if the user kept the default starter code (all-pass) or
    // cleared/changed it (random pass/fail for demo purposes).
    final code    = _codeCtrl.text.trim();
    final starter = (widget.level.starterCode[_lang] ?? '').trim();
    final isDefaultCode = code == starter || code.isEmpty;

    final testCases = submitAll
        ? widget.level.testCases
        : widget.level.testCases.where((t) => !t.isHidden).toList();

    final rng = math.Random();
    final results = <_TestResult>[];
    int passed = 0;

    for (var i = 0; i < testCases.length; i++) {
      final tc = testCases[i];
      // If code is default starter, simulate mostly-passing for demo
      // If code is empty, fail all
      final bool pass = code.isEmpty
          ? false
          : isDefaultCode
          ? (i < testCases.length - 1 || rng.nextBool())
          : rng.nextDouble() > 0.35;

      final actual = pass
          ? tc.expectedOutput
          : _mockWrongOutput(tc.expectedOutput);

      results.add(_TestResult(
        testCase: tc, passed: pass,
        actualOutput: actual, index: i,
      ));
      if (pass) passed++;
    }

    final allPassed = passed == testCases.length;

    setState(() {
      _results     = results;
      _submitState = allPassed ? _SubmitState.passed : _SubmitState.failed;
    });

    _resultCtrl.forward(from: 0);
    HapticFeedback.mediumImpact();

    // ── If all passed on a submit, save to Firestore ──────────────────────
    if (allPassed && submitAll) {
      _stopwatch.stop();
      _timerRunning = false;

      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        final timeSecs = _stopwatch.elapsed.inSeconds;
        final attempts = widget.progress.attempts + 1;
        final stars    = ProgressService.calculateStars(
            timeTaken: timeSecs, attempts: attempts);

        // Find next level id to unlock
        try {
          final levels     = await _lvlSvc.getLevels();
          final idx        = levels.indexWhere((l) => l.id == widget.level.id);
          final nextId     = (idx != -1 && idx + 1 < levels.length)
              ? levels[idx + 1].id : null;

          await _progSvc.completeLevel(
            uid:        uid,
            levelId:    widget.level.id,
            nextLevelId: nextId,
            stars:      stars,
            xpReward:   widget.level.xpReward,
          );
          if (mounted) _showVictorySheet(stars);
        } catch (e) {
          // Non-fatal — user still sees the passed UI
          if (mounted) _showVictorySheet(3);
        }
      }
    }
  }

  String _mockWrongOutput(String expected) {
    // Produce something plausible-looking but wrong
    if (expected.startsWith('[')) return '[${expected.substring(1, expected.length - 1).split(',').reversed.join(',')}]';
    if (int.tryParse(expected) != null) return '${(int.parse(expected) + math.Random().nextInt(5) + 1)}';
    if (expected == 'true') return 'false';
    if (expected == 'false') return 'true';
    return '"${expected}_wrong"';
  }

  // ─────────────────────────────────────────────────────────────────────────
  // BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final p      = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size   = MediaQuery.of(context).size;
    final tc     = _tagColor(p);

    return Scaffold(
      backgroundColor: p.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(children: [

        // ── Subtle animated bg ───────────────────────────────────────────
        AnimatedBuilder(
          animation: _bgCtrl,
          builder: (_, __) => CustomPaint(
            size: size,
            painter: _BattleBgPainter(
                CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut).value,
                tc, isDark),
          ),
        ),

        // ── Main layout ──────────────────────────────────────────────────
        SafeArea(
          child: Column(children: [
            _buildTopBar(p, tc),
            _buildTabBar(p, tc),
            Expanded(child: _buildBody(p, isDark, tc)),
            _buildBottomBar(p, tc),
          ]),
        ),
      ]),
    );
  }

  Color _tagColor(_Palette p) {
    switch (widget.level.tag.toLowerCase()) {
      case 'easy':   return p.win;
      case 'medium': return p.gold;
      case 'hard':   return p.loss;
      default:       return p.gold;
    }
  }

  // ── Top bar ───────────────────────────────────────────────────────────────
  Widget _buildTopBar(_Palette p, Color tc) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.0, 0.5, curve: Curves.easeOut)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
        child: Row(children: [
          // Back button
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); Navigator.of(context).pop(); },
            child: Container(
              width: 38.w, height: 38.w,
              decoration: BoxDecoration(
                color: p.surface, borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: p.hint.withOpacity(0.2)),
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 14.sp, color: p.text),
            ),
          ),
          SizedBox(width: 12.w),

          // Level title
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.level.title,
                  maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.dmSerifDisplay(fontSize: 16.sp, color: p.text)),
              Text('Level ${widget.level.number}  ·  ${widget.level.tag}',
                  style: GoogleFonts.dmMono(fontSize: 9.sp, color: p.sub)),
            ]),
          ),

          SizedBox(width: 8.w),

          // Timer
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: p.surface2, borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: p.hint.withOpacity(0.2)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.timer_outlined, size: 10.sp, color: p.sub),
              SizedBox(width: 4.w),
              Text(_timerLabel,
                  style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub,
                      fontWeight: FontWeight.w700)),
            ]),
          ),

          SizedBox(width: 8.w),

          // XP badge
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: tc.withOpacity(0.12), borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: tc.withOpacity(0.3)),
            ),
            child: Text('+${widget.level.xpReward} XP',
                style: GoogleFonts.dmMono(fontSize: 10.sp, color: tc,
                    fontWeight: FontWeight.w700)),
          ),
        ]),
      ),
    );
  }

  // ── Tab bar ───────────────────────────────────────────────────────────────
  Widget _buildTabBar(_Palette p, Color tc) {
    final tabs = [
      (icon: Icons.code_rounded,         label: 'Code'),
      (icon: Icons.description_outlined, label: 'Problem'),
      (icon: Icons.science_outlined,     label: 'Results'),
    ];
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.1, 0.6, curve: Curves.easeOut)),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
        child: Container(
          height: 40.h,
          decoration: BoxDecoration(
            color: p.surface2, borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(children: List.generate(tabs.length, (i) {
            final selected = _activeTab == i;
            final hasResult = i == 2 && _results.isNotEmpty;
            return Expanded(
              child: GestureDetector(
                onTap: () { HapticFeedback.selectionClick(); setState(() => _activeTab = i); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: EdgeInsets.all(3.w),
                  decoration: BoxDecoration(
                    color: selected ? p.surface : Colors.transparent,
                    borderRadius: BorderRadius.circular(11.r),
                    boxShadow: selected
                        ? [BoxShadow(color: Colors.black.withOpacity(0.08),
                        blurRadius: 6, offset: const Offset(0, 2))]
                        : null,
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(tabs[i].icon, size: 13.sp,
                        color: selected ? tc : p.sub),
                    SizedBox(width: 5.w),
                    Text(tabs[i].label,
                        style: GoogleFonts.dmMono(fontSize: 10.sp,
                            color: selected ? tc : p.sub,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                    if (hasResult) ...[
                      SizedBox(width: 4.w),
                      _ResultDot(results: _results),
                    ],
                  ]),
                ),
              ),
            );
          })),
        ),
      ),
    );
  }

  // ── Body ──────────────────────────────────────────────────────────────────
  Widget _buildBody(_Palette p, bool isDark, Color tc) {
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.2, 0.8, curve: Curves.easeOut)),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        transitionBuilder: (child, anim) => FadeTransition(opacity: anim, child: child),
        child: KeyedSubtree(
          key: ValueKey(_activeTab),
          child: _activeTab == 0 ? _buildEditor(p, isDark, tc)
              : _activeTab == 1 ? _buildProblem(p, isDark, tc)
              : _buildResults(p, isDark, tc),
        ),
      ),
    );
  }

  // ── Code editor ───────────────────────────────────────────────────────────
  Widget _buildEditor(_Palette p, bool isDark, Color tc) {
    return Column(children: [
      // Language selector
      Padding(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
        child: Row(children: [
          Text('Language', style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub)),
          const Spacer(),
          ...widget.level.starterCode.keys.map((lang) => GestureDetector(
            onTap: () => _switchLang(lang),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              margin: EdgeInsets.only(left: 6.w),
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 5.h),
              decoration: BoxDecoration(
                color: _lang == lang ? tc.withOpacity(0.15) : p.surface2,
                borderRadius: BorderRadius.circular(9.r),
                border: Border.all(color: _lang == lang
                    ? tc.withOpacity(0.45) : p.hint.withOpacity(0.2)),
              ),
              child: Text(lang.toUpperCase(),
                  style: GoogleFonts.dmMono(
                    fontSize: 9.sp,
                    color: _lang == lang ? tc : p.sub,
                    fontWeight: FontWeight.w700,
                  )),
            ),
          )),
        ]),
      ),

      SizedBox(height: 8.h),

      // Editor area
      Expanded(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: p.code,
            borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: p.hint.withOpacity(0.12)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18),
                blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18.r),
            child: Column(children: [
              // Editor chrome bar
              Container(
                height: 32.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.04),
                  border: Border(bottom: BorderSide(
                      color: Colors.white.withOpacity(0.06))),
                ),
                padding: EdgeInsets.symmetric(horizontal: 14.w),
                child: Row(children: [
                  // Fake traffic lights
                  Row(children: [
                    _TrafficLight(const Color(0xFFFF5F57)),
                    SizedBox(width: 5.w),
                    _TrafficLight(const Color(0xFFFFBD2E)),
                    SizedBox(width: 5.w),
                    _TrafficLight(const Color(0xFF28CA41)),
                  ]),
                  const Spacer(),
                  Text('${_lang}.${_lang == 'python' ? 'py' : 'js'}',
                      style: GoogleFonts.dmMono(fontSize: 9.sp,
                          color: Colors.white.withOpacity(0.35))),
                ]),
              ),

              // The actual text field
              Expanded(
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  // Line numbers
                  _LineNumbers(controller: _codeCtrl, p: p),
                  // Code text field
                  Expanded(
                    child: Scrollbar(
                      controller: _codeScroll,
                      child: SingleChildScrollView(
                        controller: _codeScroll,
                        padding: EdgeInsets.fromLTRB(8.w, 12.h, 14.w, 12.h),
                        child: TextField(
                          controller: _codeCtrl,
                          maxLines: null,
                          keyboardType: TextInputType.multiline,
                          style: GoogleFonts.dmMono(
                            fontSize: 12.5.sp,
                            color: const Color(0xFFB8D0FF),
                            height: 1.65,
                          ),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          cursorColor: const Color(0xFF9D8FF7),
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                    ),
                  ),
                ]),
              ),
            ]),
          ),
        ),
      ),

      SizedBox(height: 8.h),
    ]);
  }

  // ── Problem tab ───────────────────────────────────────────────────────────
  Widget _buildProblem(_Palette p, bool isDark, Color tc) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // Header card
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: p.surface, borderRadius: BorderRadius.circular(18.r),
            border: Border.all(color: tc.withOpacity(0.2)),
            boxShadow: [BoxShadow(color: tc.withOpacity(0.08),
                blurRadius: 16, offset: const Offset(0, 6))],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: 56.w, height: 56.w,
              decoration: BoxDecoration(
                color: tc.withOpacity(0.12), borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: tc.withOpacity(0.25)),
              ),
              child: Center(child: Text(widget.level.emoji,
                  style: TextStyle(fontSize: 26.sp))),
            ),
            SizedBox(width: 12.w),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(widget.level.title,
                  style: GoogleFonts.dmSerifDisplay(fontSize: 18.sp, color: p.text)),
              SizedBox(height: 5.h),
              Wrap(spacing: 6.w, runSpacing: 4.h, children: [
                _Pill(label: widget.level.tag, color: tc),
                _Pill(label: '${widget.level.xpReward} XP', color: p.gold),
              ]),
            ])),
          ]),
        ),

        SizedBox(height: 16.h),

        // Description
        Text('Problem Statement',
            style: GoogleFonts.dmSerifDisplay(fontSize: 16.sp, color: p.text)),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity, padding: EdgeInsets.all(14.w),
          decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14.r),
              border: Border.all(color: p.hint.withOpacity(0.1))),
          child: Text(widget.level.description,
              style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.7)),
        ),

        SizedBox(height: 16.h),

        // Visible test cases
        Text('Examples',
            style: GoogleFonts.dmSerifDisplay(fontSize: 16.sp, color: p.text)),
        SizedBox(height: 8.h),
        ...widget.level.testCases.where((t) => !t.isHidden).map((tc2) {
          final i = widget.level.testCases.indexOf(tc2);
          return Container(
            width: double.infinity,
            margin: EdgeInsets.only(bottom: 10.h),
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: p.hint.withOpacity(0.1))),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Example ${i + 1}', style: GoogleFonts.dmMono(
                  fontSize: 10.sp, color: tc, fontWeight: FontWeight.w700)),
              SizedBox(height: 8.h),
              _ExRow(label: 'Input:',    value: tc2.input,          color: tc,   p: p),
              SizedBox(height: 4.h),
              _ExRow(label: 'Expected:', value: tc2.expectedOutput, color: p.win, p: p),
            ]),
          );
        }),
      ]),
    );
  }

  // ── Results tab ───────────────────────────────────────────────────────────
  Widget _buildResults(_Palette p, bool isDark, Color tc) {
    if (_submitState == _SubmitState.running) {
      return _buildRunning(p, tc);
    }
    if (_results.isEmpty) {
      return _buildNoResults(p);
    }
    return _buildResultsList(p, isDark, tc);
  }

  Widget _buildRunning(_Palette p, Color tc) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      AnimatedBuilder(
        animation: _runCtrl,
        builder: (_, __) => Transform.rotate(
          angle: _runCtrl.value * math.pi * 2,
          child: Container(
            width: 52.w, height: 52.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(colors: [tc.withOpacity(0.0), tc]),
            ),
            child: Padding(
              padding: EdgeInsets.all(4.w),
              child: Container(decoration: BoxDecoration(
                  color: p.bg, shape: BoxShape.circle)),
            ),
          ),
        ),
      ),
      SizedBox(height: 18.h),
      Text('Running tests…',
          style: GoogleFonts.dmSerifDisplay(fontSize: 18.sp, color: p.text)),
      SizedBox(height: 6.h),
      Text('Executing your code against all test cases',
          style: GoogleFonts.dmMono(fontSize: 11.sp, color: p.sub)),
    ]),
  );

  Widget _buildNoResults(_Palette p) => Center(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text('🧪', style: TextStyle(fontSize: 44.sp)),
      SizedBox(height: 12.h),
      Text('No results yet', style: GoogleFonts.dmSerifDisplay(fontSize: 18.sp, color: p.text)),
      SizedBox(height: 6.h),
      Text('Run your code to see test results here',
          style: GoogleFonts.dmMono(fontSize: 11.sp, color: p.sub)),
    ]),
  );

  Widget _buildResultsList(_Palette p, bool isDark, Color tc) {
    final passed = _results.where((r) => r.passed).length;
    final total  = _results.length;
    final allPassed = passed == total;
    final statusColor = allPassed ? p.win : p.loss;

    return SingleChildScrollView(
      controller: _outputScroll,
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 20.h),
      child: AnimatedBuilder(
        animation: _resultCtrl,
        builder: (_, child) => FadeTransition(
          opacity: _resultCtrl,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero)
                .animate(_resultCtrl),
            child: child,
          ),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Summary banner
          Container(
            width: double.infinity, padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.10),
              borderRadius: BorderRadius.circular(18.r),
              border: Border.all(color: statusColor.withOpacity(0.35)),
            ),
            child: Row(children: [
              Container(
                width: 44.w, height: 44.w,
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.15), shape: BoxShape.circle,
                  border: Border.all(color: statusColor.withOpacity(0.3)),
                ),
                child: Center(child: Text(allPassed ? '✅' : '❌',
                    style: TextStyle(fontSize: 20.sp))),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(allPassed ? 'All Tests Passed!' : 'Some Tests Failed',
                      style: GoogleFonts.dmSerifDisplay(
                          fontSize: 18.sp, color: statusColor)),
                  SizedBox(height: 2.h),
                  Text('$passed / $total test cases passed',
                      style: GoogleFonts.dmMono(fontSize: 11.sp, color: p.sub)),
                ]),
              ),
              // Pass rate bar
              Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                Text('${(passed / total * 100).round()}%',
                    style: GoogleFonts.dmMono(fontSize: 16.sp,
                        color: statusColor, fontWeight: FontWeight.w800)),
                SizedBox(height: 4.h),
                SizedBox(
                  width: 50.w, height: 5.h,
                  child: ClipRRect(borderRadius: BorderRadius.circular(99.r),
                    child: LinearProgressIndicator(
                      value: passed / total,
                      backgroundColor: p.hint.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(statusColor),
                    ),
                  ),
                ),
              ]),
            ]),
          ),

          SizedBox(height: 14.h),

          // Individual test results
          ..._results.asMap().entries.map((e) => _TestResultCard(
            result: e.value, p: p, index: e.key,
          )),
        ]),
      ),
    );
  }

  // ── Bottom action bar ─────────────────────────────────────────────────────
  Widget _buildBottomBar(_Palette p, Color tc) {
    final isRunning = _submitState == _SubmitState.running;
    return FadeTransition(
      opacity: CurvedAnimation(parent: _entryCtrl,
          curve: const Interval(0.3, 0.9, curve: Curves.easeOut)),
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 14.h),
        decoration: BoxDecoration(
          color: p.surface,
          border: Border(top: BorderSide(color: p.hint.withOpacity(0.10))),
        ),
        child: Row(children: [
          // Hint button
          GestureDetector(
            onTap: () { HapticFeedback.lightImpact(); _showHintSheet(p); },
            child: Container(
              width: 44.w, height: 44.w,
              decoration: BoxDecoration(
                color: p.surface2, borderRadius: BorderRadius.circular(13.r),
                border: Border.all(color: p.hint.withOpacity(0.2)),
              ),
              child: Icon(Icons.lightbulb_outline_rounded, size: 18.sp, color: p.gold),
            ),
          ),
          SizedBox(width: 10.w),

          // Reset button
          GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              setState(() => _codeCtrl.text =
                  widget.level.starterCode[_lang] ?? '');
            },
            child: Container(
              width: 44.w, height: 44.w,
              decoration: BoxDecoration(
                color: p.surface2, borderRadius: BorderRadius.circular(13.r),
                border: Border.all(color: p.hint.withOpacity(0.2)),
              ),
              child: Icon(Icons.refresh_rounded, size: 18.sp, color: p.sub),
            ),
          ),

          SizedBox(width: 10.w),

          // Run tests button (visible tests only)
          Expanded(
            flex: 2,
            child: _BarButton(
              label: 'Run Tests',
              icon: Icons.play_arrow_rounded,
              color: p.accent,
              loading: isRunning,
              runCtrl: _runCtrl,
              onTap: isRunning ? null : () => _runCode(submitAll: false),
            ),
          ),

          SizedBox(width: 10.w),

          // Submit button (all tests including hidden)
          Expanded(
            flex: 3,
            child: _BarButton(
              label: 'Submit Solution',
              icon: Icons.upload_rounded,
              color: tc,
              loading: isRunning,
              runCtrl: _runCtrl,
              onTap: isRunning ? null : () => _runCode(submitAll: true),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Hint sheet ────────────────────────────────────────────────────────────
  void _showHintSheet(_Palette p) {
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _HintSheet(level: widget.level, p: p),
    );
  }

  // ── Victory sheet ─────────────────────────────────────────────────────────
  void _showVictorySheet(int stars) {
    _timerRunning = false;
    showModalBottomSheet(
      context: context, backgroundColor: Colors.transparent,
      isDismissible: false, enableDrag: false,
      isScrollControlled: true,
      builder: (_) => _VictorySheet(
        level: widget.level,
        stars: stars,
        timeSecs: _stopwatch.elapsed.inSeconds,
        p: _Palette.of(context),
        onContinue: () {
          Navigator.of(context).pop(); // close sheet
          Navigator.of(context).pop(); // back to level screen
          Navigator.of(context).pop(); // back to map
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LINE NUMBERS WIDGET
// ─────────────────────────────────────────────────────────────────────────────
class _LineNumbers extends StatefulWidget {
  final TextEditingController controller;
  final _Palette p;
  const _LineNumbers({required this.controller, required this.p});
  @override State<_LineNumbers> createState() => _LineNumbersState();
}
class _LineNumbersState extends State<_LineNumbers> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() => setState(() {}));
  }
  @override
  Widget build(BuildContext context) {
    final lines = '\n'.allMatches(widget.controller.text).length + 1;
    return Container(
      width: 36.w,
      padding: EdgeInsets.fromLTRB(0, 12.h, 0, 12.h),
      decoration: BoxDecoration(
        border: Border(right: BorderSide(color: Colors.white.withOpacity(0.06))),
      ),
      child: Column(children: List.generate(lines, (i) => SizedBox(
        height: 12.5.sp * 1.65,
        child: Center(child: Text('${i + 1}',
            style: GoogleFonts.dmMono(fontSize: 10.sp,
                color: Colors.white.withOpacity(0.20)))),
      ))),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// TEST RESULT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _TestResultCard extends StatefulWidget {
  final _TestResult result;
  final _Palette    p;
  final int         index;
  const _TestResultCard({required this.result, required this.p, required this.index});
  @override State<_TestResultCard> createState() => _TestResultCardState();
}
class _TestResultCardState extends State<_TestResultCard> {
  bool _expanded = false;
  @override
  Widget build(BuildContext context) {
    final r      = widget.result;
    final p      = widget.p;
    final color  = r.passed ? p.win : p.loss;
    final bgCol  = r.passed ? p.winSoft : p.lossSoft;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); setState(() => _expanded = !_expanded); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: EdgeInsets.only(bottom: 10.h),
        decoration: BoxDecoration(
          color: p.surface, borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: color.withOpacity(0.25)),
          boxShadow: [BoxShadow(color: color.withOpacity(0.06),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Column(children: [
          // Header row
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(children: [
              Container(
                width: 28.w, height: 28.w,
                decoration: BoxDecoration(color: bgCol, shape: BoxShape.circle,
                    border: Border.all(color: color.withOpacity(0.3))),
                child: Center(child: Icon(
                  r.passed ? Icons.check_rounded : Icons.close_rounded,
                  size: 14.sp, color: color,
                )),
              ),
              SizedBox(width: 10.w),
              Text('Test Case ${r.index + 1}',
                  style: GoogleFonts.dmMono(fontSize: 11.sp,
                      color: p.text, fontWeight: FontWeight.w600)),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(color: bgCol, borderRadius: BorderRadius.circular(7.r)),
                child: Text(r.passed ? 'Passed' : 'Failed',
                    style: GoogleFonts.dmMono(fontSize: 9.sp,
                        color: color, fontWeight: FontWeight.w700)),
              ),
              SizedBox(width: 8.w),
              AnimatedRotation(
                turns: _expanded ? 0.5 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Icon(Icons.keyboard_arrow_down_rounded, size: 16.sp, color: p.sub),
              ),
            ]),
          ),

          // Expanded details
          if (_expanded)
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 0, 14.w, 14.h),
              child: Column(children: [
                const Divider(height: 1, color: Color(0x14FFFFFF)),
                SizedBox(height: 10.h),
                _ExRow(label: 'Input:',    value: r.testCase.input,          color: p.accent, p: p),
                SizedBox(height: 6.h),
                _ExRow(label: 'Expected:', value: r.testCase.expectedOutput, color: p.win,    p: p),
                SizedBox(height: 6.h),
                _ExRow(label: 'Got:',      value: r.actualOutput,            color: color,    p: p),
              ]),
            ),
        ]),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HINT SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _HintSheet extends StatelessWidget {
  final Level    level;
  final _Palette p;
  const _HintSheet({required this.level, required this.p});

  String _hint() {
    switch (level.tag.toLowerCase()) {
      case 'easy':
        return 'Start with the simplest possible approach, even if it\'s O(n²). '
            'Once it works, think about how to optimise with a hash map or two-pointer technique.';
      case 'medium':
        return 'Break the problem into smaller subproblems. Consider what data structure '
            'gives you O(1) lookups — a hash map or set is often key. '
            'Trace through the examples by hand first.';
      case 'hard':
        return 'Hard problems usually combine multiple techniques. Identify which algorithmic '
            'pattern applies: sliding window, monotonic stack, union-find, or DP. '
            'Draw the state transitions on paper before coding.';
      default:
        return 'This is the final boss — think carefully about time and space complexity. '
            'A brute-force won\'t pass the hidden tests. You need the optimal approach.';
    }
  }

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
      Text('💡', style: TextStyle(fontSize: 40.sp)),
      SizedBox(height: 10.h),
      Text('Hint', style: GoogleFonts.dmSerifDisplay(fontSize: 22.sp, color: p.text)),
      SizedBox(height: 8.h),
      Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(color: p.goldSoft, borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: p.gold.withOpacity(0.3))),
        child: Text(_hint(), textAlign: TextAlign.center,
            style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.6)),
      ),
      SizedBox(height: 22.h),
      GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Text('Got it', style: GoogleFonts.dmMono(
            fontSize: 13.sp, color: p.sub, fontWeight: FontWeight.w600)),
      ),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// VICTORY SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _VictorySheet extends StatefulWidget {
  final Level        level;
  final int          stars;
  final int          timeSecs;
  final _Palette     p;
  final VoidCallback onContinue;
  const _VictorySheet({required this.level, required this.stars, required this.timeSecs,
    required this.p, required this.onContinue});
  @override State<_VictorySheet> createState() => _VictorySheetState();
}
class _VictorySheetState extends State<_VictorySheet> with TickerProviderStateMixin {
  late final AnimationController _starCtrl;
  late final AnimationController _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _starCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();
    HapticFeedback.heavyImpact();
  }

  @override
  void dispose() { _starCtrl.dispose(); _confettiCtrl.dispose(); super.dispose(); }

  String get _timeLabel {
    final m = widget.timeSecs ~/ 60;
    final s = widget.timeSecs % 60;
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final size = MediaQuery.of(context).size;

    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 44.h),
      decoration: BoxDecoration(color: p.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32.r))),
      child: Stack(children: [
        // Confetti painter
        AnimatedBuilder(
          animation: _confettiCtrl,
          builder: (_, __) => CustomPaint(
            size: Size(size.width, 200.h),
            painter: _ConfettiPainter(_confettiCtrl.value),
          ),
        ),

        Column(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 40.w, height: 4.h,
              decoration: BoxDecoration(color: p.hint.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(99.r))),
          SizedBox(height: 24.h),

          // Trophy
          Text('🏆', style: TextStyle(fontSize: 58.sp)),
          SizedBox(height: 6.h),
          Text('Level Complete!',
              style: GoogleFonts.dmSerifDisplay(fontSize: 26.sp, color: p.text)),
          SizedBox(height: 4.h),
          Text(widget.level.title,
              style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub)),
          SizedBox(height: 20.h),

          // Stars
          Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (i) => AnimatedBuilder(
                animation: _starCtrl,
                builder: (_, __) {
                  final t = CurvedAnimation(parent: _starCtrl,
                      curve: Interval(i * 0.22, i * 0.22 + 0.5, curve: Curves.elasticOut)).value;
                  return Transform.scale(scale: t, child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 4.w),
                    child: Icon(
                      i < widget.stars ? Icons.star_rounded : Icons.star_outline_rounded,
                      size: 38.sp,
                      color: i < widget.stars ? p.gold : p.hint.withOpacity(0.3),
                    ),
                  ));
                },
              ))),

          SizedBox(height: 20.h),

          // Stats row
          Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            _StatPill(label: 'XP Earned', value: '+${widget.level.xpReward}', color: p.gold),
            SizedBox(width: 10.w),
            _StatPill(label: 'Time', value: _timeLabel, color: p.accent),
            SizedBox(width: 10.w),
            _StatPill(label: 'Stars', value: '${widget.stars}/3', color: p.win),
          ]),

          SizedBox(height: 28.h),

          // Continue button
          GestureDetector(
            onTap: widget.onContinue,
            child: Container(
              width: double.infinity, height: 56.h,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.lerp(p.accent, Colors.white, 0.1)!, p.accent],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(18.r),
                boxShadow: [BoxShadow(color: p.accent.withOpacity(0.40),
                    blurRadius: 20, offset: const Offset(0, 8))],
              ),
              child: Center(
                child: Text('Continue  →',
                    style: GoogleFonts.dmMono(fontSize: 15.sp,
                        color: Colors.white, fontWeight: FontWeight.w800)),
              ),
            ),
          ),
        ]),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────
class _BattleBgPainter extends CustomPainter {
  final double t; final Color accent; final bool isDark;
  const _BattleBgPainter(this.t, this.accent, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final d   = math.sin(t * math.pi) * 30;
    final mul = isDark ? 1.2 : 0.5;
    _blob(canvas, Offset(size.width * 0.85 + d, size.height * 0.08),
        size.width * 0.55, accent.withOpacity(0.10 * mul));
    _blob(canvas, Offset(size.width * 0.10, size.height * 0.50 + d * 0.6),
        size.width * 0.45, accent.withOpacity(0.06 * mul));
    if (isDark) {
      final rng = math.Random(55);
      for (var i = 0; i < 60; i++) {
        final op = (0.08 + rng.nextDouble() * 0.35
            + math.sin(t * math.pi * 2 + i) * 0.12).clamp(0.0, 0.6);
        canvas.drawCircle(
          Offset(rng.nextDouble() * size.width, rng.nextDouble() * size.height),
          rng.nextDouble() * 1.1 + 0.1,
          Paint()..color = Colors.white.withOpacity(op),
        );
      }
    }
  }

  void _blob(Canvas c, Offset centre, double r, Color color) =>
      c.drawCircle(centre, r, Paint()
        ..shader = RadialGradient(colors: [color, Colors.transparent])
            .createShader(Rect.fromCircle(center: centre, radius: r)));

  @override bool shouldRepaint(covariant _BattleBgPainter o) => o.t != t;
}

class _ConfettiPainter extends CustomPainter {
  final double t;
  const _ConfettiPainter(this.t);

  static final _rng = math.Random(99);
  static final _colors = [
    const Color(0xFF9D8FF7), const Color(0xFF3DD68C),
    const Color(0xFFFFB82E), const Color(0xFFFF6B6B),
    const Color(0xFF4FC995), const Color(0xFFE8A83E),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final rng = math.Random(99);
    for (var i = 0; i < 48; i++) {
      final x    = rng.nextDouble() * size.width;
      final yBase = rng.nextDouble() * size.height;
      final dy    = t * size.height * (0.6 + rng.nextDouble() * 0.6);
      final y     = (yBase + dy) % size.height;
      final op    = (1.0 - t * 0.8).clamp(0.0, 1.0);
      final rot   = t * math.pi * 4 * (rng.nextBool() ? 1 : -1);
      final color = _colors[i % _colors.length].withOpacity(op);
      final w     = 5.0 + rng.nextDouble() * 5;
      final h     = 3.0 + rng.nextDouble() * 3;

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(rot);
      canvas.drawRRect(
        RRect.fromRectAndRadius(Rect.fromCenter(center: Offset.zero, width: w, height: h),
            const Radius.circular(2)),
        Paint()..color = color,
      );
      canvas.restore();
    }
  }

  @override bool shouldRepaint(covariant _ConfettiPainter o) => o.t != t;
}

// ─────────────────────────────────────────────────────────────────────────────
// SMALL WIDGETS
// ─────────────────────────────────────────────────────────────────────────────
class _ResultDot extends StatelessWidget {
  final List<_TestResult> results;
  const _ResultDot({required this.results});
  @override
  Widget build(BuildContext context) {
    final allPassed = results.every((r) => r.passed);
    return Container(
      width: 7.w, height: 7.w,
      decoration: BoxDecoration(
        color: allPassed ? const Color(0xFF3DD68C) : const Color(0xFFFF6B6B),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _TrafficLight extends StatelessWidget {
  final Color color;
  const _TrafficLight(this.color);
  @override
  Widget build(BuildContext context) => Container(
    width: 9.w, height: 9.w,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}

class _Pill extends StatelessWidget {
  final String label; final Color color;
  const _Pill({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 4.h),
    decoration: BoxDecoration(color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: color.withOpacity(0.28))),
    child: Text(label, style: GoogleFonts.dmMono(
        fontSize: 9.5.sp, color: color, fontWeight: FontWeight.w700)),
  );
}

class _ExRow extends StatelessWidget {
  final String label, value; final Color color; final _Palette p;
  const _ExRow({required this.label, required this.value,
    required this.color, required this.p});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      SizedBox(width: 62.w,
          child: Text(label, style: GoogleFonts.dmMono(
              fontSize: 9.5.sp, color: p.hint, fontWeight: FontWeight.w600))),
      Expanded(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(color: color.withOpacity(0.08),
              borderRadius: BorderRadius.circular(7.r),
              border: Border.all(color: color.withOpacity(0.18))),
          child: Text(value, style: GoogleFonts.dmMono(
              fontSize: 10.sp, color: color, fontWeight: FontWeight.w600)),
        ),
      ),
    ],
  );
}

class _StatPill extends StatelessWidget {
  final String label, value; final Color color;
  const _StatPill({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
    decoration: BoxDecoration(
      color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: color.withOpacity(0.28)),
    ),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Text(value, style: GoogleFonts.dmMono(fontSize: 15.sp,
          color: color, fontWeight: FontWeight.w800)),
      SizedBox(height: 2.h),
      Text(label, style: GoogleFonts.dmMono(fontSize: 8.sp,
          color: color.withOpacity(0.7), fontWeight: FontWeight.w600)),
    ]),
  );
}

class _BarButton extends StatelessWidget {
  final String       label;
  final IconData     icon;
  final Color        color;
  final bool         loading;
  final AnimationController runCtrl;
  final VoidCallback? onTap;
  const _BarButton({required this.label, required this.icon, required this.color,
    required this.loading, required this.runCtrl, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 44.h,
      decoration: BoxDecoration(
        color: onTap != null ? color.withOpacity(0.15) : color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: onTap != null
            ? color.withOpacity(0.4) : color.withOpacity(0.15)),
      ),
      child: Center(
        child: loading
            ? AnimatedBuilder(
          animation: runCtrl,
          builder: (_, __) => SizedBox(
            width: 16.w, height: 16.w,
            child: CircularProgressIndicator(
              value: null, strokeWidth: 2,
              color: color,
            ),
          ),
        )
            : Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 15.sp, color: color),
          SizedBox(width: 5.w),
          Text(label, style: GoogleFonts.dmMono(fontSize: 11.sp,
              color: color, fontWeight: FontWeight.w700)),
        ]),
      ),
    ),
  );
}