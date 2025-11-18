import 'package:devs/src/features/onBoardings/presentation/page_view/page_view1.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import '../../../core/common/constants/font_strings.dart';

class OnBoardingPage extends StatefulWidget {
  const OnBoardingPage({super.key});

  @override
  State<OnBoardingPage> createState() => _OnBoardingPageState();
}

List<Widget> pages = [
  PageView1(
    image: 'assets/onBoarding/ob2.png',
    title: 'Start your journey',
    subTitle:
    'You can start your journey in the field you love, no need to be afraid of getting lost, we will help you reach the finish line',
  ),
  PageView1(
    image: 'assets/onBoarding/ob3.png',
    title: 'You can be anything, the world is in your hands',
    subTitle:
    'By learning & increasing knowledge you will become a wise person and can change things around you and even the world',
  ),
  PageView1(
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
        isLastPage = _pageController.page!.round() == pages.length - 1;
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose() ;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PAGEVIEW
          PageView(
            controller: _pageController,
            children: pages,
          ),

          // PAGE INDICATOR
          Positioned(
            bottom: 170,
            left: 0,
            right: 0,
            child: Center(
              child: SmoothPageIndicator(
                controller: _pageController,
                count: pages.length,
                effect: WormEffect(
                  dotHeight: 10,
                  dotWidth: 10,
                  spacing: 10,
                  activeDotColor: Colors.white,
                  dotColor: Colors.grey.shade800,
                ),
              ),
            ),
          ),

          // MORPHING BUTTON (arrow → full button)
          Positioned(
            bottom: 40,
            right: 25,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.fastOutSlowIn,
              width: isLastPage ? 360 : 60,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  if (!isLastPage) {
                    _pageController.nextPage(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut,
                    );
                  } else {
                    print("Get Started Pressed!");
                  }
                },
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, anim) =>
                      FadeTransition(opacity: anim, child: child),
                  child: isLastPage
                      ? Text(
                    "Get Started",
                    key: const ValueKey('text'),
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontFamily: AppFontStrings.pjsBold,
                    ),
                  )
                      : Icon(
                    Icons.arrow_forward_rounded,
                    key: const ValueKey('icon'),
                    color: Colors.black,
                    size: 28,
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
