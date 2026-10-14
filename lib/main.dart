import 'package:flutter/material.dart';

import 'routes/app_routes.dart';
import 'state/app_state.dart';
import 'theme/app_colors.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  AppState.instance.startMonitoring(); // pantau jaringan sungguhan (FR-16)
  runApp(const PoskoSyncApp());
}

class PoskoSyncApp extends StatelessWidget {
  const PoskoSyncApp({super.key, this.initialRoute = AppRoutes.landing});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PoskoSync',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: AppColors.surface,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          primary: AppColors.primary,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.ink,
        ),
      ),
      initialRoute: initialRoute,
      onGenerateRoute: AppRoutes.onGenerateRoute,
      onUnknownRoute: AppRoutes.onUnknownRoute,
    );
  }
}
