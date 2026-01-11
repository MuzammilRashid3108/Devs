import 'package:devs/src/features/auth/presentation/pages/forget_psw_page.dart';
import 'package:devs/src/features/auth/presentation/pages/login_page.dart';
import 'package:devs/src/features/auth/presentation/pages/signup_page.dart';
import 'package:devs/src/features/onBoardings/presentation/on_boarding_page.dart';
import 'package:devs/src/features/welcome/presentaion/welcome_page.dart';
import 'package:devs/src/features/home/presentation/pages/home_page.dart';
import 'package:go_router/go_router.dart';

final appRoutes = GoRouter(
  initialLocation: '/onBoarding',
  routes: [
    GoRoute(
      path: '/onBoarding',
      builder: (context, state) => const OnBoardingPage(),
    ),
    GoRoute(path: '/welcome', builder: (context, state) => const WelcomePage()),
    GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
    GoRoute(path: '/signup', builder: (context, state) => const SignupPage()),
    GoRoute(path: '/home', builder: (context, state) => const HomePage()),
  ],
);
