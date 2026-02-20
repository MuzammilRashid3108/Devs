import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/common/widgets/nav_bar.dart';

class _Palette {
  final Color bg,surface,surface2,accent,accentSoft,accentMid,win,winSoft,loss,lossSoft,gold,goldSoft,text,sub,hint;
  const _Palette({required this.bg,required this.surface,required this.surface2,required this.accent,required this.accentSoft,required this.accentMid,required this.win,required this.winSoft,required this.loss,required this.lossSoft,required this.gold,required this.goldSoft,required this.text,required this.sub,required this.hint});
  static const _light=_Palette(bg:Color(0xFFF0EDF9),surface:Color(0xFFFFFFFF),surface2:Color(0xFFE4E0F5),accent:Color(0xFF7C6EF5),accentSoft:Color(0xFFEBE8FD),accentMid:Color(0xFFBBB4F9),win:Color(0xFF4FC995),winSoft:Color(0xFFDFF5EC),loss:Color(0xFFF47B7B),lossSoft:Color(0xFFFDECEC),gold:Color(0xFFE8A83E),goldSoft:Color(0xFFFDF3E1),text:Color(0xFF1C1830),sub:Color(0xFF8A85A0),hint:Color(0xFFB8B4CC));
  static const _dark=_Palette(bg:Color(0xFF080611),surface:Color(0xFF13101C),surface2:Color(0xFF1B1727),accent:Color(0xFF9D8FF7),accentSoft:Color(0xFF1E1A38),accentMid:Color(0xFF4A3F8A),win:Color(0xFF3DD68C),winSoft:Color(0xFF0D2B1F),loss:Color(0xFFFF6B6B),lossSoft:Color(0xFF2B1212),gold:Color(0xFFFFB82E),goldSoft:Color(0xFF2A1F07),text:Color(0xFFF0EDF9),sub:Color(0xFF8A85A0),hint:Color(0xFF2A2640));
  static _Palette of(BuildContext ctx)=>Theme.of(ctx).brightness==Brightness.dark?_dark:_light;
}

const _tabs = ['Global','Friends','Country'];

const _players = [
  (rank:1, name:'NeuroHacker',  emoji:'🤖', rating:3210, badge:'👑', tier:'Grandmaster', delta:'+42'),
  (rank:2, name:'ByteKing',     emoji:'🐉', rating:3105, badge:'💎', tier:'Legend',      delta:'+18'),
  (rank:3, name:'algo_wizard',  emoji:'🦊', rating:2980, badge:'💎', tier:'Legend',      delta:'-5'),
  (rank:4, name:'ByteSlayer',   emoji:'🧑‍💻', rating:2140, badge:'💎', tier:'Diamond',    delta:'+27'), // ME
  (rank:5, name:'CodeNinja42',  emoji:'🥷', rating:2090, badge:'🔷', tier:'Platinum',    delta:'+11'),
  (rank:6, name:'Xeno_Dev',     emoji:'🌀', rating:1995, badge:'🔷', tier:'Platinum',    delta:'-3'),
  (rank:7, name:'PixelCoder',   emoji:'🎨', rating:1870, badge:'🥇', tier:'Gold',        delta:'+8'),
  (rank:8, name:'StackOverflow',emoji:'📚', rating:1730, badge:'🥇', tier:'Gold',        delta:'-14'),
  (rank:9, name:'PtrWizard',    emoji:'⚗️', rating:1640, badge:'🥈', tier:'Silver',      delta:'+3'),
  (rank:10,name:'HeapHero',     emoji:'🏛️', rating:1580, badge:'🥈', tier:'Silver',      delta:'+6'),
];

const _tierColors = {
  'Grandmaster': Color(0xFFFFB82E),
  'Legend':      Color(0xFF9D8FF7),
  'Diamond':     Color(0xFF3DD68C),
  'Platinum':    Color(0xFF60C8F5),
  'Gold':        Color(0xFFE8A83E),
  'Silver':      Color(0xFF8A85A0),
};

class RankPage extends StatefulWidget {
  const RankPage({super.key});
  @override State<RankPage> createState()=>_RankPageState();
}

class _RankPageState extends State<RankPage> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl,_entryCtrl;
  late final TabController _tabCtrl;
  int _myRank = 4;

  @override void initState(){
    super.initState();
    _bgCtrl    = AnimationController(vsync:this,duration:const Duration(seconds:14))..repeat(reverse:true);
    _entryCtrl = AnimationController(vsync:this,duration:const Duration(milliseconds:1300))..forward();
    _tabCtrl   = TabController(length:_tabs.length,vsync:this);
  }
  @override void dispose(){ _bgCtrl.dispose(); _entryCtrl.dispose(); _tabCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final p=_Palette.of(context);
    final isDark=Theme.of(context).brightness==Brightness.dark;
    final size=MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor:p.bg,
      body:Stack(children:[
        AnimatedBuilder(animation:_bgCtrl,builder:(_,__)=>CustomPaint(size:size,
            painter:_StarfieldPainter(CurvedAnimation(parent:_bgCtrl,curve:Curves.easeInOut).value,isDark))),
        SafeArea(child:Column(children:[
          _buildHeader(p),
          SizedBox(height:12.h),
          _buildMyRankCard(p),
          SizedBox(height:12.h),
          _buildTabBar(p),
          Expanded(child:TabBarView(controller:_tabCtrl,children:[
            _buildList(p),
            _buildList(p,friendOnly:true),
            _buildList(p),
          ])),
        ])),
        Positioned(bottom:0, left:0, right:0, child: const AppNavBar(current: NavDest.rank)),
      ]),
    );
  }

  Widget _buildHeader(_Palette p) => Padding(
    padding:EdgeInsets.fromLTRB(18.w,10.h,18.w,0),
    child:Row(children:[
      Text('Leaderboard',style:GoogleFonts.dmSerifDisplay(fontSize:22.sp,color:p.text)),
      const Spacer(),
      _Chip(emoji:'🏆',label:'Season 3',fg:p.gold,bg:p.goldSoft),
    ]),
  );

  Widget _buildMyRankCard(_Palette p) {
    return SlideTransition(
      position:Tween<Offset>(begin:const Offset(0,-0.2),end:Offset.zero)
          .animate(CurvedAnimation(parent:_entryCtrl,curve:const Interval(0,0.5,curve:Curves.easeOut))),
      child:FadeTransition(opacity:CurvedAnimation(parent:_entryCtrl,curve:const Interval(0,0.5,curve:Curves.easeOut)),
          child:Container(
            margin:EdgeInsets.symmetric(horizontal:18.w),
            padding:EdgeInsets.all(16.w),
            decoration:BoxDecoration(
              gradient:LinearGradient(colors:[p.accent.withOpacity(0.18),p.gold.withOpacity(0.08)],
                  begin:Alignment.topLeft,end:Alignment.bottomRight),
              borderRadius:BorderRadius.circular(20.r),
              border:Border.all(color:p.accent.withOpacity(0.3)),
              boxShadow:[BoxShadow(color:p.accent.withOpacity(0.12),blurRadius:20,offset:const Offset(0,6))],
            ),
            child:Row(children:[
              // Rank badge
              Container(width:52.w,height:52.w,
                  decoration:BoxDecoration(color:p.accentSoft,shape:BoxShape.circle,
                      border:Border.all(color:p.accent.withOpacity(0.4),width:2)),
                  child:Center(child:Text('#$_myRank',style:GoogleFonts.dmSerifDisplay(fontSize:16.sp,color:p.accent)))),
              SizedBox(width:12.w),
              Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                Text('Your Ranking',style:GoogleFonts.dmMono(fontSize:9.sp,color:p.sub,fontWeight:FontWeight.w600)),
                SizedBox(height:2.h),
                Text('ByteSlayer',style:GoogleFonts.dmSerifDisplay(fontSize:15.sp,color:p.text)),
                SizedBox(height:3.h),
                Row(children:[
                  Container(padding:EdgeInsets.symmetric(horizontal:6.w,vertical:2.h),
                      decoration:BoxDecoration(color:const Color(0xFF3DD68C).withOpacity(0.12),borderRadius:BorderRadius.circular(6.r)),
                      child:Text('💎 Diamond',style:GoogleFonts.dmMono(fontSize:8.sp,color:const Color(0xFF3DD68C),fontWeight:FontWeight.w700))),
                  SizedBox(width:8.w),
                  Text('2,140 MMR',style:GoogleFonts.dmMono(fontSize:9.sp,color:p.gold,fontWeight:FontWeight.w700)),
                ]),
              ])),
              Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                Container(padding:EdgeInsets.symmetric(horizontal:7.w,vertical:3.h),
                    decoration:BoxDecoration(color:p.winSoft,borderRadius:BorderRadius.circular(8.r)),
                    child:Text('+27 this week',style:GoogleFonts.dmMono(fontSize:8.sp,color:p.win,fontWeight:FontWeight.w700))),
                SizedBox(height:6.h),
                Text('Top 0.3%',style:GoogleFonts.dmMono(fontSize:8.5.sp,color:p.sub)),
              ]),
            ]),
          )),
    );
  }

  Widget _buildTabBar(_Palette p) => Container(
    margin:EdgeInsets.symmetric(horizontal:18.w),
    height:38.h,
    decoration:BoxDecoration(color:p.surface2,borderRadius:BorderRadius.circular(12.r)),
    child:TabBar(
      controller:_tabCtrl,
      indicator:BoxDecoration(color:p.accent,borderRadius:BorderRadius.circular(10.r),
          boxShadow:[BoxShadow(color:p.accent.withOpacity(0.35),blurRadius:8)]),
      indicatorSize:TabBarIndicatorSize.tab,
      labelStyle:GoogleFonts.dmMono(fontSize:10.sp,fontWeight:FontWeight.w700),
      unselectedLabelStyle:GoogleFonts.dmMono(fontSize:10.sp),
      labelColor:Colors.white,
      unselectedLabelColor:p.sub,
      dividerColor:Colors.transparent,
      tabs:_tabs.map((t)=>Tab(text:t)).toList(),
    ),
  );

  Widget _buildList(_Palette p,{bool friendOnly=false}) {
    final list = friendOnly
        ? _players.where((pl)=>['ByteSlayer','CodeNinja42','algo_wizard','PixelCoder'].contains(pl.name)).toList()
        : _players;
    return ListView.separated(
      padding:EdgeInsets.fromLTRB(18.w,12.h,18.w,120.h),
      separatorBuilder:(_,__)=>SizedBox(height:8.h),
      itemCount:list.length,
      itemBuilder:(ctx,i){
        final pl=list[i];
        final isMe=pl.name=='ByteSlayer';
        final tierColor=_tierColors[pl.tier]??p.sub;
        final up=pl.delta.startsWith('+');
        return AnimatedBuilder(animation:_entryCtrl,builder:(_,child){
          final t=CurvedAnimation(parent:_entryCtrl,
              curve:Interval((0.1+i*0.06).clamp(0,0.8),(0.1+i*0.06+0.35).clamp(0,1),curve:Curves.easeOut)).value;
          return Opacity(opacity:t,child:Transform.translate(offset:Offset(30*(1-t),0),child:child));
        },
            child:Container(
              padding:EdgeInsets.symmetric(horizontal:14.w,vertical:11.h),
              decoration:BoxDecoration(
                color:isMe?p.accent.withOpacity(0.08):p.surface,
                borderRadius:BorderRadius.circular(14.r),
                border:Border.all(color:isMe?p.accent.withOpacity(0.35):p.hint.withOpacity(0.10)),
                boxShadow:[BoxShadow(color:isMe?p.accent.withOpacity(0.10):Colors.black.withOpacity(0.04),
                    blurRadius:10,offset:const Offset(0,3))],
              ),
              child:Row(children:[
                // Rank number
                SizedBox(width:28.w,
                    child:pl.rank<=3
                        ? Text(['🥇','🥈','🥉'][pl.rank-1],style:TextStyle(fontSize:18.sp),textAlign:TextAlign.center)
                        : Text('#${pl.rank}',style:GoogleFonts.dmMono(fontSize:11.sp,color:p.hint,fontWeight:FontWeight.w700))),
                SizedBox(width:8.w),
                Text(pl.emoji,style:TextStyle(fontSize:18.sp)),
                SizedBox(width:10.w),
                Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
                  Row(children:[
                    Text(pl.name,style:GoogleFonts.dmMono(fontSize:11.sp,
                        color:isMe?p.accent:p.text,fontWeight:FontWeight.w700)),
                    if(isMe)...[SizedBox(width:5.w),
                      Container(padding:EdgeInsets.symmetric(horizontal:5.w,vertical:1.h),
                          decoration:BoxDecoration(color:p.accentSoft,borderRadius:BorderRadius.circular(4.r)),
                          child:Text('YOU',style:GoogleFonts.dmMono(fontSize:6.sp,color:p.accent,fontWeight:FontWeight.w800)))],
                  ]),
                  SizedBox(height:2.h),
                  Text(pl.tier,style:GoogleFonts.dmMono(fontSize:8.5.sp,color:tierColor,fontWeight:FontWeight.w600)),
                ])),
                Column(crossAxisAlignment:CrossAxisAlignment.end,children:[
                  Text('${pl.rating} MMR',style:GoogleFonts.dmMono(fontSize:10.sp,color:p.gold,fontWeight:FontWeight.w700)),
                  SizedBox(height:3.h),
                  Text(pl.delta,style:GoogleFonts.dmMono(fontSize:8.5.sp,
                      color:up?p.win:p.loss,fontWeight:FontWeight.w600)),
                ]),
              ]),
            ));
      },
    );
  }

  Widget _buildNav(_Palette p)=>Container(
    padding:EdgeInsets.only(top:12.h,bottom:26.h,left:18.w,right:18.w),
    decoration:BoxDecoration(color:p.surface.withOpacity(0.96),
        border:Border(top:BorderSide(color:p.hint.withOpacity(0.10))),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.10),blurRadius:30,offset:const Offset(0,-4))]),
    child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[
      _NavBtn(icon:Icons.flash_on_rounded,    label:'Battle',  active:false,p:p),
      _NavBtn(icon:Icons.emoji_events_rounded,label:'Rank',    active:true, p:p),
      _NavBtn(icon:Icons.home_rounded,        label:'Home',    active:false,p:p),
      _NavBtn(icon:Icons.person_rounded,      label:'Profile', active:false,p:p),
      _NavBtn(icon:Icons.settings_rounded,    label:'Settings',active:false,p:p),
    ]),
  );
}

class _Chip extends StatelessWidget {
  final String emoji,label;final Color fg,bg;
  const _Chip({required this.emoji,required this.label,required this.fg,required this.bg});
  @override Widget build(BuildContext context)=>Container(
    padding:EdgeInsets.symmetric(horizontal:10.w,vertical:6.h),
    decoration:BoxDecoration(color:bg,borderRadius:BorderRadius.circular(12.r),border:Border.all(color:fg.withOpacity(0.3))),
    child:Row(mainAxisSize:MainAxisSize.min,children:[Text(emoji,style:TextStyle(fontSize:11.sp)),SizedBox(width:5.w),
      Text(label,style:GoogleFonts.dmMono(fontSize:10.sp,color:fg,fontWeight:FontWeight.w700))]),
  );
}
class _NavBtn extends StatelessWidget {
  final IconData icon;final String label;final bool active;final _Palette p;
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
class _StarfieldPainter extends CustomPainter {
  final double t;final bool isDark;
  const _StarfieldPainter(this.t,this.isDark);
  @override void paint(Canvas canvas,Size size){
    final drift=math.sin(t*math.pi)*32;final mul=isDark?1.0:0.55;
    _blob(canvas,Offset(size.width*0.88+drift,size.height*0.10),size.width*0.65,const Color(0xFF7C6EF5).withOpacity(0.13*mul));
    _blob(canvas,Offset(size.width*0.07,size.height*0.55+drift*0.6),size.width*0.55,const Color(0xFF3DD68C).withOpacity(0.08*mul));
    _blob(canvas,Offset(size.width*0.60,size.height*0.78-drift*0.4),size.width*0.50,const Color(0xFFFF6B6B).withOpacity(0.07*mul));
    if(isDark){final rng=math.Random(42);for(var i=0;i<90;i++){final sx=rng.nextDouble()*size.width;final sy=rng.nextDouble()*size.height;final sr=rng.nextDouble()*1.3+0.2;final op=(0.15+rng.nextDouble()*0.5+math.sin(t*math.pi*2+i)*0.18).clamp(0.0,0.85);canvas.drawCircle(Offset(sx,sy),sr,Paint()..color=Colors.white.withOpacity(op));}}
  }
  void _blob(Canvas c,Offset centre,double r,Color color)=>c.drawCircle(centre,r,Paint()..shader=RadialGradient(colors:[color,Colors.transparent]).createShader(Rect.fromCircle(center:centre,radius:r)));
  @override bool shouldRepaint(covariant _StarfieldPainter o)=>o.t!=t||o.isDark!=isDark;
}