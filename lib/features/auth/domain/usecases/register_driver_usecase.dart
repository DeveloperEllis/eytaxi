import 'dart:io';
import 'dart:typed_data';
import 'package:eytaxi/features/auth/data/repositories/auth_repositories.dart';
import 'package:eytaxi/core/services/storage_service.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/core/services/supabase_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/foundation.dart'; // Para debugPrint

class RegisterDriverParams {
  final String email;
  final String password;
  final String nombre;
  final String apellidos;
  final String phone;
  final String licenseNumber;
  final String vehicleCapacity;
  final List<String> routes;
  final bool viajesLocales;
  final Ubicacion? municipio;
  final Uint8List? profilePhotoBytes;
  final Uint8List? vehiclePhotoBytes;
  final File? profilePhotoFile;
  final File? vehiclePhotoFile;

  RegisterDriverParams({
    required this.email,
    required this.password,
    required this.nombre,
    required this.apellidos,
    required this.phone,
    required this.licenseNumber,
    required this.vehicleCapacity,
    required this.routes,
    required this.viajesLocales,
    required this.municipio,
    this.profilePhotoBytes,
    this.vehiclePhotoBytes,
    this.profilePhotoFile,
    this.vehiclePhotoFile,
  });
}

class RegisterDriverUseCase {
  final AuthRepositoryImpl authRepository;
  final StorageService storageService;
  final SupabaseService supabaseService;

  RegisterDriverUseCase({
    required this.authRepository,
    required this.storageService,
    required this.supabaseService,
  });

  Future<String?> call(RegisterDriverParams params) async {
    try {
      final userExists = await authRepository.checkIfUserExists(
        params.email.trim(),
        params.phone.trim(),
      );
      if (userExists) {
        return 'El email o teléfono ya está registrado';
      }

      final authResponse = await authRepository.signUp(
        params.email,
        params.password,
      );
      if (authResponse.user == null) {
        return 'Error en el registro de autenticación';
      }
      final userId = authResponse.user!.id;

      // 3. Subir fotos
      final profilePhotoUrl = await storageService.uploadImage(
        imageData: kIsWeb ? params.profilePhotoBytes : params.profilePhotoFile,
        userId: userId,
        type: 'profile',
      );

      final vehiclePhotoUrl = await storageService.uploadImage(
        imageData: kIsWeb ? params.vehiclePhotoBytes : params.vehiclePhotoFile,
        userId: userId,
        type: 'vehicle',
      );

      // 4. Crear perfil y conductor en la base de datos
      final token = await FirebaseMessaging.instance.getToken();

      final userProfileInsert = await supabaseService.client.from('user_profiles').insert({
        'id': userId,
        'email': params.email.trim(),
        'nombre': params.nombre.trim(),
        'apellidos': params.apellidos.trim(),
        'phone_number': params.phone,
        'user_type': 'driver',
        'photo_url': profilePhotoUrl,
        'fcm_token': token,
      });

      final driversInsert = await supabaseService.client.from('drivers').insert({
        'id': userId,
        'license_number': params.licenseNumber.trim(),
        'vehicle_capacity': int.parse(params.vehicleCapacity),
        'routes': params.routes,
        'is_available': true,
        'driver_status': 'pending',
        'vehicle_photo_url': vehiclePhotoUrl,
        'id_municipio_de_origen': params.municipio?.id,
        'viajes_locales': params.viajesLocales,
      });

      // 5. Cerrar sesión
      await authRepository.signOut();

      // Si todo salió bien, retorna null (sin error)
      return null;
    } catch (e) {
      return e.toString();
    }
  }
}