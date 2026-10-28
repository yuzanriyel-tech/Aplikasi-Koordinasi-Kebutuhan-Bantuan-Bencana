import 'package:flutter/material.dart';

import '../models/item.dart';
import '../models/posko_location.dart';
import '../screens/catatan_form_screen.dart';
import '../screens/detail_screen.dart';
import '../screens/home_screen.dart';
import '../screens/landing_screen.dart';
import '../screens/login_screen.dart';
import '../screens/map_picker_screen.dart';
import '../screens/not_found_screen.dart';
import '../screens/queue_screen.dart';
import '../screens/register_screen.dart';
import '../screens/requirement_form_screen.dart';
import '../screens/requirement_list_screen.dart';
import '../screens/riwayat_laporan_page.dart';
import '../screens/daftar_penyaluran_screen.dart';
class AppRoutes {
  AppRoutes._();

  static const String landing = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String map = '/map';
  static const String home = '/home';
  static const String requirements = '/requirements';
  static const String requirementInput = '/requirements/new';
  static const String requirementEdit = '/requirements/edit';
  static const String queue = '/queue';
  static const String history = '/history';
  static const String distribution = '/distribution';
  static const String detail = '/detail';
  static const String catatanForm = '/catatan-form';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case landing:
        return _page<void>(settings, const LandingScreen());
      case login:
        return _page<void>(settings, const LoginScreen());
      case register:
        return _page<void>(settings, const RegisterScreen());
      case map:
        final args = settings.arguments;
        return _page<PoskoLocation>(
          settings,
          MapPickerScreen(
            initial: args is PoskoLocation ? args : PoskoLocation.fallback,
          ),
        );
      case home:
        return _page<void>(settings, const HomeScreen());
      case requirements:
        return _page<void>(settings, const RequirementListScreen());
      case requirementInput:
        return _page<bool>(settings, const RequirementFormScreen());
      case requirementEdit:
        final args = settings.arguments;
        if (args is Item) {
          return _page<bool>(settings, RequirementFormScreen(item: args));
        }
        return null;
      case queue:
        return _page<void>(settings, const QueueScreen());
      case history:
        return _page<void>(settings, const RiwayatLaporanPage());
              case distribution:
          return _page<void>(settings, const DaftarPenyaluranScreen());
      case detail:
        final args = settings.arguments;
        if (args is Item) {
          return _page<void>(settings, DetailScreen(item: args));
        }
        return null;
      case catatanForm:
        return _page<String>(settings, const CatatanFormScreen());
      default:
        return null;
    }
  }

  static Route<dynamic> onUnknownRoute(RouteSettings settings) {
    return MaterialPageRoute<void>(
      builder: (_) => NotFoundScreen(routeName: settings.name),
      settings: settings,
    );
  }

  static MaterialPageRoute<T> _page<T>(RouteSettings settings, Widget page) {
    return MaterialPageRoute<T>(builder: (_) => page, settings: settings);
  }
}
