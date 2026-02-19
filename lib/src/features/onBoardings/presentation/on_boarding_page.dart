import 'package:devs/src/features/onBoardings/presentation/page_view/page_view1.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../core/common/constants/font_strings.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

List<Widget> pages = [
  const PageView1(
    image: 'assets/onBoarding/ob2.png',
    title: 'Start your journey',
    subTitle:
    'You can start your journey in the field you love, no need to be afraid of getting lost, we will help you reach the finish line',
  ),
  const PageView1(
    image: 'assets/onBoarding/ob3.png',
    title: 'You can be anything, the world is in your hands',
    subTitle:
    'By learning & increasing knowledge you will become a wise person and can change things around you and even the world',
  ),
  const PageView1(
    height: 348,
    image: 'assets/onBoarding/ob1.png',
    title: 'Find a field that you like',
    subTitle:
    'There are many fields that you can find here, and you can learn all of them',
  ),
];

class _OnBoardingPageState extends State<OnBoardingPage> {
  late PageController _pageController;
  bool isLastPage = false;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();

    _pageController.addListener(() {
      setState(() {
        isLastPage =
            _pageController.page!.round() == pages.length - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode =
        Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Stack(
        children: [

          /// Gradient Background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDarkMode
                    ? [Colors.black, const Color(0xFF111111)]
                    : [Colors.white, const Color(0xFFF5F5F5)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          /// PageView
          PageView(
            controller: _pageController,
            children: pages,
          ),

          /// Indicator
          Positioned(
            bottom: 160.h,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: pages.length,
                effect: WormEffect(
                  dotHeight: 8.h,
                  dotWidth: 8.w,
                  spacing: 8.w,
                  activeDotColor: isDarkMode
                      ? Colors.white
                      : Colors.black,
                  dotColor: isDarkMode
                      ? Colors.white.withOpacity(0.2)
                      : Colors.black.withOpacity(0.2),
                ),
              ),
            ),
          ),

          /// Morphing Button
          Positioned(
            bottom: 40.h,
            right: 21,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeInOut,
              width: isLastPage ? 330.w : 60.w,
              height: 60.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                gradient: LinearGradient(
                  colors: isDarkMode
                      ? [Colors.white, Colors.grey.shade300]
                      : [Colors.black, Colors.grey.shade900],
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDarkMode
                        ? Colors.white.withOpacity(0.3)
                        : Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20.r),
                  onTap: () {
                    if (!isLastPage) {
                      _pageController.nextPage(
                        duration:
                        const Duration(milliseconds: 500),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      context.push('/welcome');
                    }
                  },
                  child: Center(
                    child: AnimatedSwitcher(
                      duration:
                      const Duration(milliseconds: 300),
                      transitionBuilder:
                          (child, anim) => FadeTransition(
                        opacity: anim,
                        child: child,
                      ),
                      child: isLastPage
                          ? Text(
                        "Get Started",
                        key: const ValueKey('text'),
                        style: TextStyle(
                          color: isDarkMode
                              ? Colors.black
                              : Colors.white,
                          fontSize: 18.sp,
                          fontFamily:
                          AppFontStrings.pjsBold,
                        ),
                      )
                          : Icon(
                        Icons.arrow_forward_rounded,
                        key: const ValueKey('icon'),
                        color: isDarkMode
                            ? Colors.black
                            : Colors.white,
                        size: 28.sp,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
