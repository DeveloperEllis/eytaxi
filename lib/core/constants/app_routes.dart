import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/features/admin/admin_dashboard.dart';
import 'package:eytaxi/features/auth/presentation/login/login_screen.dart';
import 'package:eytaxi/features/auth/presentation/registro/register_screen.dart';
import 'package:eytaxi/features/home/presentation/pages/home_screen.dart';
import 'package:eytaxi/features/driver/presentation/home/driver_home.dart';
import 'package:eytaxi/features/driver/presentation/status/pending_driver_screen.dart';
import 'package:eytaxi/features/driver/presentation/status/rejected_driver_screen.dart';
import 'package:eytaxi/features/splashscreen/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final currentLocation = state.matchedLocation;

      print('DEBUG ROUTER: Current location: $currentLocation, User: ${user?.id}');

      // Si estoy en splash, no redirijo todavía
      if (currentLocation == splash) {
        return null;
      }

      // Rutas públicas (accesibles sin autenticación)
      final publicRoutes = [home, login, register];
      
      // Usuario no autenticado
      if (user == null) {
        // Solo puede acceder a rutas públicas
        if (publicRoutes.contains(currentLocation)) {
          return null; // Permitir acceso
        } else {
          print('DEBUG ROUTER: Usuario no autenticado intentando acceder a $currentLocation, redirigiendo a home');
          return home; // Redirigir a home si intenta acceder a rutas protegidas
        }
      }

      // Usuario autenticado (user != null)
      // Si intenta acceder a login o register, redirigir a driverHome
      if (currentLocation == login || currentLocation == register) {
        print('DEBUG ROUTER: Usuario autenticado intentando acceder a auth, redirigiendo a driverHome');
        return driverHome;
      }
      
      // Para otras rutas, permitir acceso (el repositorio maneja la lógica específica de estado del conductor)
      return null;
    },
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
