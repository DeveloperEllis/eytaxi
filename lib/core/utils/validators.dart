import 'package:eytaxi/core/utils/regex_utils.dart';
import 'package:eytaxi/features/trip_request/presentation/pages/widgets/pickup_dialog.dart';

class Validators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un correo electrónico';
    }
    if (!RegexUtils.emailRegex.hasMatch(value)) {
      return 'Ingrese un correo válido';
    }
    return null;
  }

  static String? validatePhoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un número de teléfono';
    }
    if (!RegexUtils.phoneRegex.hasMatch(value)) {
      return 'Ingrese un número válido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una contraseña';
    }
    if (!RegexUtils.passwordRegex.hasMatch(value)) {
      return 'Contraseña incorrecta';
    }
    return null;
  }

  static String? validateLicenseNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un número de licencia';
    }
    if (!RegexUtils.isValidLicenciaNumber.hasMatch(value)) {
      return 'El número de licencia no es válido';
    }
    return null;
  }

  static String? validateNonEmpty(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return 'El campo $fieldName no puede estar vacío';
    }
    return null;
  }

  static String? validateVehicleCapacity(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese la capacidad del vehículo';
    }
    final capacity = int.tryParse(value);
    if (capacity == null || capacity <= 0) {
      return 'La capacidad debe ser un número positivo';
    }
    return null;
  }

  static String? validateNombre(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su nombre';
    }
    return null;
  }

  static String? validateApellidos(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su apellido';
    }
    return null;
  }

  static String? validateRoutes(List<String>? routes) {
    if (routes == null || routes.isEmpty) {
      return 'Seleccione al menos una ruta';
    }
    return null;
  }

  static String? valdateDireccion(String? direccion) {
    if (direccion == null || direccion.isEmpty) {
      return 'Ingrese una dirección';
    }
    if (direccion.length < 10) {
      return 'Especifique una dirección más detallada';
    }
    return null;
  }

  static String? validateCantidadPersonas(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "La cantidad es requerida";
    }
    final cantidad = int.tryParse(value);
    if (cantidad == null || cantidad < 1 || cantidad > 50) {
      return "Ingrese un número válido entre 1 y 50";
    }
    return null;
  }
}
