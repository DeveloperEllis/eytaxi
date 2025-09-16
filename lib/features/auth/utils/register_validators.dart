import 'dart:typed_data';

import 'package:eytaxi/core/utils/validators.dart';

class RegisterValidators {
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su contraseña';
    }
    if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe tener al menos una mayúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe tener al menos una minúscula';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Debe tener al menos un número';
    }
    if (!RegExp(r'[!@#\$&*~._-]').hasMatch(value)) {
      return 'Debe tener al menos un carácter especial';
    }
    return null;
  }

  static String? validateConfirmPassword(String? value, String password) {
    if (value == null || value.isEmpty) {
      return 'Confirme su contraseña';
    }
    if (value != password) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  static String? validateDriverInfo(
    String? license,
    String? vehicleCapacity,
    List<String> routes,
    bool viajesLocales,
  ) {
    final licenseError = Validators.validateLicenseNumber(license);
    if (licenseError != null) {
      return licenseError;
    }

    final capacityError = Validators.validateVehicleCapacity(vehicleCapacity);
    if (capacityError != null) {
      return capacityError;
    }

    if (routes.isEmpty && !viajesLocales) {
      return 'Seleccione al menos una ruta o active la opción de viajes locales';
    }

    return null;
  }

  static String? validateProfilePhoto(Uint8List? value) {
    if (value == null || value.isEmpty) {
      return 'Suba una foto de perfil';
    }
    return null;
  }

  static String? validateVehiclePhoto(Uint8List? value) {
    if (value == null || value.isEmpty) {
      return 'Suba una foto del vehículo';
    }
    return null;
  }
}
