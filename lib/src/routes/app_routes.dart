import 'package:devs/src/features/auth/presentation/pages/forget_psw_page.dart';
import 'package:devs/src/features/auth/presentation/pages/login_page.dart';
import 'package:devs/src/features/auth/presentation/pages/signup_page.dart';
import 'package:devs/src/features/battle/presentation/screens/battle_page.dart';
import 'package:devs/src/features/onBoardings/presentation/on_boarding_page.dart';
import 'package:devs/src/features/profile/profile_page.dart';
import 'package:devs/src/features/rank/presentation/screens/rank_page.dart';
import 'package:devs/src/features/settings/presentaion/screens/settings_page.dart';
import 'package:devs/src/features/welcome/presentaion/welcome_page.dart';
import 'package:devs/src/features/home/presentation/pages/home_page.dart';
import 'package:devs/src/features/home/presentation/pages/home_screen.dart';
import 'package:go_router/go_router.dart';

final appRoutes = GoRouter(
  initialLocation: '/onBoarding',
  routes: [
    GoRoute(
      path: '/onBoarding',
      builder: (context, state) => const OnBoardingPage(),
    ),
    GoRoute(path: '/welcome',  builder: (context, state) => const WelcomePage()),
    GoRoute(path: '/login',    builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup',   builder: (context, state) => const SignupPage()),
    GoRoute(path: '/home',     builder: (context, state) => const ProfileBuilderPage()),
    GoRoute(path: '/level',    builder: (context, state) => const LevelMapPage()),
    GoRoute(path: '/profile',  builder: (context, state) => const ProfilePage()),
    GoRoute(path: '/settings', builder: (context, state) => const SettingsPage()),  // ✅ fixed path
    GoRoute(path: '/rank',     builder: (context, state) => const RankPage()),      // ✅ fixed path
    GoRoute(path: '/battle',   builder: (context, state) => const BattlePage()),   // ✅ fixed path
    GoRoute(path: '/forgetPs',   builder: (context, state) => const ForgetPsPage()),   // ✅ fixed path
  ],
);