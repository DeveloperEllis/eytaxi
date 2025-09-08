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
    
    String? token;
    
    if (!kIsWeb) {
      // Solicitar permisos para notificaciones en iOS
      await FirebaseMessaging.instance.requestPermission();
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      token = await messaging.getToken();
    }

    final user = Supabase.instance.client.auth.currentUser;
    final response = await remoteDataSource.signInWithPassword(email, password);

    if (!kIsWeb && user != null && token != null) {
      // Actualizar el campo fcmtoken en user_profiles
      final response = await Supabase.instance.client
          .from('user_profiles')
          .update({'fcm_token': token})
          .eq('id', user.id);
      if (response != null) {
        print('FCM token updated for user ${user.id}: $token');
      }
    }

    return response;
  }

  Future<void> handlePostLoginRedirection() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      print('DEBUG: No user found after login');
      return;
    }

    try {
      print('DEBUG: Checking driver status for user: ${user.id}');
      
      // Verificar el estado del conductor
      final driverStatus = await _driverDataSource.getDriverStatus(user.id);
      
      print('DEBUG: Driver status: $driverStatus');
      
      if (driverStatus == null) {
        // El usuario no está registrado como conductor, dirigir al driverHome normal
        print('DEBUG: User is not a driver, redirecting to driverHome');
        AppRoutes.router.go(AppRoutes.driverHome);
        return;
      }

      // Manejar los diferentes estados del conductor
      switch (driverStatus.toLowerCase()) {
        case 'pending':
          print('DEBUG: Driver status is pending, showing pending screen');
          AppRoutes.router.go(AppRoutes.pendingdriver);
          signOut();
          break;
        case 'rejected':
          print('DEBUG: Driver status is rejected, showing rejected screen');
          AppRoutes.router.go(AppRoutes.rejectedDriver);
          signOut();
          break;
        case 'approved':
          print('DEBUG: Driver status is approved/active, redirecting to driver home');
          AppRoutes.router.go(AppRoutes.driverHome);
          break;
        default:
          // Estado desconocido, dirigir al driverHome por defecto
          print('DEBUG: Unknown driver status: $driverStatus, redirecting to driverHome');
          AppRoutes.router.go(AppRoutes.driverHome);
      }
    } catch (e) {
      print('Error checking driver status: $e');
      // En caso de error, dirigir al driverHome por defecto
      AppRoutes.router.go(AppRoutes.driverHome);
    }
  }

  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
