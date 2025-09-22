import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:eytaxi/features/driver/data/datasources/driver_profile_remote_datasource.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;
  late final DriverProfileRemoteDataSource _driverDataSource;

  AuthRepositoryImpl(this.remoteDataSource) {
    _driverDataSource = DriverProfileRemoteDataSource(Supabase.instance.client);
  }

  Stream<AuthState> get authStateChanges => remoteDataSource.authStateChanges;

  Future<AuthResponse> signUp(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) {
    return remoteDataSource.signUp(email, password, data: data);
  }

  Future<bool> checkIfUserExists(String email, String phone) async {
    try {
      final response = await remoteDataSource.client
          .from('user_profiles')
          .select('id')
          .or('email.eq.$email,phone_number.eq.$phone')
          .limit(1);
      final exists = response.isNotEmpty;
      return exists;
    } catch (e) {
      return false;
    }
  }

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      print('DEBUG: Iniciando signInWithPassword');
      final response = await remoteDataSource.signInWithPassword(email, password);
      final user = await Supabase.instance.client.auth.currentUser;
      
      print('DEBUG: Login exitoso, usuario: ${user?.id}');

      // Intentar configurar Firebase Messaging (no crítico)
      String? token;
      try {
        print('DEBUG: Solicitando permisos de Firebase Messaging');
        await FirebaseMessaging.instance.requestPermission();
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        token = await messaging.getToken();
        print('DEBUG: FCM token obtenido: ${token != null ? "Sí" : "No"}');
      } catch (firebaseError) {
        print('WARNING: Error al configurar Firebase Messaging (no crítico): $firebaseError');
        // No rethrow - esto no debe impedir el login
      }

      // Actualizar FCM token si está disponible
      if (user != null && token != null) {
        try {
          await Supabase.instance.client
              .from('user_profiles')
              .update({'fcm_token': token})
              .eq('id', user.id);
          print('DEBUG: FCM token actualizado para el usuario ${user.id}');
        } catch (updateError) {
          print('WARNING: Error al actualizar FCM token (no crítico): $updateError');
          // No rethrow - esto no debe impedir el login
        }
      }

      print('DEBUG: signInWithPassword completado exitosamente');
      return response;
    } catch (e) {
      print('ERROR: signInWithPassword falló: $e');
      rethrow; // Re-throw para que sea manejado por el catch de login_screen
    }
  }

  Future<void> handlePostLoginRedirection() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('DEBUG: No user found after login');
      return;
    }

    try {
      print('DEBUG: Checking user type and status for user: ${user.id}');

      // Primero verificar el tipo de usuario (admin o driver)
      final userProfileResponse = await remoteDataSource.client
          .from('user_profiles')
          .select('user_type')
          .eq('id', user.id)
          .maybeSingle();

      final userType = userProfileResponse?['user_type'] as String?;
      print('DEBUG: User type: $userType');

      // Si es admin, redirigir al panel de administración
      if (userType == 'admin') {
        print('DEBUG: User is admin, redirecting to admin dashboard');
        try {
          AppRoutes.router.go(AppRoutes.admin);
          return;
        } catch (routeError) {
          print('ERROR: Failed to navigate to admin: $routeError');
          return;
        }
      }

      // Si es driver o no tiene tipo definido, verificar estado del conductor
      final driverStatus = await _driverDataSource.getDriverStatus(user.id);
      print('DEBUG: Driver status: $driverStatus');

      if (driverStatus == null) {
        // El usuario no está registrado como conductor, dirigir al driverHome normal
        print('DEBUG: User is not a driver, redirecting to driverHome');
        try {
          AppRoutes.router.go(AppRoutes.driverHome);
          return;
        } catch (routeError) {
          print('ERROR: Failed to navigate to driverHome: $routeError');
          return;
        }
      }

      // Manejar los diferentes estados del conductor
      switch (driverStatus.toLowerCase()) {
        case 'pending':
          print('DEBUG: Driver status is pending, showing pending screen');
          try {
            AppRoutes.router.go(AppRoutes.pendingdriver);
            signOut();
          } catch (routeError) {
            print('ERROR: Failed to navigate to pending screen: $routeError');
          }
          break;
        case 'rejected':
          print('DEBUG: Driver status is rejected, showing rejected screen');
          try {
            AppRoutes.router.go(AppRoutes.rejectedDriver);
            signOut();
          } catch (routeError) {
            print('ERROR: Failed to navigate to rejected screen: $routeError');
          }
          break;
        case 'approved':
          print(
            'DEBUG: Driver status is approved/active, redirecting to driver home',
          );
          try {
            AppRoutes.router.go(AppRoutes.driverHome);
          } catch (routeError) {
            print('ERROR: Failed to navigate to driver home: $routeError');
          }
          break;
        default:
          // Estado desconocido, dirigir al driverHome por defecto
          print(
            'DEBUG: Unknown driver status: $driverStatus, redirecting to driverHome',
          );
          try {
            AppRoutes.router.go(AppRoutes.driverHome);
          } catch (routeError) {
            print('ERROR: Failed to navigate to driverHome (default): $routeError');
          }
      }
    } catch (e) {
      print('ERROR: Exception in handlePostLoginRedirection: $e');
      print('ERROR: Stack trace: ${StackTrace.current}');
      // En caso de error, dirigir al driverHome por defecto
      try {
        AppRoutes.router.go(AppRoutes.driverHome);
      } catch (routeError) {
        print('ERROR: Failed to navigate to driverHome: $routeError');
      }
    }
  }

  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
