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

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override State<SettingsPage> createState()=>_SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> with TickerProviderStateMixin {
  late final AnimationController _bgCtrl,_entryCtrl;

  // Toggle states
  bool _darkMode        = true;
  bool _haptics         = true;
  bool _soundFx         = true;
  bool _bgMusic         = false;
  bool _pushBattleInv   = true;
  bool _pushStreak      = true;
  bool _pushLeaderboard = false;
  bool _pushDailyRemind = true;
  bool _showOnline      = true;
  bool _publicProfile   = true;
  String _difficulty    = 'Medium';
  String _language      = 'Python';
  double _matchTimeout  = 30;

  @override void initState(){
    super.initState();
    _bgCtrl   =AnimationController(vsync:this,duration:const Duration(seconds:14))..repeat(reverse:true);
    _entryCtrl=AnimationController(vsync:this,duration:const Duration(milliseconds:1100))..forward();
  }
  @override void dispose(){ _bgCtrl.dispose(); _entryCtrl.dispose(); super.dispose(); }

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
          Expanded(child:SingleChildScrollView(
            physics:const BouncingScrollPhysics(),
            padding:EdgeInsets.only(bottom:110.h),
            child:Column(children:[
              SizedBox(height:10.h),
              _buildAccountCard(p),
              SizedBox(height:14.h),
              _section(p,'🎮  Gameplay',[
                _DropdownTile(label:'Preferred Difficulty',value:_difficulty,
                    options:const['Easy','Medium','Hard','Mixed'],
                    icon:Icons.bar_chart_rounded,color:p.gold,p:p,
                    onChanged:(v)=>setState(()=>_difficulty=v)),
                _DropdownTile(label:'Default Language',value:_language,
                    options:const['Python','JavaScript','C++','Java','Rust','Go'],
                    icon:Icons.code_rounded,color:p.accent,p:p,
                    onChanged:(v)=>setState(()=>_language=v)),
                _SliderTile(label:'Match Timeout',value:_matchTimeout,
                    min:15,max:60,suffix:'s',
                    icon:Icons.timer_rounded,color:p.win,p:p,
                    onChanged:(v)=>setState(()=>_matchTimeout=v)),
              ],i:0),
              SizedBox(height:14.h),
              _section(p,'🎨  Appearance',[
                _ToggleTile(label:'Dark Mode',sub:'Starfield theme',
                    icon:Icons.dark_mode_rounded,color:p.accent,value:_darkMode,p:p,
                    onChanged:(v){setState(()=>_darkMode=v);HapticFeedback.lightImpact();}),
                _ToggleTile(label:'Haptic Feedback',sub:'Vibrations on tap',
                    icon:Icons.vibration_rounded,color:p.gold,value:_haptics,p:p,
                    onChanged:(v)=>setState(()=>_haptics=v)),
                _ToggleTile(label:'Sound FX',sub:'Battle & victory sounds',
                    icon:Icons.volume_up_rounded,color:p.win,value:_soundFx,p:p,
                    onChanged:(v)=>setState(()=>_soundFx=v)),
                _ToggleTile(label:'Background Music',sub:'Ambient zone music',
                    icon:Icons.music_note_rounded,color:p.loss,value:_bgMusic,p:p,
                    onChanged:(v)=>setState(()=>_bgMusic=v)),
              ],i:1),
              SizedBox(height:14.h),
              _section(p,'🔔  Notifications',[
                _ToggleTile(label:'Battle Invitations',sub:'When friends challenge you',
                    icon:Icons.flash_on_rounded,color:p.loss,value:_pushBattleInv,p:p,
                    onChanged:(v)=>setState(()=>_pushBattleInv=v)),
                _ToggleTile(label:'Streak Reminders',sub:'Keep your streak alive',
                    icon:Icons.local_fire_department_rounded,color:p.gold,value:_pushStreak,p:p,
                    onChanged:(v)=>setState(()=>_pushStreak=v)),
                _ToggleTile(label:'Leaderboard Changes',sub:'When you drop in rank',
                    icon:Icons.emoji_events_rounded,color:p.accent,value:_pushLeaderboard,p:p,
                    onChanged:(v)=>setState(()=>_pushLeaderboard=v)),
                _ToggleTile(label:'Daily Challenge',sub:'Daily problem reminders',
                    icon:Icons.today_rounded,color:p.win,value:_pushDailyRemind,p:p,
                    onChanged:(v)=>setState(()=>_pushDailyRemind=v)),
              ],i:2),
              SizedBox(height:14.h),
              _section(p,'🔒  Privacy',[
                _ToggleTile(label:'Show Online Status',sub:'Let others see when active',
                    icon:Icons.circle,color:p.win,value:_showOnline,p:p,
                    onChanged:(v)=>setState(()=>_showOnline=v)),
                _ToggleTile(label:'Public Profile',sub:'Visible on leaderboards',
                    icon:Icons.public_rounded,color:p.accent,value:_publicProfile,p:p,
                    onChanged:(v)=>setState(()=>_publicProfile=v)),
              ],i:3),
              SizedBox(height:14.h),
              _section(p,'⚠️  Danger Zone',[
                _ActionTile(label:'Reset Progress',sub:'Clear all level data',
                    icon:Icons.refresh_rounded,color:p.gold,p:p,
                    onTap:()=>_confirmSheet(context,p,'Reset Progress',
                        'This will wipe all your level progress. XP and rank are safe.','🔄',p.gold)),
                _ActionTile(label:'Delete Account',sub:'Permanently remove everything',
                    icon:Icons.delete_forever_rounded,color:p.loss,p:p,
                    onTap:()=>_confirmSheet(context,p,'Delete Account',
                        'This will permanently delete your account and all data.','💀',p.loss)),
              ],i:4),
              SizedBox(height:14.h),
              _buildAppInfo(p),
            ]),
          )),
        ])),
        Positioned(bottom:0, left:0, right:0, child: const AppNavBar(current: NavDest.settings)),
      ]),
    );
  }

  Widget _buildHeader(_Palette p)=>Padding(
    padding:EdgeInsets.fromLTRB(18.w,10.h,18.w,0),
    child:Row(children:[
      Text('Settings',style:GoogleFonts.dmSerifDisplay(fontSize:22.sp,color:p.text)),
      const Spacer(),
      Container(padding:EdgeInsets.symmetric(horizontal:10.w,vertical:6.h),
          decoration:BoxDecoration(color:p.winSoft,borderRadius:BorderRadius.circular(12.r),border:Border.all(color:p.win.withOpacity(0.3))),
          child:Text('v2.4.1',style:GoogleFonts.dmMono(fontSize:9.sp,color:p.win,fontWeight:FontWeight.w700))),
    ]),
  );

  Widget _buildAccountCard(_Palette p)=>FadeTransition(
    opacity:CurvedAnimation(parent:_entryCtrl,curve:const Interval(0,0.5,curve:Curves.easeOut)),
    child:Container(
      margin:EdgeInsets.symmetric(horizontal:18.w),
      padding:EdgeInsets.all(14.w),
      decoration:BoxDecoration(
        gradient:LinearGradient(colors:[p.accent.withOpacity(0.14),p.gold.withOpacity(0.06)],
            begin:Alignment.topLeft,end:Alignment.bottomRight),
        borderRadius:BorderRadius.circular(20.r),
        border:Border.all(color:p.accent.withOpacity(0.25)),
        boxShadow:[BoxShadow(color:p.accent.withOpacity(0.10),blurRadius:18,offset:const Offset(0,5))],
      ),
      child:Row(children:[
        Container(width:46.w,height:46.w,
            decoration:BoxDecoration(gradient:const LinearGradient(colors:[Color(0xFF9C91F8),Color(0xFF7C6EF5)]),
                shape:BoxShape.circle,border:Border.all(color:Colors.white.withOpacity(0.2),width:2)),
            child:Center(child:Text('🧑‍💻',style:TextStyle(fontSize:22.sp)))),
        SizedBox(width:12.w),
        Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
          Text('ByteSlayer',style:GoogleFonts.dmSerifDisplay(fontSize:15.sp,color:p.text)),
          SizedBox(height:2.h),
          Text('byteslayer@code.io',style:GoogleFonts.dmMono(fontSize:9.sp,color:p.sub)),
          SizedBox(height:4.h),
          Text('Grandmaster 👑',style:GoogleFonts.dmMono(fontSize:8.5.sp,color:p.gold,fontWeight:FontWeight.w700)),
        ])),
        Column(children:[
          GestureDetector(
            onTap:(){HapticFeedback.lightImpact();},
            child:Container(padding:EdgeInsets.symmetric(horizontal:10.w,vertical:6.h),
                decoration:BoxDecoration(color:p.accentSoft,borderRadius:BorderRadius.circular(10.r),
                    border:Border.all(color:p.accent.withOpacity(0.3))),
                child:Text('Edit',style:GoogleFonts.dmMono(fontSize:10.sp,color:p.accent,fontWeight:FontWeight.w700))),
          ),
          SizedBox(height:6.h),
          GestureDetector(
            onTap:(){HapticFeedback.lightImpact();},
            child:Container(padding:EdgeInsets.symmetric(horizontal:10.w,vertical:6.h),
                decoration:BoxDecoration(color:p.lossSoft,borderRadius:BorderRadius.circular(10.r),
                    border:Border.all(color:p.loss.withOpacity(0.3))),
                child:Text('Logout',style:GoogleFonts.dmMono(fontSize:10.sp,color:p.loss,fontWeight:FontWeight.w700))),
          ),
        ]),
      ]),
    ),
  );

  Widget _section(_Palette p, String title, List<Widget> tiles, {required int i}) {
    return AnimatedBuilder(animation:_entryCtrl,builder:(_,child){
      final t=CurvedAnimation(parent:_entryCtrl,
          curve:Interval((0.1+i*0.08).clamp(0,0.7),(0.1+i*0.08+0.4).clamp(0,1),curve:Curves.easeOut)).value;
      return Opacity(opacity:t,child:Transform.translate(offset:Offset(0,16*(1-t)),child:child));
    },
        child:Container(
          margin:EdgeInsets.symmetric(horizontal:18.w),
          decoration:BoxDecoration(color:p.surface,borderRadius:BorderRadius.circular(20.r),
              border:Border.all(color:p.hint.withOpacity(0.10)),
              boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.05),blurRadius:12,offset:const Offset(0,4))]),
          child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Padding(padding:EdgeInsets.fromLTRB(16.w,14.h,16.w,6.h),
                child:Text(title,style:GoogleFonts.dmSerifDisplay(fontSize:14.sp,color:p.text))),
            ...tiles.map((t)=>Column(children:[
              Divider(height:1,color:p.hint.withOpacity(0.07),indent:16.w,endIndent:16.w),
              t,
            ])).toList(),
            SizedBox(height:4.h),
          ]),
        ));
  }

  Widget _buildAppInfo(_Palette p) => Container(
    margin:EdgeInsets.symmetric(horizontal:18.w),
    padding:EdgeInsets.all(16.w),
    decoration:BoxDecoration(color:p.surface,borderRadius:BorderRadius.circular(20.r),
        border:Border.all(color:p.hint.withOpacity(0.10))),
    child:Column(children:[
      Text('🧑‍💻',style:TextStyle(fontSize:32.sp)),
      SizedBox(height:6.h),
      Text('ByteArena',style:GoogleFonts.dmSerifDisplay(fontSize:18.sp,color:p.text)),
      SizedBox(height:3.h),
      Text('Version 2.4.1 (Build 241)',style:GoogleFonts.dmMono(fontSize:9.sp,color:p.hint)),
      SizedBox(height:10.h),
      Row(mainAxisAlignment:MainAxisAlignment.center,children:[
        _linkBtn('Privacy Policy',p),SizedBox(width:12.w),
        _linkBtn('Terms of Use',p),SizedBox(width:12.w),
        _linkBtn('Help',p),
      ]),
      SizedBox(height:8.h),
      Text('Made with ❤️ for coders worldwide',style:GoogleFonts.dmMono(fontSize:8.5.sp,color:p.hint)),
    ]),
  );

  Widget _linkBtn(String label,_Palette p)=>GestureDetector(
    onTap:(){},
    child:Text(label,style:GoogleFonts.dmMono(fontSize:9.sp,color:p.accent,fontWeight:FontWeight.w600,
        decoration:TextDecoration.underline,decorationColor:p.accent.withOpacity(0.4))),
  );

  Widget _buildNav(_Palette p)=>Container(
    padding:EdgeInsets.only(top:12.h,bottom:26.h,left:18.w,right:18.w),
    decoration:BoxDecoration(color:p.surface.withOpacity(0.96),
        border:Border(top:BorderSide(color:p.hint.withOpacity(0.10))),
        boxShadow:[BoxShadow(color:Colors.black.withOpacity(0.10),blurRadius:30,offset:const Offset(0,-4))]),
    child:Row(mainAxisAlignment:MainAxisAlignment.spaceAround,children:[
      _NavBtn(icon:Icons.flash_on_rounded,    label:'Battle',  active:false,p:p),
      _NavBtn(icon:Icons.emoji_events_rounded,label:'Rank',    active:false,p:p),
      _NavBtn(icon:Icons.home_rounded,        label:'Home',    active:false,p:p),
      _NavBtn(icon:Icons.person_rounded,      label:'Profile', active:false,p:p),
      _NavBtn(icon:Icons.settings_rounded,    label:'Settings',active:true, p:p),
    ]),
  );

  void _confirmSheet(BuildContext ctx,_Palette p,String title,String sub,String emoji,Color color)=>
      showModalBottomSheet(context:ctx,backgroundColor:Colors.transparent,builder:(_)=>_Sheet(p:p,children:[
        Text(emoji,style:TextStyle(fontSize:44.sp)),
        SizedBox(height:10.h),
        Text(title,style:GoogleFonts.dmSerifDisplay(fontSize:22.sp,color:p.text)),
        SizedBox(height:6.h),
        Text(sub,textAlign:TextAlign.center,style:GoogleFonts.dmMono(fontSize:11.sp,color:p.sub,height:1.5)),
        SizedBox(height:24.h),
        _Btn(label:'Confirm — $title',color:color,onTap:(){HapticFeedback.heavyImpact();Navigator.pop(ctx);}),
        SizedBox(height:10.h),
        GestureDetector(onTap:()=>Navigator.pop(ctx),child:Text('Cancel',style:GoogleFonts.dmMono(fontSize:13.sp,color:p.sub))),
      ]));
}

// ─────────────────────────────────────────────────────────────────────────────
// SETTING TILE TYPES
// ─────────────────────────────────────────────────────────────────────────────
class _ToggleTile extends StatelessWidget {
  final String label,sub;final IconData icon;final Color color;
  final bool value;final _Palette p;final ValueChanged<bool> onChanged;
  const _ToggleTile({required this.label,required this.sub,required this.icon,
    required this.color,required this.value,required this.p,required this.onChanged});
  @override Widget build(BuildContext context)=>Padding(
    padding:EdgeInsets.symmetric(horizontal:16.w,vertical:11.h),
    child:Row(children:[
      Container(width:34.w,height:34.w,
          decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(10.r)),
          child:Icon(icon,size:16.sp,color:color)),
      SizedBox(width:12.w),
      Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
        Text(label,style:GoogleFonts.dmMono(fontSize:11.sp,color:p.text,fontWeight:FontWeight.w700)),
        SizedBox(height:1.h),
        Text(sub,style:GoogleFonts.dmMono(fontSize:8.5.sp,color:p.sub)),
      ])),
      Switch(value:value,onChanged:onChanged,
          activeColor:color,activeTrackColor:color.withOpacity(0.25),
          inactiveThumbColor:p.hint,inactiveTrackColor:p.surface2),
    ]),
  );
}

class _DropdownTile extends StatelessWidget {
  final String label,value;final List<String> options;
  final IconData icon;final Color color;final _Palette p;final ValueChanged<String> onChanged;
  const _DropdownTile({required this.label,required this.value,required this.options,
    required this.icon,required this.color,required this.p,required this.onChanged});
  @override Widget build(BuildContext context)=>Padding(
    padding:EdgeInsets.symmetric(horizontal:16.w,vertical:11.h),
    child:Row(children:[
      Container(width:34.w,height:34.w,
          decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(10.r)),
          child:Icon(icon,size:16.sp,color:color)),
      SizedBox(width:12.w),
      Expanded(child:Text(label,style:GoogleFonts.dmMono(fontSize:11.sp,color:p.text,fontWeight:FontWeight.w700))),
      Theme(data:Theme.of(context).copyWith(canvasColor:p.surface),
          child:DropdownButton<String>(
              value:value,underline:const SizedBox(),isDense:true,
              style:GoogleFonts.dmMono(fontSize:10.sp,color:color,fontWeight:FontWeight.w700),
              icon:Icon(Icons.expand_more_rounded,size:14.sp,color:p.hint),
              items:options.map((o)=>DropdownMenuItem(value:o,
                  child:Text(o,style:GoogleFonts.dmMono(fontSize:10.sp,color:p.text)))).toList(),
              onChanged:(v){if(v!=null)onChanged(v);})),
    ]),
  );
}

class _SliderTile extends StatelessWidget {
  final String label,suffix;final double value,min,max;
  final IconData icon;final Color color;final _Palette p;final ValueChanged<double> onChanged;
  const _SliderTile({required this.label,required this.value,required this.min,required this.max,
    required this.suffix,required this.icon,required this.color,required this.p,required this.onChanged});
  @override Widget build(BuildContext context)=>Padding(
    padding:EdgeInsets.fromLTRB(16.w,11.h,16.w,6.h),
    child:Column(children:[
      Row(children:[
        Container(width:34.w,height:34.w,
            decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(10.r)),
            child:Icon(icon,size:16.sp,color:color)),
        SizedBox(width:12.w),
        Expanded(child:Text(label,style:GoogleFonts.dmMono(fontSize:11.sp,color:p.text,fontWeight:FontWeight.w700))),
        Text('${value.round()}$suffix',style:GoogleFonts.dmMono(fontSize:11.sp,color:color,fontWeight:FontWeight.w700)),
      ]),
      SliderTheme(data:SliderThemeData(
          activeTrackColor:color,inactiveTrackColor:color.withOpacity(0.15),
          thumbColor:color,overlayColor:color.withOpacity(0.12),
          trackHeight:3,thumbShape:const RoundSliderThumbShape(enabledThumbRadius:7)),
          child:Slider(value:value,min:min,max:max,onChanged:onChanged)),
    ]),
  );
}

class _ActionTile extends StatelessWidget {
  final String label,sub;final IconData icon;final Color color;
  final _Palette p;final VoidCallback onTap;
  const _ActionTile({required this.label,required this.sub,required this.icon,
    required this.color,required this.p,required this.onTap});
  @override Widget build(BuildContext context)=>GestureDetector(
    onTap:onTap,
    child:Padding(padding:EdgeInsets.symmetric(horizontal:16.w,vertical:11.h),
        child:Row(children:[
          Container(width:34.w,height:34.w,
              decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(10.r)),
              child:Icon(icon,size:16.sp,color:color)),
          SizedBox(width:12.w),
          Expanded(child:Column(crossAxisAlignment:CrossAxisAlignment.start,children:[
            Text(label,style:GoogleFonts.dmMono(fontSize:11.sp,color:color,fontWeight:FontWeight.w700)),
            SizedBox(height:1.h),
            Text(sub,style:GoogleFonts.dmMono(fontSize:8.5.sp,color:p.sub)),
          ])),
          Icon(Icons.chevron_right_rounded,size:16.sp,color:p.hint),
        ])),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// SHARED WIDGETS + PAINTERS
// ─────────────────────────────────────────────────────────────────────────────
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
class _Sheet extends StatelessWidget {
  final _Palette p;final List<Widget> children;
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
  final String label;final Color color;final VoidCallback onTap;
  const _Btn({required this.label,required this.color,required this.onTap});
  @override Widget build(BuildContext context)=>GestureDetector(
      onTap:onTap,child:Container(width:double.infinity,height:50.h,
      decoration:BoxDecoration(color:color.withOpacity(0.12),borderRadius:BorderRadius.circular(16.r),border:Border.all(color:color.withOpacity(0.35))),
      child:Center(child:Text(label,style:GoogleFonts.dmMono(fontSize:13.sp,color:color,fontWeight:FontWeight.w700)))));
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