import 'package:flutter/material.dart';
import 'package:RevMate/views/main/main_page.dart';
import 'package:RevMate/views/reservation/available_times_page.dart';
import 'package:RevMate/views/reservation/deadline_page.dart';
import 'package:RevMate/views/reservation/reserve_page.dart';
import 'package:RevMate/views/reservation/revised_page.dart';
import 'package:RevMate/views/main/status_page.dart';
import 'package:RevMate/views/login/login_page.dart';
import 'package:RevMate/views/widgets/animated_page_route.dart';

class AppRoutes {
  static const String mainPage = '/main';
  static const String availableTimesPage = '/availableTimes';
  static const String deadlinePage = '/deadline';
  static const String reservePage = '/reserve';
  static const String revisedPage = '/revised';
  static const String statusPage = '/status';
  static const String loginPage = '/login';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case mainPage:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case availableTimesPage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => AvailableTimesPage(
            equipment: args['equipment'],
            duration: args['duration'],
          ),
        );
      case deadlinePage:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          builder: (_) => DeadlineWidget(
            equipment: args['equipment'],
            ocrText: args['ocrText'],
          ),
        );
      case reservePage:
        return MaterialPageRoute(builder: (_) => const ReservePage());
      case revisedPage:
        final equipment = settings.arguments as String;
        return MaterialPageRoute(
          builder: (_) => RevisedPage(equipment: equipment),
        );
      case statusPage:
        return animatedPageRoute(page: StatusPage());
      case loginPage:
        return MaterialPageRoute(builder: (_) => LoginPage());
      default:
        return MaterialPageRoute(builder: (_) => const MainPage());
    }
  }
}
