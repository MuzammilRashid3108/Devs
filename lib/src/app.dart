import 'package:devs/src/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'core/theme/theme.dart';

class DevsApp extends StatelessWidget {
  const DevsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.system,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      routerConfig: appRoutes,
    );
  }
}
