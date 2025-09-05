import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/features/driver/data/datasources/driver_profile_remote_datasource.dart';
import 'package:eytaxi/features/driver/domain/repositories/driver_profile_repository.dart';

class DriverProfileRepositoryImpl implements DriverProfileRepository {
  final DriverProfileRemoteDataSource remote;
  DriverProfileRepositoryImpl(this.remote);

  @override
  Future<(Map<String, dynamic> userProfile, Driver? driver)> fetchProfile(String userId) {
    return remote.fetchProfile(userId);
  }

  @override
  Future<bool> updateProfilePhoto(String userId, String photoUrl) {
    return remote.updateProfilePhoto(userId, photoUrl);
  }

  @override
  Future<bool> updateUserProfile(String userId, {String? nombre, String? apellidos, String? phoneNumber}) {
    return remote.updateUserProfile(userId, nombre: nombre, apellidos: apellidos, phoneNumber: phoneNumber);
  }

  @override
  Future<bool> updateDriverInfo(
    String userId, {
    String? licenseNumber,
    int? vehicleCapacity,
    List<String>? routes,
    bool? isAvailable,
    int? idMunicipioDeOrigen,
    bool? viajesLocales,
    String? vehiclePhotoUrl,
  }) {
    return remote.updateDriverInfo(
      userId,
      licenseNumber: licenseNumber,
      vehicleCapacity: vehicleCapacity,
      routes: routes,
      isAvailable: isAvailable,
      idMunicipioDeOrigen: idMunicipioDeOrigen,
      viajesLocales: viajesLocales,
      vehiclePhotoUrl: vehiclePhotoUrl,
    );
  }

  @override
  Future<bool> updateVehiclePhoto(String userId, String photoUrl) {
    return remote.updateVehiclePhoto(userId, photoUrl);
  }
}
