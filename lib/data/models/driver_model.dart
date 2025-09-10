import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/data/models/user_model.dart';

class Driver extends User {
  final String licenseNumber;
  final String vehiclePhotoUrl;
  final int vehicleCapacity;
  final List<String> routes;
  final bool isAvailable;
  final int id_municipio_de_origen;
  final bool viajes_locales;
  final Ubicacion? origen;

  Driver({
    required super.id,
    required super.email,
    required super.nombre,
    required super.apellidos,
    required super.phoneNumber,
    required super.photoUrl,
    required this.licenseNumber,
    required this.vehiclePhotoUrl,
    required this.vehicleCapacity,
    required this.routes,
    this.isAvailable = true,
    required this.id_municipio_de_origen,
    required this.viajes_locales,
    this.origen,
  }) : super(userType: UserType.driver);

  factory Driver.fromJson(Map<String, dynamic> json) {
    // Verificar si los datos vienen de user_profiles anidados o directamente
    Map<String, dynamic> userProfileData = json['user_profiles'] ?? json;
    
    return Driver(
      id: json['id'] ?? userProfileData['id'] ?? '',
      email: userProfileData['email'] ?? '',
      nombre: userProfileData['nombre'] ?? '',
      apellidos: userProfileData['apellidos'] ?? '',
      phoneNumber: userProfileData['phone_number'] ?? '',
      photoUrl: userProfileData['photo_url'] ?? '',
      licenseNumber: json['license_number'] ?? '',
      vehiclePhotoUrl: json['vehicle_photo_url'] ?? '',
      vehicleCapacity: json['vehicle_capacity'] ?? 0,
      routes: (json['routes'] is List)
          ? List<String>.from(json['routes'])
          : <String>[],
      isAvailable: json['is_available'] ?? true,
      id_municipio_de_origen: json['id_municipio_de_origen'] ?? 0,
      viajes_locales: json['viajes_locales'] ?? true,
      origen: json['origen'] != null ? Ubicacion.fromJson(json['origen'] as Map<String, dynamic>) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'nombre': nombre,
      'apellidos': apellidos,
      'phone_number': phoneNumber,
      'user_type': userType.toString(),
      'photo_url': photoUrl,
      'license_number': licenseNumber,
      'vehicle_photo_url': vehiclePhotoUrl,
      'vehicle_capacity': vehicleCapacity,
      'routes': routes,
      'is_available': isAvailable,
      'id_municipio_de_origen': id_municipio_de_origen,
      'viajes_locales': viajes_locales,
    };
  }
}