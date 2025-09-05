import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/presentation/admin/admin_dashboard.dart';
import 'package:eytaxi/features/auth/presentation/login/login_screen.dart';
import 'package:eytaxi/features/auth/presentation/registro/register_screen.dart';
import 'package:eytaxi/features/home/presentation/pages/home_screen.dart';
import 'package:eytaxi/features/driver/presentation/home/driver_home.dart';
import 'package:eytaxi/features/driver/presentation/status/pending_driver_screen.dart';
import 'package:eytaxi/features/driver/presentation/status/rejected_driver_screen.dart';
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
  // Administrador
  static const String admin = '/admin';
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    // redirect: (context, state) {
    //   final user = Supabase.instance.client.auth.currentUser;

    //   // Si estoy en splash, no redirijo todavía
    //   if (state.matchedLocation == splash) {
    //     return null;
    //   }

    //   // Usuario no logueado → solo puede entrar a login/register
    //   if (user == null) {
    //     final isAuthPage =
    //         state.matchedLocation == login || state.matchedLocation == register;
    //     return isAuthPage ? null : home;
    //   }

    //   // Si el usuario está logueado y quiere ir a login/register → mándalo a home
    //   if (user != null &&
    //       (state.matchedLocation == login ||
    //           state.matchedLocation == register)) {
    //     return home;
    //   }

    //   // Aquí puedes verificar el rol o estado del conductor desde la base de datos
    //   // Ejemplo (pseudo):
    //   // final role = await getRole(user.id);
    //   // if (role == 'pending') return pendingDriver;
    //   // if (role == 'rejected') return rejectedDriver;

    //   return null; // No redirigir
    // },
    routes: [
      GoRoute(path: splash, builder: (context, state) => SplashScreen()),
      GoRoute(path: home, builder: (context, state) => HomeScreen()),

      GoRoute(path: login, builder: (context, state) => const LoginScreen()),
      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // Nuevas rutas para conductor
      GoRoute(
        path: driverHome,
        builder: (context, state) => const DriverHome(),
      ),
      GoRoute(
        path: pendingdriver,
        builder: (context, state) => const PendingDriverScreen(),
      ),
      GoRoute(
        path: rejectedDriver,
        builder: (context, state) => const RejectedDriverScreen(),
      ),

      GoRoute(
        path: register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: admin,
        builder: (context, state) => const AdminDashboard(),
      ),

      // Agrega más rutas aquí según lo necesites
    ],
    errorBuilder:
        (context, state) =>
            const Scaffold(body: Center(child: Text('Página no encontrada'))),
  );
}
