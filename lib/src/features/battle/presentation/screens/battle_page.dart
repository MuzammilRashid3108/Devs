import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/widgets/nav_bar.dart';

// ─────────────────────────────────────────────────────────────────────────────
// PALETTE
// ─────────────────────────────────────────────────────────────────────────────
class _Palette {
  final Color bg, surface, surface2;
  final Color accent, accentSoft, accentMid;
  final Color win, winSoft, loss, lossSoft, gold, goldSoft;
  final Color text, sub, hint;
  const _Palette({required this.bg,required this.surface,required this.surface2,required this.accent,required this.accentSoft,required this.accentMid,required this.win,required this.winSoft,required this.loss,required this.lossSoft,required this.gold,required this.goldSoft,required this.text,required this.sub,required this.hint});
  static const _light = _Palette(bg:Color(0xFFF0EDF9),surface:Color(0xFFFFFFFF),surface2:Color(0xFFE4E0F5),accent:Color(0xFF7C6EF5),accentSoft:Color(0xFFEBE8FD),accentMid:Color(0xFFBBB4F9),win:Color(0xFF4FC995),winSoft:Color(0xFFDFF5EC),loss:Color(0xFFF47B7B),lossSoft:Color(0xFFFDECEC),gold:Color(0xFFE8A83E),goldSoft:Color(0xFFFDF3E1),text:Color(0xFF1C1830),sub:Color(0xFF8A85A0),hint:Color(0xFFB8B4CC));
  static const _dark  = _Palette(bg:Color(0xFF080611),surface:Color(0xFF13101C),surface2:Color(0xFF1B1727),accent:Color(0xFF9D8FF7),accentSoft:Color(0xFF1E1A38),accentMid:Color(0xFF4A3F8A),win:Color(0xFF3DD68C),winSoft:Color(0xFF0D2B1F),loss:Color(0xFFFF6B6B),lossSoft:Color(0xFF2B1212),gold:Color(0xFFFFB82E),goldSoft:Color(0xFF2A1F07),text:Color(0xFFF0EDF9),sub:Color(0xFF8A85A0),hint:Color(0xFF2A2640));
  static _Palette of(BuildContext ctx) => Theme.of(ctx).brightness == Brightness.dark ? _dark : _light;
}

// ─────────────────────────────────────────────────────────────────────────────
// DATA
// ─────────────────────────────────────────────────────────────────────────────
const _modes = [
  (emoji:'⚔️',  title:'1v1 Duel',      sub:'Real-time coding battle',        color:Color(0xFFFF6B6B), players:'2'),
  (emoji:'👥',  title:'Squad War',     sub:'2v2 team elimination',           color:Color(0xFF9D8FF7), players:'4'),
  (emoji:'🎯',  title:'Blitz',         sub:'Solve 5 problems fastest',       color:Color(0xFFFFB82E), players:'∞'),
  (emoji:'🏆',  title:'Ranked',        sub:'Climb the global ladder',        color:Color(0xFF3DD68C), players:'2'),
];

const _openLobbies = [
  (name:'CodeNinja42',  rank:'Diamond',  emoji:'💎', rating:2140, diff:'Medium', problem:'Merge Intervals',    wait:'00:12'),
  (name:'algo_wizard',  rank:'Gold',     emoji:'🥇', rating:1870, diff:'Hard',   problem:'Segment Tree',       wait:'00:34'),
  (name:'Xeno_Dev',     rank:'Platinum', emoji:'🔷', rating:1995, diff:'Easy',   problem:'Two Sum',            wait:'01:02'),
  (name:'PixelCoder',   rank:'Silver',   emoji:'🥈', rating:1430, diff:'Medium', problem:'BFS Shortest Path',  wait:'00:08'),
];

// ─────────────────────────────────────────────────────────────────────────────
// BATTLE PAGE
// ─────────────────────────────────────────────────────────────────────────────
class BattlePage extends StatefulWidget {
  const BattlePage({super.key});
  @override State<BattlePage> createState() => _BattlePageState();
}

class _BattlePageState extends State<BattlePage> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl;
  late final AnimationController _entryCtrl;
  late final AnimationController _pulseCtrl;
  int _selectedMode = 0;

  @override
  void initState() {
    super.initState();
    _bgCtrl    = AnimationController(vsync:this, duration:const Duration(seconds:14))..repeat(reverse:true);
    _entryCtrl = AnimationController(vsync:this, duration:const Duration(milliseconds:1200))..forward();
    _pulseCtrl = AnimationController(vsync:this, duration:const Duration(milliseconds:1500))..repeat(reverse:true);
  }

  @override void dispose() { _bgCtrl.dispose(); _entryCtrl.dispose(); _pulseCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p = _Palette.of(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: p.bg,
      body: Stack(children: [
        AnimatedBuilder(animation:_bgCtrl, builder:(_,__)=>CustomPaint(size:size,
            painter:_StarfieldPainter(CurvedAnimation(parent:_bgCtrl,curve:Curves.easeInOut).value,isDark))),

        SafeArea(child: Column(children: [
          _buildHeader(p),
          Expanded(child: SingleChildScrollView(
            physics:const BouncingScrollPhysics(),
            padding: EdgeInsets.only(bottom:100.h),
            child: Column(children: [
              SizedBox(height:8.h),
              _buildModeSelector(p),
              SizedBox(height:20.h),
              _buildQuickMatchBtn(p),
              SizedBox(height:20.h),
              _buildOpenLobbies(p),
              SizedBox(height:20.h),
              _buildMyStats(p),
            ]),
          )),
        ])),

        Positioned(bottom:0, left:0, right:0, child: const AppNavBar(current: NavDest.battle)),
      ]),
    );
  }

  Widget _buildHeader(_Palette p) => Padding(
    padding:EdgeInsets.fromLTRB(18.w,10.h,18.w,0),
    child:Row(children:[
      Text('Battle Arena',style:GoogleFonts.dmSerifDisplay(fontSize:22.sp,color:p.text)),
      const Spacer(),
      _Chip(emoji:'⚔️',label:'Ranked',fg:p.loss,bg:p.lossSoft),
      SizedBox(width:7.w),
      _Chip(emoji:'🔥',label:'17',fg:p.gold,bg:p.goldSoft),
    ]),
  );

  Widget _buildModeSelector(_Palette p) {
    return Column(crossAxisAlignment:CrossAxisAlignment.start, children:[
      Padding(padding:EdgeInsets.symmetric(horizontal:18.w),
          child:Text('Choose Mode',style:GoogleFonts.dmSerifDisplay(fontSize:16.sp,color:p.sub))),
      SizedBox(height:10.h),
      SizedBox(height:120.h,
        child:ListView.separated(
          padding:EdgeInsets.symmetric(horizontal:18.w),
          scrollDirection:Axis.horizontal,
          separatorBuilder:(_,__)=>SizedBox(width:10.w),
          itemCount:_modes.length,
          itemBuilder:(ctx,i){
            final m = _modes[i];
            final sel = i == _selectedMode;
            return AnimatedBuilder(animation:_entryCtrl, builder:(_,child){
              final t = CurvedAnimation(parent:_entryCtrl,
                  curve:Interval(i*0.08,i*0.08+0.5,curve:Curves.elasticOut)).value;
              return Transform.scale(scale:t,child:child);
            },
                child:GestureDetector(
                  onTap:(){ HapticFeedback.lightImpact(); setState(()=>_selectedMode=i); },
                  child:AnimatedContainer(
                    duration:const Duration(milliseconds:200),
                    width:130.w,
                    padding:EdgeInsets.all(14.w),
                    decoration:BoxDecoration(
                      color: sel ? m.color.withOpacity(0.15) : p.surface,
                      borderRadius:BorderRadius.circular(18.r),
                      border:Border.all(color: sel ? m.color.withOpacity(0.6) : p.hint.withOpacity(0.15),
                          width: sel ? 1.5 : 1),
                      boxShadow:[BoxShadow(color: sel ? m.color.withOpacity(0.18) : Colors.black.withOpacity(0.06),
                          blurRadius:14,offset:const Offset(0,4))],
                    ),
                    child:Column(crossAxisAlignment:CrossAxisAlignment.start,mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                      Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children:[
                        Text(m.emoji,style:TextStyle(fontSize:22.sp)),
                        Container(padding:EdgeInsets.symmetric(horizontal:5.w,vertical:2.h),
                            decoration:BoxDecoration(color:m.color.withOpacity(0.15),borderRadius:BorderRadius.circular(6.r)),
                            child:Text('${m.players}P',style:GoogleFonts.dmMono(fontSize:7.sp,color:m.color,fontWeight:FontWeight.w700))),
                      ]),
                      Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                        Text(m.title,style:GoogleFonts.dmSerifDisplay(fontSize:13.sp,color: sel ? m.color : p.text)),
                        SizedBox(height:2.h),
                        Text(m.sub,style:GoogleFonts.dmMono(fontSize:7.5.sp,color:p.sub),maxLines:2),
                      ]),
                    ]),
                  ),
                ));
          },
        ),
      ),
    ]);
  }

  Widget _buildQuickMatchBtn(_Palette p) {
    final mode = _modes[_selectedMode];
    return Padding(
      padding:EdgeInsets.symmetric(horizontal:18.w),
      child:AnimatedBuilder(animation:_pulseCtrl, builder:(_,__){
        final pulse = CurvedAnimation(parent:_pulseCtrl,curve:Curves.easeInOut).value;
        return GestureDetector(
          onTap:(){ HapticFeedback.heavyImpact(); _showMatchmakingSheet(context,p,mode.title); },
          child:Container(
            height:62.h,
            decoration:BoxDecoration(
              gradient:LinearGradient(colors:[mode.color, Color.lerp(mode.color,p.accent,0.4)!],
                  begin:Alignment.centerLeft,end:Alignment.centerRight),
              borderRadius:BorderRadius.circular(20.r),
              boxShadow:[
                BoxShadow(color:mode.color.withOpacity(0.25+pulse*0.15),blurRadius:20+pulse*8,offset:const Offset(0,4)),
              ],
            ),
            child:Row(mainAxisAlignment:MainAxisAlignment.center,children:[
              Text(mode.emoji,style:TextStyle(fontSize:22.sp)),
              SizedBox(width:10.w),
              Text('Quick Match — ${mode.title}',style:GoogleFonts.dmSerifDisplay(fontSize:15.sp,color:Colors.white)),
              SizedBox(width:8.w),
              Icon(Icons.arrow_forward_ios_rounded,size:12.sp,color:Colors.white.withOpacity(0.8)),
            ]),
          ),
        );
      }),
    );
  }

  Widget _buildOpenLobbies(_Palette p) {
    final diffColor = {'Easy':p.win,'Medium':p.gold,'Hard':p.loss};
    return Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
      Padding(padding:EdgeInsets.symmetric(horizontal:18.w),
          child:Row(children:[
            Text('Open Lobbies',style:GoogleFonts.dmSerifDisplay(fontSize:16.sp,color:p.text)),
            const Spacer(),
            Text('Refresh ↻',style:GoogleFonts.dmMono(fontSize:9.sp,color:p.accent,fontWeight:FontWeight.w700)),
          ])),
      SizedBox(height:10.h),
      ...List.generate(_openLobbies.length,(i){
        final l = _openLobbies[i];
        return AnimatedBuilder(animation:_entryCtrl, builder:(_,child){
          final t = CurvedAnimation(parent:_entryCtrl,
              curve:Interval(0.2+i*0.07,0.2+i*0.07+0.4,curve:Curves.easeOut)).value;
          return Opacity(opacity:t,
              child:Transform.translate(offset:Offset(0,20*(1-t)),child:child));
        },
            child:GestureDetector(
              onTap:(){ HapticFeedback.lightImpact(); _showJoinSheet(context,p,l.name,l.problem); },
              child:Container(
                margin:EdgeInsets.fromLTRB(18.w,0,18.w,8.h),
                padding:EdgeInsets.symmetric(horizontal:14.w,vertical:12.h),
                decoration:BoxDecoration(
                  color:p.surface,borderRadius:BorderRadius.circular(16.r),
                  border:Border.all(color:p.hint.withOpacity(0.12)),
                  boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05),blurRadius:10,offset:const Offset(0,3))],
                ),
                child:Row(children:[
                  Text(l.emoji,style:TextStyle(fontSize:22.sp)),
                  SizedBox(width:10.w),
                  Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                    Row(children:[
                      Text(l.name,style:GoogleFonts.dmMono(fontSize:11.sp,color:p.text,fontWeight:FontWeight.w700)),
                      SizedBox(width:6.w),
                      Container(padding:EdgeInsets.symmetric(horizontal:5.w,vertical:2.h),
                          decoration:BoxDecoration(color:p.accentSoft,borderRadius:BorderRadius.circular(5.r)),
                          child:Text(l.rank,style:GoogleFonts.dmMono(fontSize:7.sp,color:p.accent,fontWeight:FontWeight.w700))),
                    ]),
                    SizedBox(height:3.h),
                    Text(l.problem,style:GoogleFonts.dmMono(fontSize:9.5.sp,color:p.sub)),
                  ])),
                  Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                    Container(padding:EdgeInsets.symmetric(horizontal:6.w,vertical:2.h),
                        decoration:BoxDecoration(color:diffColor[l.diff]!.withOpacity(0.12),
                            borderRadius:BorderRadius.circular(5.r)),
                        child:Text(l.diff,style:GoogleFonts.dmMono(fontSize:7.sp,
                            color:diffColor[l.diff]!,fontWeight:FontWeight.w700))),
                    SizedBox(height:4.h),
                    Text('⏱ ${l.wait}',style:GoogleFonts.dmMono(fontSize:8.5.sp,color:p.hint)),
                    SizedBox(height:2.h),
                    Text('${l.rating} MMR',style:GoogleFonts.dmMono(fontSize:8.sp,color:p.gold,fontWeight:FontWeight.w600)),
                  ]),
                ]),
              ),
            ));
      }),
    ]);
  }

  Widget _buildMyStats(_Palette p) {
    final stats = [
      (label:'Battles',value:'248',color:p.accent),
      (label:'Won',value:'181',color:p.win),
      (label:'Lost',value:'67',color:p.loss),
      (label:'Win%',value:'73%',color:p.gold),
    ];
    return Container(
      margin:EdgeInsets.symmetric(horizontal:18.w),
      padding:EdgeInsets.all(16.w),
      decoration:BoxDecoration(
        color:p.surface,borderRadius:BorderRadius.circular(20.r),
        border:Border.all(color:p.hint.withOpacity(0.10)),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.06),blurRadius:14,offset:const Offset(0,4))],
      ),
      child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text('My Battle Stats',style:GoogleFonts.dmSerifDisplay(fontSize:15.sp,color:p.text)),
        SizedBox(height:12.h),
        Row(children:stats.map((s)=>Expanded(child:Column(children:[
          Text(s.value,style:GoogleFonts.dmSerifDisplay(fontSize:18.sp,color:s.color)),
          SizedBox(height:3.h),
          Text(s.label,style:GoogleFonts.dmMono(fontSize:8.sp,color:p.sub)),
        ]))).toList()),
        SizedBox(height:14.h),
        // Win-rate bar
        Row(children:[
          Expanded(flex:73,child:Container(height:6.h,
            decoration:BoxDecoration(color:p.win,borderRadius:BorderRadius.horizontal(left:Radius.circular(99.r))),)),
          Expanded(flex:27,child:Container(height:6.h,
            decoration:BoxDecoration(color:p.loss,borderRadius:BorderRadius.horizontal(right:Radius.circular(99.r))),)),
        ]),
      ]),
    );
  }

  Widget _buildNav(_Palette p) => Container(
    padding:EdgeInsets.only(top:12.h,bottom:26.h,left:18.w,right:18.w),
    decoration:BoxDecoration(
      color:p.surface.withOpacity(0.96),
      border:Border(top:BorderSide(color:p.hint.withOpacity(0.10))),
      boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.10),blurRadius:30,offset:const Offset(0,-4))],
    ),
    child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[
      _NavBtn(icon:Icons.flash_on_rounded,    label:'Battle',  active:true, p:p),
      _NavBtn(icon:Icons.emoji_events_rounded,label:'Rank',    active:false,p:p),
      _NavBtn(icon:Icons.home_rounded,        label:'Home',    active:false,p:p),
      _NavBtn(icon:Icons.person_rounded,      label:'Profile', active:false,p:p),
      _NavBtn(icon:Icons.settings_rounded,    label:'Settings',active:false,p:p),
    ]),
  );

  void _showMatchmakingSheet(BuildContext ctx, _Palette p, String mode) =>
      showModalBottomSheet(context:ctx,backgroundColor:Colors.transparent,isScrollControlled:true,
          builder:(_)=>_MatchmakingSheet(p:p,mode:mode));

  void _showJoinSheet(BuildContext ctx, _Palette p, String opp, String prob) =>
      showModalBottomSheet(context:ctx,backgroundColor:Colors.transparent,
          builder:(_)=>_JoinSheet(p:p,opponent:opp,problem:prob));
}

// ── Matchmaking sheet ────────────────────────────────────────────────────────
class _MatchmakingSheet extends StatefulWidget {
  final _Palette p; final String mode;
  const _MatchmakingSheet({required this.p,required this.mode});
  @override State<_MatchmakingSheet> createState()=>_MatchmakingSheetState();
}
class _MatchmakingSheetState extends State<_MatchmakingSheet> with SingleTickerProviderStateMixin {
  late final AnimationController _spin;
  @override void initState(){ super.initState(); _spin=AnimationController(vsync:this,duration:const Duration(seconds:2))..repeat(); }
  @override void dispose(){ _spin.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext ctx){
    final p=widget.p;
    return _Sheet(p:p,children:[
      AnimatedBuilder(animation:_spin,builder:(_,__)=>Transform.rotate(
          angle:_spin.value*2*math.pi,
          child:Text('⚔️',style:TextStyle(fontSize:44.sp)))),
      SizedBox(height:12.h),
      Text('Finding Opponent…',style:GoogleFonts.dmSerifDisplay(fontSize:22.sp,color:p.text)),
      SizedBox(height:6.h),
      Text('Mode: ${widget.mode}',style:GoogleFonts.dmMono(fontSize:11.sp,color:p.sub)),
      SizedBox(height:20.h),
      LinearProgressIndicator(backgroundColor:p.accentSoft,
          valueColor:AlwaysStoppedAnimation(p.accent),minHeight:4.h),
      SizedBox(height:24.h),
      _Btn(label:'Cancel',color:p.loss,onTap:()=>Navigator.pop(ctx)),
    ]);
  }
}

class _JoinSheet extends StatelessWidget {
  final _Palette p; final String opponent, problem;
  const _JoinSheet({required this.p,required this.opponent,required this.problem});
  @override Widget build(BuildContext ctx)=>_Sheet(p:p,children:[
    Text('⚔️',style:TextStyle(fontSize:44.sp)),
    SizedBox(height:10.h),
    Text('Challenge $opponent',style:GoogleFonts.dmSerifDisplay(fontSize:20.sp,color:p.text)),
    SizedBox(height:6.h),
    Text(problem,style:GoogleFonts.dmMono(fontSize:11.sp,color:p.sub)),
    SizedBox(height:24.h),
    _Btn(label:'⚔️  Join Battle',color:p.loss,onTap:(){HapticFeedback.heavyImpact();Navigator.pop(ctx);}),
    SizedBox(height:10.h),
    GestureDetector(onTap:()=>Navigator.pop(ctx),child:Text('Cancel',style:GoogleFonts.dmMono(fontSize:13.sp,color:p.sub))),
  ]);
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED SMALL WIDGETS + PAINTERS (same as map)
// ─────────────────────────────────────────────────────────────────────────────
class _Chip extends StatelessWidget {
  final String emoji,label; final Color fg,bg;
  const _Chip({required this.emoji,required this.label,required this.fg,required this.bg});
  @override Widget build(BuildContext context)=>Container(
    padding:EdgeInsets.symmetric(horizontal:10.w,vertical:6.h),
    decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(12.r),border:Border.all(color:fg.withOpacity(0.3))),
    child:Row(mainAxisSize:MainAxisSize.min,children:[
      Text(emoji,style:TextStyle(fontSize:11.sp)),SizedBox(width:5.w),
      Text(label,style:GoogleFonts.dmMono(fontSize:10.sp,color:fg,fontWeight:FontWeight.w700)),
    ]),
  );
}
class _NavBtn extends StatelessWidget {
  final IconData icon; final String label; final bool active; final _Palette p;
  const _NavBtn({required this.icon,required this.label,required this.active,required this.p});
  @override Widget build(BuildContext context)=>AnimatedContainer(
    duration:const Duration(milliseconds:250),
    padding:EdgeInsets.symmetric(horizontal:active?13.w:8.w,vertical:7.h),
    decoration:BoxDecoration(color:active?p.accentSoft:Colors.transparent,borderRadius:BorderRadius.circular(14.r)),
    child:Row(mainAxisSize:MainAxisSize.min,children:[
      Icon(icon,size:20.sp,color:active?p.accent:p.hint),
      if(active)...[SizedBox(width:5.w),Text(label,style:GoogleFonts.dmMono(fontSize:11.sp,color:p.accent,fontWeight:FontWeight.w700))],
    ]),
  );
}
class _Sheet extends StatelessWidget {
  final _Palette p; final List<Widget> children;
  const _Sheet({required this.p,required this.children});
  @override Widget build(BuildContext context)=>Container(
    padding:EdgeInsets.fromLTRB(24.w,20.h,24.w,40.h),
    decoration:BoxDecoration(color:p.surface,borderRadius:BorderRadius.vertical(top:Radius.circular(28.r))),
    child:Column(mainAxisSize:MainAxisSize.min,children:[
      Container(width:40.w,height:4.h,decoration:BoxDecoration(color:p.hint.withOpacity(0.35),borderRadius:BorderRadius.circular(99.r))),
      SizedBox(height:20.h),...children,
    ]),
  );
}
class _Btn extends StatelessWidget {
  final String label; final Color color; final VoidCallback onTap;
  const _Btn({required this.label,required this.color,required this.onTap});
  @override Widget build(BuildContext context)=>GestureDetector(
      onTap:onTap,child:Container(width:double.infinity,height:50.h,
      decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(16.r),border:Border.all(color:color.withOpacity(0.35))),
      child:Center(child:Text(label,style:GoogleFonts.dmMono(fontSize:13.sp,color:color,fontWeight:FontWeight.w700)))));
}
class _StarfieldPainter extends CustomPainter {
  final double t; final bool isDark;
  const _StarfieldPainter(this.t,this.isDark);
  @override void paint(Canvas canvas,Size size){
    final drift=math.sin(t*math.pi)*32; final mul=isDark?1.0:0.55;
    _blob(canvas,Offset(size.width*0.88+drift,size.height*0.10),size.width*0.65,const Color(0xFF7C6EF5).withOpacity(0.13*mul));
    _blob(canvas,Offset(size.width*0.07,size.height*0.55+drift*0.6),size.width*0.55,const Color(0xFF3DD68C).withOpacity(0.08*mul));
    _blob(canvas,Offset(size.width*0.60,size.height*0.78-drift*0.4),size.width*0.50,const Color(0xFFFF6B6B).withOpacity(0.07*mul));
    if(isDark){final rng=math.Random(42);for(var i=0;i<90;i++){final sx=rng.nextDouble()*size.width;final sy=rng.nextDouble()*size.height;final sr=rng.nextDouble()*1.3+0.2;final op=(0.15+rng.nextDouble()*0.5+math.sin(t*math.pi*2+i)*0.18).clamp(0.0,0.85);canvas.drawCircle(Offset(sx,sy),sr,Paint()..color=Colors.white.withOpacity(op));}}
  }
  void _blob(Canvas c,Offset centre,double r,Color color)=>c.drawCircle(centre,r,Paint()..shader=RadialGradient(colors:[color,Colors.transparent]).createShader(Rect.fromCircle(center:centre,radius:r)));
  @override bool shouldRepaint(covariant _StarfieldPainter o)=>o.t!=t||o.isDark!=isDark;
}