import 'routes/app_routes.dart';
import 'package:flutter/material.dart';

import 'screens/login_screen.dart';
import 'theme/app_colors.dart';


void main() => runApp(const PoskoSyncApp());

class PoskoSyncApp extends StatelessWidget {
  const PoskoSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoskoSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary, primary: AppColors.primary),
      ),
         initialRoute: AppRoutes.login,
         onGenerateRoute: AppRoutes.onGenerateRoute,
         onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}