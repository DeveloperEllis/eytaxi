import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/features/admin/admin_dashboard.dart';
import 'package:eytaxi/features/admin/presentation/screens/accepted_requests_screen.dart';
import 'package:eytaxi/features/admin/presentation/screens/all_requests_screen.dart';
import 'package:eytaxi/features/admin/presentation/screens/attend_request_screen.dart';
import 'package:eytaxi/features/admin/presentation/screens/in_progress_requests_screen.dart';
import 'package:eytaxi/features/admin/presentation/screens/pending_requests_screen.dart';
import 'package:eytaxi/features/auth/presentation/login/login_screen.dart';
import 'package:eytaxi/features/auth/presentation/registro/register_screen.dart';
import 'package:eytaxi/features/home/presentation/pages/home_screen.dart';
import 'package:eytaxi/features/driver/presentation/home/driver_home.dart';
import 'package:eytaxi/features/driver/presentation/status/pending_driver_screen.dart';
import 'package:eytaxi/features/driver/presentation/status/rejected_driver_screen.dart';
import 'package:eytaxi/features/splashscreen/splash_screen.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
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
  static const String all_requests = '/admin/all_request';
  static const String pending_requests = '/admin/pending_requests';
  static const String accepted_requests= '/admin/accepted_requests';
  static const String in_progress_requests = '/admin/in_progres_requests';
  static const String attend_request = '/admin/attend_request';
  static final GoRouter router = GoRouter(
    initialLocation: splash,
    redirect: (context, state) async {
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
      
      // Verificar acceso a rutas de administrador
      final adminRoutes = [admin, all_requests, pending_requests, accepted_requests, in_progress_requests, attend_request];
      if (adminRoutes.contains(currentLocation)) {
        try {
          final userProfile = await Supabase.instance.client
              .from('user_profiles')
              .select('user_type')
              .eq('id', user.id)
              .maybeSingle();
          
          final userType = userProfile?['user_type'] as String?;
          print('DEBUG ROUTER: User type for admin route check: $userType');
          
          if (userType != 'admin') {
            print('DEBUG ROUTER: Usuario no autorizado para ruta de admin, redirigiendo a driverHome');
            return driverHome; // Redirigir a driverHome si no es admin
          }
        } catch (e) {
          print('DEBUG ROUTER: Error verificando tipo de usuario: $e');
          return driverHome; // En caso de error, redirigir a driverHome por seguridad
        }
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

      //admin
      GoRoute( path: all_requests,
        builder: (context, state) => const AllRequestsScreen(),
      ),
      GoRoute( path: pending_requests,
        builder: (context, state) => const PendingRequestsScreen(),
      ),
      GoRoute( path: accepted_requests,
        builder: (context, state) => const AcceptedRequestsScreen(),
      ),
      GoRoute( path: in_progress_requests,
        builder: (context, state) => const InProgressRequestsScreen(),
      ),
      GoRoute(
        path: attend_request,
        builder: (context, state) {
          final request = state.extra as TripRequest?;
          if (request == null) {
            return const Scaffold(
              body: Center(child: Text('Error: No se recibió la solicitud')),
            );
          }
          return AttendRequestScreen(request: request);
        },
      ),


      // Agrega más rutas aquí según lo necesites
    ],
    errorBuilder:
        (context, state) =>
            const Scaffold(body: Center(child: Text('Página no encontrada'))),
  );

}
