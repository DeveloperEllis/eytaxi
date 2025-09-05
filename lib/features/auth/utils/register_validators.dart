import 'dart:typed_data';


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

  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su correo electrónico';
    }
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
      return 'Ingrese un correo electrónico válido';
    }
    return null;
  }

  static String? validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su número de teléfono';
    }
    if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(value)) {
      return 'Ingrese un número de teléfono válido';
    }
    return null;
  }

  static String? validateVehicleCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese la capacidad del vehículo';
    }
    if (!RegExp(r'^[1-9]\d*$').hasMatch(value)) {
      return 'Ingrese un número válido';
    }
    return null;
  }

  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su $fieldName';
    }
    return null;
  }
  

  static String? validateDriverInfo(String? license, String? vehicleCapacity, List<String> routes, bool viajesLocales) {
    final licenseError = validateNonEmpty(license, 'licencia');
    if (licenseError != null) {
      return licenseError;
    }

    final capacityError = validateVehicleCapacity(vehicleCapacity);
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