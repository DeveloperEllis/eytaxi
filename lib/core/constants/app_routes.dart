import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/presentation/auth/login_screen.dart';
import 'package:eytaxi/presentation/auth/register_screen.dart';
import 'package:eytaxi/presentation/common/home_screen.dart';
import 'package:eytaxi/presentation/driver/home/driver_home.dart';
import 'package:eytaxi/presentation/driver/status/pending_driver_screen.dart';
import 'package:eytaxi/presentation/driver/status/rejected_driver_screen.dart';
import 'package:eytaxi/presentation/splashscreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Importa más pantallas aquí según las vayas creando
final ThemeNotifier themeNotifier = ThemeNotifier();

class AppRoutes {
  static const String splash = '/';
  static const String home = '/home';
  static const String tripAceptedPage = '/trip-acepted';
  static const String login = '/login';
  static const String register = '/register';
  // Nuevas rutas para conductor
  static const String driverHome = '/driverhome';
  static const String confirmtrip = '/driver/trips';
  static const String historytrip = '/driver/historytrip';
  static const String driverProfile = '/driver/profile';
  static const String pendingdriver = '/driver/pending';
  static const String rejectedDriver = '/driver/rejected';

  static final GoRouter router = GoRouter(
    initialLocation: splash,
    routes: [

      GoRoute(path: splash, builder: (context, state) => SplashScreen()),
      GoRoute(path: home, builder: (context, state) => HomeScreen()),

      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(path: register, builder: (context, state) => const RegisterScreen()),
      
      // Nuevas rutas para conductor
      GoRoute(path: driverHome, builder: (context, state)=> const DriverHome()),
      GoRoute(path: pendingdriver, builder: (context, state) => const PendingDriverScreen()),
      GoRoute(path: rejectedDriver, builder: (context, state) => const RejectedDriverScreen()),
      
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Agrega más rutas aquí según lo necesites
    ],
    errorBuilder:
        (context, state) =>
            const Scaffold(body: Center(child: Text('Página no encontrada'))),
  );
}
