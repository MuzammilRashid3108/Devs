import 'package:devs/src/features/onBoardings/presentation/on_boarding_page.dart';
import 'package:go_router/go_router.dart';


final appRoutes = GoRouter(
  initialLocation: '/onBoarding',
  routes: [
    GoRoute(path: '/onBoarding', builder: (context, state) => const OnBoardingPage()),
  ],
);
