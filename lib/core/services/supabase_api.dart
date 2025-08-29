import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/enum/Driver_status_enum.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseApi {
  final SupabaseClient _client = Supabase.instance.client;

  SupabaseClient get client => _client;

  // --- Authentication ---

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<AuthResponse> signUp(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: data, // For additional user metadata like name, phone
      );
      return response;
    } catch (e) {
      // Consider more specific error handling
      throw Exception('Signup failed: ${e.toString()}');
    }
  }

  Future<AuthResponse> signInWithPassword(String email, String password) async {
    try {
      return await Supabase.instance.client.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } on AuthException catch (e) {
      print(
        'SupabaseApi AuthException: status=${e.statusCode}, message=${e.message}, errorCode=${e.code}',
      );
      rethrow; // Re-lanza AuthException sin envolver
    } catch (e, stackTrace) {
      print('SupabaseApi unexpected error: $e\nStackTrace: $stackTrace');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await Supabase.instance.client.auth.signOut();
    } catch (e) {
      throw Exception('Signout failed: ${e.toString()}');
    }
  }

  // --- Add other API methods for Taxi, Excursions etc. later ---
}


Future<DriverStatus?> IsPending() async {
  try {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      debugPrint('IsPending: No current user');
      return DriverStatus.pending;
    }

    debugPrint('IsPending: Querying drivers table for user ${user.id}');
    final response =
        await Supabase.instance.client
            .from('drivers')
            .select('driver_status')
            .eq('id', user.id)
            .maybeSingle();

    if (response == null) {
      debugPrint('IsPending: No profile found for user ${user.id}');
      return DriverStatus.pending;
    }

    final status = response['driver_status'] as String?;
    debugPrint('IsPending: Found driver_status: $status');

    switch (status?.toLowerCase()) {
      case 'approved':
        return DriverStatus.approved;
      case 'rejected':
        return DriverStatus.rejected;
      case 'pending':
        return DriverStatus.pending;
      default:
        debugPrint('IsPending: Unknown driver_status: $status');
        return DriverStatus.pending;
    }
  } on PostgrestException catch (e) {
    debugPrint(
      'PostgrestException in IsPending: message=${e.message}, code=${e.code}, details=${e.details}',
    );
    return DriverStatus.pending;
  } catch (e) {
    debugPrint('Unexpected error in IsPending: $e');
    return DriverStatus.pending;
  }
}

Future<void> Login(String email, String password, BuildContext context) async {
if( email != null ){
  final response = await SupabaseApi().signInWithPassword(email, password);
}
 AppRoutes.router.go(AppRoutes.driverHome);
}
