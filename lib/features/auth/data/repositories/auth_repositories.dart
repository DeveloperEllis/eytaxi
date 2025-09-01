import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl {
  final AuthRemoteDataSource remoteDataSource;

  AuthRepositoryImpl(this.remoteDataSource);

  @override
  Stream<AuthState> get authStateChanges => remoteDataSource.authStateChanges;

  @override
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
      final exists = response != null && response.isNotEmpty;
      return exists;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthResponse> signInWithPassword(String email, String password) async {
    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    final response = await remoteDataSource.signInWithPassword(email, password);
    final user = Supabase.instance.client.auth.currentUser;

    if (user != null && token != null) {
      // Actualizar el campo fcmtoken en user_profiles
      final response = await Supabase.instance.client
          .from('user_profiles')
          .update({'fcm_token': token})
          .eq('id', user.id);
      if (response != null) {
        print('FCM token updated for user ${user.id}: $token');
      }
    }

    AppRoutes.router.go(AppRoutes.driverHome);
    return response;
  }

  @override
  Future<void> signOut() {
    return remoteDataSource.signOut();
  }
}
