import 'package:devs/src/features/welcome/wiedgets/social_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

import '../../../core/common/constants/app_colors.dart';
import '../../auth/services/auth_services.dart';
import '../../home/presentation/pages/home_page.dart';

class AuthButtons extends StatefulWidget {
  const AuthButtons({super.key});

  @override
  State<AuthButtons> createState() => _AuthButtonsState();
}

class _AuthButtonsState extends State<AuthButtons>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = Palette.of(context); // your shared palette

    return FadeSlide(
      ctrl: _ctrl,
      delay: 0.5,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          SocialButton(
            label: "GOOGLE",
            color: AppColors.googleButton,
            palette: p,
            onTap: () async {
              try {
                final user = await AuthService().signInWithGoogle();
                if (user != null && context.mounted) {
                  context.go('/home');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Error: $e")),
                  );
                }
              }
            },
          ),
          SizedBox(width: 16.w),
          SocialButton(
            label: "FACEBOOK",
            color: AppColors.facebookButton,
            palette: p,
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

