import 'dart:io';
import 'dart:typed_data';
import 'package:eytaxi/core/services/storage_service.dart';
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/features/driver/domain/repositories/driver_profile_repository.dart';
import 'package:flutter/foundation.dart';

class DriverProfileViewModel extends ChangeNotifier {
  final DriverProfileRepository repo;
  final StorageService storage;
  final String userId;

  DriverProfileViewModel({
    required this.repo,
    required this.storage,
    required this.userId,
  });

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  Map<String, dynamic>? _userProfile;
  Map<String, dynamic>? get userProfile => _userProfile;

  Driver? _driver;
  Driver? get driver => _driver;

  void _setLoading(bool value) {
    _loading = value;
    notifyListeners();
  }

  void _setError(String? error) {
    _error = error;
    notifyListeners();
  }

  Future<void> load() async {
    if (userId.isEmpty) {
      _setError('Usuario no válido');
      return;
    }

    _setLoading(true);
    _setError(null);

    try {
      final (userProfile, driver) = await repo.fetchProfile(userId);
      _userProfile = userProfile;
      _driver = driver;
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar el perfil: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> updateProfile({
    String? nombre,
    String? apellidos,
    String? phoneNumber,
  }) async {
    try {
      final success = await repo.updateUserProfile(
        userId,
        nombre: nombre,
        apellidos: apellidos,
        phoneNumber: phoneNumber,
      );
      
      if (success) {
        // Recargar el perfil para obtener los datos actualizados
        await load();
      }
      
      return success;
    } catch (e) {
      _setError('Error al actualizar el perfil: ${e.toString()}');
      return false;
    }
  }

  Future<bool> changePhoto({File? file, Uint8List? webBytes}) async {
    try {
      String? photoUrl;
      
      if (webBytes != null) {
        // Subir desde web
        photoUrl = await storage.uploadImage(
          imageData: webBytes,
          userId: userId,
          type: 'profile',
        );
      } else if (file != null) {
        // Subir desde móvil
        photoUrl = await storage.uploadImage(
          imageData: file,
          userId: userId,
          type: 'profile',
        );
      }
      
      if (photoUrl == null) return false;
      
      final success = await repo.updateProfilePhoto(userId, photoUrl);
      
      if (success) {
        // Actualizar localmente
        _userProfile?['photo_url'] = photoUrl;
        notifyListeners();
      }
      
      return success;
    } catch (e) {
      _setError('Error al cambiar la foto: ${e.toString()}');
      return false;
    }
  }

  Future<bool> changeVehiclePhoto({File? file, Uint8List? webBytes}) async {
    try {
      String? photoUrl;
      
      if (webBytes != null) {
        // Subir desde web
        photoUrl = await storage.uploadImage(
          imageData: webBytes,
          userId: userId,
          type: 'vehicle',
        );
      } else if (file != null) {
        // Subir desde móvil
        photoUrl = await storage.uploadImage(
          imageData: file,
          userId: userId,
          type: 'vehicle',
        );
      }
      
      if (photoUrl == null) return false;
      
      final success = await repo.updateVehiclePhoto(userId, photoUrl);
      
      if (success) {
        // Recargar para obtener los datos actualizados
        await load();
      }
      
      return success;
    } catch (e) {
      _setError('Error al cambiar la foto del vehículo: ${e.toString()}');
      return false;
    }
  }

  Future<bool> updateDriverInfo({
    String? licenseNumber,
    int? vehicleCapacity,
    List<String>? routes,
    bool? isAvailable,
    int? idMunicipioDeOrigen,
    bool? viajesLocales,
  }) async {
    try {
      final success = await repo.updateDriverInfo(
        userId,
        licenseNumber: licenseNumber,
        vehicleCapacity: vehicleCapacity,
        routes: routes,
        isAvailable: isAvailable,
        idMunicipioDeOrigen: idMunicipioDeOrigen,
        viajesLocales: viajesLocales,
      );
      
      if (success) {
        // Recargar para obtener los datos actualizados
        await load();
      }
      
      return success;
    } catch (e) {
      _setError('Error al actualizar información del conductor: ${e.toString()}');
      return false;
    }
  }

  void clearError() {
    _setError(null);
  }
}
