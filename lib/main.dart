import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_page.dart';
import 'admin_profile.dart';
import 'user_management.dart';
import 'graphs_page.dart';
import 'analytics_page.dart';
import 'survey_page.dart';

void main() {
  // In debug mode, ensure common debug paint overlays are turned off.
  // This runs only in debug (asserts are disabled in release/profile builds).
  assert(() {
    debugPaintSizeEnabled = false;
    debugPaintBaselinesEnabled = false;
    debugPaintPointersEnabled = false;
    debugPaintLayerBordersEnabled = false;
  debugRepaintRainbowEnabled = false;
    return true;
  }());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
  Route<dynamic> buildRoute(RouteSettings settings) {
      Widget page;
      switch (settings.name) {
        case '/':
          page = const LoginPage();
          break;
        case '/admin/profile':
          page = const AdminProfilePage();
          break;
        case '/admin/users':
          page = const UserManagementPage();
          break;
        case '/admin/graphs':
          page = const GraphsPage();
          break;
        case '/admin/survey':
          page = const SurveyPage();
          break;
        case '/admin/analytics':
          page = const AnalyticsPage();
          break;
        default:
          page = const LoginPage();
      }

      return PageRouteBuilder(
        settings: settings,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, animation, secondaryAnimation) => page,
        transitionsBuilder: (_, animation, secondaryAnimation, child) {
          // Simple fade transition
          final fadeAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);
          return FadeTransition(opacity: fadeAnimation, child: child);
        },
      );
    }

    return MaterialApp(
      title: 'ARTA ADMIN',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: false,
        // Set Poppins as the default app font. Individual widgets can
        // still override this (e.g. the left header uses Racing Sans One).
        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),
      ),
      initialRoute: '/',
  onGenerateRoute: (settings) => buildRoute(settings),
      debugShowCheckedModeBanner: false,
    );
  }
}