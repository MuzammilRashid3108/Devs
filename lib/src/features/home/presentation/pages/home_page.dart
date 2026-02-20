import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ADAPTIVE PALETTE
// Resolves light or dark tokens based on system brightness.
//
// Usage anywhere in the widget tree:
//   final p = Palette.of(context);
//   color: p.accent
// ─────────────────────────────────────────────────────────────────────────────
class Palette {
  final Color bg, surface, surface2;
  final Color accent, accentSoft, accentMid;
  final Color win, winSoft;
  final Color loss, lossSoft;
  final Color gold, goldSoft;
  final Color text, sub, hint;

  const Palette({
    required this.bg,       required this.surface,    required this.surface2,
    required this.accent,   required this.accentSoft, required this.accentMid,
    required this.win,      required this.winSoft,
    required this.loss,     required this.lossSoft,
    required this.gold,     required this.goldSoft,
    required this.text,     required this.sub,        required this.hint,
  });

  // ── Light ──────────────────────────────────────────────────────────────────
  static const _light = Palette(
    bg:         Color(0xFFF6F4F9),
    surface:    Color(0xFFFFFFFF),
    surface2:   Color(0xFFF0EDF6),
    accent:     Color(0xFF7C6EF5),
    accentSoft: Color(0xFFEBE8FD),
    accentMid:  Color(0xFFBBB4F9),
    win:        Color(0xFF4FC995),
    winSoft:    Color(0xFFDFF5EC),
    loss:       Color(0xFFF47B7B),
    lossSoft:   Color(0xFFFDECEC),
    gold:       Color(0xFFE8A83E),
    goldSoft:   Color(0xFFFDF3E1),
    text:       Color(0xFF1C1830),
    sub:        Color(0xFF8A85A0),
    hint:       Color(0xFFB8B4CC),
  );

  // ── Dark ───────────────────────────────────────────────────────────────────
  static const _dark = Palette(
    bg:         Color(0xFF0E0C15),
    surface:    Color(0xFF16131F),
    surface2:   Color(0xFF1E1A2E),
    accent:     Color(0xFF9D8FF7),
    accentSoft: Color(0xFF1E1A38),
    accentMid:  Color(0xFF4A3F8A),
    win:        Color(0xFF3DD68C),
    winSoft:    Color(0xFF0D2B1F),
    loss:       Color(0xFFFF6B6B),
    lossSoft:   Color(0xFF2B1212),
    gold:       Color(0xFFFFB82E),
    goldSoft:   Color(0xFF2A1F07),
    text:       Color(0xFFF0EDF9),
    sub:        Color(0xFF8A85A0),
    hint:       Color(0xFF3E3A52),
  );

  /// Returns the correct palette for the current system brightness.
  static Palette of(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? _dark : _light;
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
const _skillOptions = [
  ('🐍', 'Python'),   ('⚙️', 'C++'),       ('☕', 'Java'),
  ('🌐', 'JS'),       ('🎯', 'Dart'),       ('🦀', 'Rust'),
  ('📊', 'ML / AI'),  ('🗃️', 'SQL'),        ('☁️', 'Cloud'),
  ('🔐', 'Security'), ('📱', 'Mobile'),     ('🎮', 'Game Dev'),
];

const _rankOptions = [
  ('🥉', 'Bronze',      Color(0xFFCD7F32)),
  ('🥈', 'Silver',      Color(0xFFA8A8A8)),
  ('🥇', 'Gold',        Color(0xFFE8A83E)),
  ('💎', 'Diamond',     Color(0xFF74D7F7)),
  ('👑', 'Grandmaster', Color(0xFF9D8FF7)),
];

const _avatarEmojis = ['🧑‍💻', '🦸', '🧙', '🥷', '👾', '🤖', '🦄', '🐉'];

// ─────────────────────────────────────────────────────────────────────────────
// PROFILE BUILDER PAGE
// ─────────────────────────────────────────────────────────────────────────────
class ProfileBuilderPage extends StatefulWidget {
  const ProfileBuilderPage({super.key});

  @override
  State<ProfileBuilderPage> createState() => _ProfileBuilderPageState();
}

class _ProfileBuilderPageState extends State<ProfileBuilderPage>
    with TickerProviderStateMixin {

  late final AnimationController _meshCtrl;
  late final AnimationController _stepCtrl;
  late final AnimationController _entryCtrl;
  late final Animation<double>   _meshAnim;

  int    _step          = 0;
  String _selectedEmoji = '🧑‍💻';
  int    _selectedRank  = 4;

  final _usernameCtrl   = TextEditingController();
  final _taglineCtrl    = TextEditingController();
  final _focusUser      = FocusNode();
  final _focusTag       = FocusNode();
  final Set<String> _selectedSkills = {};

  late List<AnimationController> _itemCtrls;

  @override
  void initState() {
    super.initState();
    _meshCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 8))
      ..repeat(reverse: true);
    _stepCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _entryCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..forward();
    _meshAnim = CurvedAnimation(parent: _meshCtrl, curve: Curves.easeInOut);
    _itemCtrls = List.generate(
      _skillOptions.length,
          (_) => AnimationController(vsync: this, duration: const Duration(milliseconds: 350)),
    );
  }

  @override
  void dispose() {
    _meshCtrl.dispose();   _stepCtrl.dispose();   _entryCtrl.dispose();
    _usernameCtrl.dispose(); _taglineCtrl.dispose();
    _focusUser.dispose();  _focusTag.dispose();
    for (final c in _itemCtrls) c.dispose();
    super.dispose();
  }

  Future<void> _next() async {
    HapticFeedback.lightImpact();
    await _stepCtrl.forward();
    setState(() => _step++);
    _stepCtrl.reset();
    if (_step == 1) {
      for (var i = 0; i < _itemCtrls.length; i++) {
        Future.delayed(Duration(milliseconds: 40 * i),
                () { if (mounted) _itemCtrls[i].forward(); });
      }
    }
  }

  Future<void> _back() async {
    HapticFeedback.selectionClick();
    setState(() => _step--);
    if (_step == 1) for (final c in _itemCtrls) c.reset();
  }

  bool get _canProceed => switch (_step) {
    0 => _usernameCtrl.text.trim().isNotEmpty,
    1 => _selectedSkills.isNotEmpty,
    _ => true,
  };

  @override
  Widget build(BuildContext context) {
    // Re-resolve on every build so hot-reloads + system changes work instantly.
    final p      = Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: p.bg,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          // Animated background mesh (opacity scales with theme)
          AnimatedBuilder(
            animation: _meshAnim,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: BuilderMeshPainter(_meshAnim.value, isDark),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                _buildTopBar(p),
                _buildStepDots(p),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 420),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0.06, 0), end: Offset.zero,
                        ).animate(CurvedAnimation(parent: anim, curve: Curves.easeOutCubic)),
                        child: child,
                      ),
                    ),
                    child: KeyedSubtree(
                      key: ValueKey(_step),
                      child: _buildStepContent(p),
                    ),
                  ),
                ),
                if (_step < 3) _buildBottomActions(p),
                SizedBox(height: 24.h),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Top Bar ─────────────────────────────────────────────────────────────────
  Widget _buildTopBar(Palette p) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 8.h, 20.w, 0),
    child: Row(
      children: [
        if (_step > 0 && _step < 3)
          GestureDetector(
            onTap: _back,
            child: Container(
              width: 38.w, height: 38.w,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10, offset: const Offset(0, 3),
                )],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, size: 15.sp, color: p.text),
            ),
          )
        else
          SizedBox(width: 38.w),
        Expanded(
          child: Center(
            child: Column(children: [
              Text(_stepTitle(),
                  style: GoogleFonts.dmSerifDisplay(fontSize: 22.sp, color: p.text)),
              Text('Step ${_step + 1} of 4',
                  style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub)),
            ]),
          ),
        ),
        SizedBox(width: 38.w),
      ],
    ),
  );

  String _stepTitle() => switch (_step) {
    0 => 'Identity', 1 => 'Skill Matrix', 2 => 'Choose Rank', 3 => 'Profile Ready', _ => '',
  };

  // ── Step Dots ───────────────────────────────────────────────────────────────
  Widget _buildStepDots(Palette p) => Padding(
    padding: EdgeInsets.symmetric(vertical: 16.h),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (i) {
        final active = i == _step;
        final done   = i < _step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          width: active ? 28.w : 8.w,
          height: 8.w,
          decoration: BoxDecoration(
            color: done ? p.win : active ? p.accent : p.hint.withOpacity(0.4),
            borderRadius: BorderRadius.circular(99.r),
          ),
          child: done ? Icon(Icons.check_rounded, size: 6.sp, color: Colors.white) : null,
        );
      }),
    ),
  );

  // ── Step Router ─────────────────────────────────────────────────────────────
  Widget _buildStepContent(Palette p) => switch (_step) {
    0 => _StepIdentity(
        usernameCtrl: _usernameCtrl, taglineCtrl: _taglineCtrl,
        focusUser: _focusUser, focusTag: _focusTag,
        selectedEmoji: _selectedEmoji,
        onEmojiChanged: (e) => setState(() => _selectedEmoji = e),
        onTyping: (_) {},
        entryCtrl: _entryCtrl, palette: p),
    1 => _StepSkills(
        selectedSkills: _selectedSkills,
        onToggle: (s) => setState(() {
          if (_selectedSkills.contains(s)) _selectedSkills.remove(s);
          else _selectedSkills.add(s);
        }),
        itemCtrls: _itemCtrls, palette: p),
    2 => _StepRank(
        selectedRank: _selectedRank,
        onRankChanged: (r) => setState(() => _selectedRank = r),
        palette: p),
    3 => _StepDone(
        emoji: _selectedEmoji,
        username: _usernameCtrl.text.trim(),
        tagline:  _taglineCtrl.text.trim(),
        skills: _selectedSkills.toList(),
        rank: _rankOptions[_selectedRank],
        palette: p),
    _ => const SizedBox(),
  };

  // ── Bottom Actions ──────────────────────────────────────────────────────────
  Widget _buildBottomActions(Palette p) => Padding(
    padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 0),
    child: AnimatedBuilder(
      animation: _entryCtrl,
      builder: (_, child) => FadeTransition(
        opacity: CurvedAnimation(
            parent: _entryCtrl, curve: const Interval(0.5, 1.0, curve: Curves.easeOut)),
        child: child,
      ),
      child: GlowButton(
        label:   _step == 2 ? 'Build My Profile ✦' : 'Continue',
        enabled: _canProceed,
        onTap:   _canProceed ? _next : null,
        palette: p,
      ),
    ),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 0 — IDENTITY
// ─────────────────────────────────────────────────────────────────────────────
class _StepIdentity extends StatelessWidget {
  final TextEditingController usernameCtrl, taglineCtrl;
  final FocusNode focusUser, focusTag;
  final String selectedEmoji;
  final ValueChanged<String> onEmojiChanged;
  final ValueChanged<bool>   onTyping;
  final AnimationController  entryCtrl;
  final Palette palette;

  const _StepIdentity({
    required this.usernameCtrl, required this.taglineCtrl,
    required this.focusUser,    required this.focusTag,
    required this.selectedEmoji, required this.onEmojiChanged,
    required this.onTyping,      required this.entryCtrl,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(children: [
        SizedBox(height: 8.h),
        FadeSlide(ctrl: entryCtrl, delay: 0.00,
            child: _AvatarPicker(selected: selectedEmoji, onChanged: onEmojiChanged, palette: p)),
        SizedBox(height: 28.h),
        FadeSlide(ctrl: entryCtrl, delay: 0.10,
            child: _BuilderField(
              controller: usernameCtrl, focusNode: focusUser,
              label: 'Username', hint: '@bytesl4yer',
              icon: Icons.alternate_email_rounded,
              onChanged: (_) => onTyping(true),
              inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9_@]'))],
              palette: p,
            )),
        SizedBox(height: 14.h),
        FadeSlide(ctrl: entryCtrl, delay: 0.18,
            child: _BuilderField(
              controller: taglineCtrl, focusNode: focusTag,
              label: 'Battle Cry (optional)', hint: 'e.g. "I speak fluent Big-O"',
              icon: Icons.bolt_rounded, maxLines: 2, palette: p,
            )),
        SizedBox(height: 20.h),
        FadeSlide(ctrl: entryCtrl, delay: 0.26,
            child: _LivePreviewCard(
              emoji: selectedEmoji,
              usernameCtrl: usernameCtrl,
              taglineCtrl:  taglineCtrl,
              palette: p,
            )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 1 — SKILLS
// ─────────────────────────────────────────────────────────────────────────────
class _StepSkills extends StatelessWidget {
  final Set<String> selectedSkills;
  final ValueChanged<String> onToggle;
  final List<AnimationController> itemCtrls;
  final Palette palette;

  const _StepSkills({
    required this.selectedSkills, required this.onToggle,
    required this.itemCtrls,      required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(children: [
        SizedBox(height: 4.h),
        Text(
          'Pick the languages & domains\nyou actually enjoy fighting with.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.5),
        ),
        SizedBox(height: 24.h),
        Wrap(
          spacing: 10.w, runSpacing: 10.h, alignment: WrapAlignment.center,
          children: List.generate(_skillOptions.length, (i) {
            final skill    = _skillOptions[i];
            final selected = selectedSkills.contains(skill.$2);
            return AnimatedBuilder(
              animation: itemCtrls[i],
              builder: (_, child) => Transform.scale(
                scale: CurvedAnimation(parent: itemCtrls[i], curve: Curves.elasticOut).value,
                child: child,
              ),
              child: _SkillChip(
                emoji: skill.$1, label: skill.$2,
                selected: selected,
                onTap: () => onToggle(skill.$2),
                palette: p,
              ),
            );
          }),
        ),
        SizedBox(height: 20.h),
        if (selectedSkills.isNotEmpty)
          Text('${selectedSkills.length} selected',
              style: GoogleFonts.dmMono(
                  fontSize: 11.sp, color: p.accent, fontWeight: FontWeight.w600)),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 2 — RANK
// ─────────────────────────────────────────────────────────────────────────────
class _StepRank extends StatelessWidget {
  final int selectedRank;
  final ValueChanged<int> onRankChanged;
  final Palette palette;

  const _StepRank({
    required this.selectedRank, required this.onRankChanged, required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(children: [
        Text(
          'Where are you starting?\nBe honest — you can always climb.',
          textAlign: TextAlign.center,
          style: GoogleFonts.dmMono(fontSize: 12.sp, color: p.sub, height: 1.5),
        ),
        SizedBox(height: 24.h),
        ...List.generate(_rankOptions.length, (i) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _RankTile(
            emoji: _rankOptions[i].$1, label: _rankOptions[i].$2,
            color: _rankOptions[i].$3, selected: i == selectedRank,
            onTap: () => onRankChanged(i), palette: p,
          ),
        )),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STEP 3 — DONE
// ─────────────────────────────────────────────────────────────────────────────
class _StepDone extends StatefulWidget {
  final String emoji, username, tagline;
  final List<String> skills;
  final (String, String, Color) rank;
  final Palette palette;

  const _StepDone({
    required this.emoji, required this.username, required this.tagline,
    required this.skills, required this.rank, required this.palette,
  });

  @override
  State<_StepDone> createState() => _StepDoneState();
}

class _StepDoneState extends State<_StepDone> with TickerProviderStateMixin {
  late final AnimationController _popCtrl, _cardCtrl, _confettiCtrl;

  @override
  void initState() {
    super.initState();
    _popCtrl      = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _cardCtrl     = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _confettiCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1800));
    Future.delayed(const Duration(milliseconds: 100), () {
      if (!mounted) return;
      _popCtrl.forward();
      _confettiCtrl.forward();
      Future.delayed(const Duration(milliseconds: 300), () { if (mounted) _cardCtrl.forward(); });
    });
  }

  @override
  void dispose() {
    _popCtrl.dispose(); _cardCtrl.dispose(); _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Stack(children: [
      AnimatedBuilder(
        animation: _confettiCtrl,
        builder: (_, __) => CustomPaint(
          size: MediaQuery.of(context).size,
          painter: _ConfettiPainter(_confettiCtrl.value),
        ),
      ),
      SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(children: [
          SizedBox(height: 12.h),

          // ── Avatar pop ───────────────────────────────────────────────────
          ScaleTransition(
            scale: CurvedAnimation(parent: _popCtrl, curve: Curves.elasticOut),
            child: FadeTransition(
              opacity: _popCtrl,
              child: Container(
                width: 100.w, height: 100.w,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [widget.rank.$3.withOpacity(0.6), widget.rank.$3],
                  ),
                  borderRadius: BorderRadius.circular(30.r),
                  boxShadow: [BoxShadow(
                    color: widget.rank.$3.withOpacity(0.4),
                    blurRadius: 28, offset: const Offset(0, 10),
                  )],
                ),
                child: Center(child: Text(widget.emoji, style: TextStyle(fontSize: 44.sp))),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          FadeTransition(
            opacity: _popCtrl,
            child: Column(children: [
              Text(
                widget.username.isNotEmpty ? widget.username : 'ByteSlayer',
                style: GoogleFonts.dmSerifDisplay(fontSize: 28.sp, color: p.text),
              ),
              if (widget.tagline.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Text('"${widget.tagline}"',
                    style: GoogleFonts.dmMono(
                        fontSize: 11.sp, color: p.sub, fontStyle: FontStyle.italic)),
              ],
              SizedBox(height: 10.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: widget.rank.$3.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10.r),
                  border: Border.all(color: widget.rank.$3.withOpacity(0.35)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(widget.rank.$1, style: TextStyle(fontSize: 13.sp)),
                  SizedBox(width: 6.w),
                  Text(widget.rank.$2,
                      style: GoogleFonts.dmMono(
                          fontSize: 11.sp, color: widget.rank.$3, fontWeight: FontWeight.w700)),
                ]),
              ),
            ]),
          ),

          SizedBox(height: 24.h),

          // ── Skills card ──────────────────────────────────────────────────
          SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero)
                .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic)),
            child: FadeTransition(
              opacity: _cardCtrl,
              child: Container(
                width: double.infinity, padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(24.r),
                  boxShadow: [BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 20, offset: const Offset(0, 6),
                  )],
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    Container(
                      width: 26.w, height: 26.w,
                      decoration: BoxDecoration(
                          color: p.accentSoft, borderRadius: BorderRadius.circular(8.r)),
                      child: Icon(Icons.code_rounded, size: 14.sp, color: p.accent),
                    ),
                    SizedBox(width: 8.w),
                    Text('Skills',
                        style: GoogleFonts.dmSerifDisplay(fontSize: 16.sp, color: p.text)),
                  ]),
                  SizedBox(height: 12.h),
                  Wrap(
                    spacing: 8.w, runSpacing: 8.h,
                    children: widget.skills.map((s) {
                      final opt = _skillOptions.firstWhere(
                              (o) => o.$2 == s, orElse: () => ('', s));
                      return Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
                        decoration: BoxDecoration(
                            color: p.accentSoft, borderRadius: BorderRadius.circular(8.r)),
                        child: Text('${opt.$1} $s',
                            style: GoogleFonts.dmMono(
                                fontSize: 10.sp, color: p.accent, fontWeight: FontWeight.w600)),
                      );
                    }).toList(),
                  ),
                ]),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
                .animate(CurvedAnimation(parent: _cardCtrl, curve: Curves.easeOutCubic)),
            child: FadeTransition(
              opacity: _cardCtrl,
              child: GlowButton(
                label: 'Enter the Arena 🏟️', enabled: true,
                onTap: () {
                  HapticFeedback.heavyImpact();
                  context.go('/level');
                  }, palette: p,
              ),
            ),
          ),

          SizedBox(height: 40.h),
        ]),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS  (all accept Palette)
// ─────────────────────────────────────────────────────────────────────────────

// ── Staggered fade + slide ────────────────────────────────────────────────────
class FadeSlide extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;
  const FadeSlide({required this.ctrl, required this.delay, required this.child});

  @override
  Widget build(BuildContext context) {
    final end   = (delay + 0.45).clamp(0.0, 1.0);
    final curve = CurvedAnimation(
        parent: ctrl, curve: Interval(delay, end, curve: Curves.easeOut));
    return FadeTransition(
      opacity: curve,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero).animate(curve),
        child: child,
      ),
    );
  }
}

// ── Avatar Picker ─────────────────────────────────────────────────────────────
class _AvatarPicker extends StatefulWidget {
  final String selected;
  final ValueChanged<String> onChanged;
  final Palette palette;
  const _AvatarPicker({required this.selected, required this.onChanged, required this.palette});

  @override
  State<_AvatarPicker> createState() => _AvatarPickerState();
}

class _AvatarPickerState extends State<_AvatarPicker> with SingleTickerProviderStateMixin {
  late final AnimationController _bounceCtrl;

  @override
  void initState() {
    super.initState();
    _bounceCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 500))
      ..forward();
  }
  @override
  void dispose() { _bounceCtrl.dispose(); super.dispose(); }

  void _pick(String e) {
    widget.onChanged(e);
    HapticFeedback.selectionClick();
    _bounceCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return Column(children: [
      ScaleTransition(
        scale: CurvedAnimation(parent: _bounceCtrl, curve: Curves.elasticOut),
        child: Container(
          width: 90.w, height: 90.w,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
            ),
            borderRadius: BorderRadius.circular(26.r),
            boxShadow: [BoxShadow(
                color: p.accent.withOpacity(0.4), blurRadius: 22, offset: const Offset(0, 8))],
          ),
          child: Center(child: Text(widget.selected, style: TextStyle(fontSize: 40.sp))),
        ),
      ),
      SizedBox(height: 14.h),
      Text('Choose your fighter',
          style: GoogleFonts.dmMono(fontSize: 10.sp, color: p.sub, letterSpacing: 0.5)),
      SizedBox(height: 10.h),
      Wrap(
        spacing: 10.w, runSpacing: 8.h, alignment: WrapAlignment.center,
        children: _avatarEmojis.map((e) {
          final sel = e == widget.selected;
          return GestureDetector(
            onTap: () => _pick(e),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46.w, height: 46.w,
              decoration: BoxDecoration(
                color: sel ? p.accentSoft : p.surface2,
                borderRadius: BorderRadius.circular(14.r),
                border: Border.all(color: sel ? p.accentMid : Colors.transparent, width: 2),
                boxShadow: sel
                    ? [BoxShadow(color: p.accent.withOpacity(0.2),
                    blurRadius: 10, offset: const Offset(0, 3))]
                    : [],
              ),
              child: Center(child: Text(e, style: TextStyle(fontSize: 22.sp))),
            ),
          );
        }).toList(),
      ),
    ]);
  }
}

// ── Text Field ────────────────────────────────────────────────────────────────
class _BuilderField extends StatefulWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final String label, hint;
  final IconData icon;
  final int maxLines;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Palette palette;

  const _BuilderField({
    required this.controller, required this.focusNode,
    required this.label,      required this.hint,
    required this.icon,       required this.palette,
    this.maxLines = 1, this.onChanged, this.inputFormatters,
  });

  @override
  State<_BuilderField> createState() => _BuilderFieldState();
}

class _BuilderFieldState extends State<_BuilderField> {
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    widget.focusNode.addListener(
            () => setState(() => _focused = widget.focusNode.hasFocus));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
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
              blurRadius: 12, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: widget.controller, focusNode: widget.focusNode,
          maxLines: widget.maxLines, onChanged: widget.onChanged,
          inputFormatters: widget.inputFormatters,
          style: GoogleFonts.dmMono(fontSize: 13.sp, color: p.text),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: GoogleFonts.dmMono(fontSize: 12.sp, color: p.hint),
            prefixIcon: Icon(widget.icon, size: 16.sp, color: _focused ? p.accent : p.hint),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 13.h),
          ),
        ),
      ),
    ]);
  }
}

// ── Live Preview Card ─────────────────────────────────────────────────────────
class _LivePreviewCard extends StatelessWidget {
  final String emoji;
  final TextEditingController usernameCtrl, taglineCtrl;
  final Palette palette;

  const _LivePreviewCard({
    required this.emoji,
    required this.usernameCtrl, required this.taglineCtrl,
    required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return ListenableBuilder(
      listenable: Listenable.merge([usernameCtrl, taglineCtrl]),
      builder: (_, __) {
        final name    = usernameCtrl.text.trim();
        final tagline = taglineCtrl.text.trim();
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: p.accentSoft,
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: p.accentMid.withOpacity(0.4)),
          ),
          child: Row(children: [
            Container(
              width: 50.w, height: 50.w,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF9C91F8), Color(0xFF7C6EF5)],
                  begin: Alignment.topLeft, end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15.r),
              ),
              child: Center(child: Text(emoji, style: TextStyle(fontSize: 22.sp))),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  name.isNotEmpty ? name : 'Your handle...',
                  style: GoogleFonts.dmSerifDisplay(
                      fontSize: 18.sp, color: name.isNotEmpty ? p.text : p.hint),
                ),
                if (tagline.isNotEmpty)
                  Text('"$tagline"',
                      style: GoogleFonts.dmMono(
                          fontSize: 10.sp, color: p.sub, fontStyle: FontStyle.italic)),
                SizedBox(height: 4.h),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                  decoration: BoxDecoration(
                      color: p.goldSoft, borderRadius: BorderRadius.circular(6.r)),
                  child: Text('👑 Grandmaster',
                      style: GoogleFonts.dmMono(
                          fontSize: 9.sp, color: p.gold, fontWeight: FontWeight.w600)),
                ),
              ]),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 4.h),
              decoration: BoxDecoration(color: p.surface, borderRadius: BorderRadius.circular(8.r)),
              child: Text('Lv.1',
                  style: GoogleFonts.dmMono(fontSize: 9.sp, color: p.accent, fontWeight: FontWeight.w700)),
            ),
          ]),
        );
      },
    );
  }
}

// ── Skill Chip ────────────────────────────────────────────────────────────────
class _SkillChip extends StatelessWidget {
  final String emoji, label;
  final bool selected;
  final VoidCallback onTap;
  final Palette palette;

  const _SkillChip({
    required this.emoji, required this.label,
    required this.selected, required this.onTap, required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: selected ? p.accent : p.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? p.accent : p.hint.withOpacity(0.3),
            width: selected ? 0 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: p.accent.withOpacity(0.3),
              blurRadius: 10, offset: const Offset(0, 4))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 6, offset: const Offset(0, 2))],
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(emoji, style: TextStyle(fontSize: 14.sp)),
          SizedBox(width: 6.w),
          Text(label,
              style: GoogleFonts.dmMono(
                fontSize: 11.sp,
                color: selected ? Colors.white : p.text,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              )),
          if (selected) ...[
            SizedBox(width: 6.w),
            Icon(Icons.check_rounded, size: 12.sp, color: Colors.white),
          ],
        ]),
      ),
    );
  }
}

// ── Rank Tile ─────────────────────────────────────────────────────────────────
class _RankTile extends StatelessWidget {
  final String emoji, label;
  final Color color;
  final bool selected;
  final VoidCallback onTap;
  final Palette palette;

  const _RankTile({
    required this.emoji,  required this.label,
    required this.color,  required this.selected,
    required this.onTap,  required this.palette,
  });

  @override
  Widget build(BuildContext context) {
    final p = palette;
    return GestureDetector(
      onTap: () { HapticFeedback.selectionClick(); onTap(); },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
        decoration: BoxDecoration(
          color: selected ? color.withOpacity(0.1) : p.surface,
          borderRadius: BorderRadius.circular(18.r),
          border: Border.all(
            color: selected ? color.withOpacity(0.5) : p.hint.withOpacity(0.2),
            width: selected ? 1.5 : 1,
          ),
          boxShadow: selected
              ? [BoxShadow(color: color.withOpacity(0.2),
              blurRadius: 14, offset: const Offset(0, 5))]
              : [BoxShadow(color: Colors.black.withOpacity(0.05),
              blurRadius: 8, offset: const Offset(0, 3))],
        ),
        child: Row(children: [
          Container(
            width: 44.w, height: 44.w,
            decoration: BoxDecoration(
                color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14.r)),
            child: Center(child: Text(emoji, style: TextStyle(fontSize: 22.sp))),
          ),
          SizedBox(width: 14.w),
          Expanded(
            child: Text(label,
                style: GoogleFonts.dmSerifDisplay(
                    fontSize: 20.sp, color: selected ? color : p.text)),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 22.w, height: 22.w,
            decoration: BoxDecoration(
              color: selected ? color : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(
                  color: selected ? color : p.hint.withOpacity(0.4), width: 1.5),
            ),
            child: selected
                ? Icon(Icons.check_rounded, size: 12.sp, color: Colors.white)
                : null,
          ),
        ]),
      ),
    );
  }
}

// ── Glow Button ───────────────────────────────────────────────────────────────
class GlowButton extends StatefulWidget {
  final String label;
  final bool enabled;
  final VoidCallback? onTap;
  final Palette palette;

  const GlowButton({
    required this.label, required this.enabled,
    required this.palette, this.onTap,
  });

  @override
  State<GlowButton> createState() => GlowButtonState();
}

class GlowButtonState extends State<GlowButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pressCtrl;
  late final Animation<double>   _scaleAnim;

  @override
  void initState() {
    super.initState();
    _pressCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 120));
    _scaleAnim = Tween<double>(begin: 1.0, end: 0.96)
        .animate(CurvedAnimation(parent: _pressCtrl, curve: Curves.easeOut));
  }
  @override
  void dispose() { _pressCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = widget.palette;
    return GestureDetector(
      onTapDown: (_) { if (widget.enabled) _pressCtrl.forward(); },
      onTapUp:   (_) { _pressCtrl.reverse(); widget.onTap?.call(); },
      onTapCancel: () => _pressCtrl.reverse(),
      child: ScaleTransition(
        scale: _scaleAnim,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
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
                blurRadius: 18, offset: const Offset(0, 8))]
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
// PAINTERS
// ─────────────────────────────────────────────────────────────────────────────

/// Background mesh — more vivid in dark mode, subtler in light mode.
class BuilderMeshPainter extends CustomPainter {
  final double t;
  final bool isDark;
  const BuilderMeshPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final drift  = math.sin(t * math.pi) * 30;
    final mul    = isDark ? 1.6 : 1.0; // boost saturation on dark backgrounds

    _blob(canvas,
      center: Offset(size.width * 0.8 + drift, size.height * 0.1),
      radius: size.width * 0.65,
      color: const Color(0xFF7C6EF5).withOpacity(0.13 * mul),
    );
    _blob(canvas,
      center: Offset(size.width * 0.1 - drift * 0.5, size.height * 0.85),
      radius: size.width * 0.55,
      color: const Color(0xFF3DD68C).withOpacity(0.09 * mul),
    );
    _blob(canvas,
      center: Offset(size.width * 0.5, size.height * 0.5 + drift),
      radius: size.width * 0.4,
      color: const Color(0xFFE8A83E).withOpacity(0.07 * mul),
    );
  }

  void _blob(Canvas canvas,
      {required Offset center, required double radius, required Color color}) {
    canvas.drawCircle(center, radius, Paint()
      ..shader = RadialGradient(colors: [color, Colors.transparent])
          .createShader(Rect.fromCircle(center: center, radius: radius)));
  }

  @override
  bool shouldRepaint(covariant BuilderMeshPainter old) =>
      old.t != t || old.isDark != isDark;
}

/// Confetti — uses the brighter dark-mode accent colors so it pops on both themes.
class _ConfettiPainter extends CustomPainter {
  final double progress;

  static final _rng       = math.Random(42);
  static final _particles = List.generate(60, (i) => (
  x:     _rng.nextDouble(),
  y:     _rng.nextDouble() * -0.3,
  speed: 0.4 + _rng.nextDouble() * 0.6,
  size:  4.0 + _rng.nextDouble() * 6,
  color: const [
    Color(0xFF9D8FF7), // accent
    Color(0xFF3DD68C), // win
    Color(0xFFFFB82E), // gold
    Color(0xFFFF6B6B), // loss
    Color(0xFF74D7F7), // diamond
  ][i % 5],
  angle: _rng.nextDouble() * math.pi * 2,
  spin:  (_rng.nextDouble() - 0.5) * 8,
  ));

  const _ConfettiPainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    for (final p in _particles) {
      final py    = (p.y + progress * p.speed * 1.5).clamp(0.0, 1.2);
      final px    = p.x + math.sin(progress * p.speed * math.pi * 2) * 0.05;
      final alpha = ((1 - progress) * 255).toInt().clamp(0, 255);
      canvas.save();
      canvas.translate(px * size.width, py * size.height);
      canvas.rotate(p.angle + progress * p.spin);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size * 0.5),
          const Radius.circular(2),
        ),
        Paint()..color = p.color.withAlpha(alpha),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => old.progress != progress;
}