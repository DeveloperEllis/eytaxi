import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/models/ubicacion_model.dart';

class LocationAutocompleteStyles {
  // Decoración del contenedor de opciones (Autocomplete options view)
  static BoxDecoration optionsContainerDecoration(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return BoxDecoration(
      color: isDarkMode ? AppColors.backgroundDark : AppColors.white,
      borderRadius: const BorderRadius.all(Radius.circular(16)),
      boxShadow: [
        BoxShadow(
          color: isDarkMode ? AppColors.white.withOpacity(0.2) : Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }

  // Estilo del texto del título en las opciones
  static TextStyle optionTitleStyle(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge!.copyWith(
          fontWeight: FontWeight.w500,
          color: Theme.of(context).brightness == Brightness.dark ? AppColors.white : Colors.black,
        );
  }

  // Estilo del texto del subtítulo en las opciones
  static TextStyle optionSubtitleStyle(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Theme.of(context).textTheme.bodyMedium!.copyWith(
          color: isDarkMode ? AppColors.grey : AppColors.grey.withOpacity(0.6),
        );
  }

  // Ícono para las opciones basado en el tipo de ubicación
  static IconData getIconForUbicacion(Ubicacion ubicacion) {
    final lowerTipo = ubicacion.tipo.toLowerCase() ?? 'ciudad';
    if (lowerTipo == 'aeropuerto') {
      return Icons.flight;
    } else if (lowerTipo == 'cayo') {
      return Icons.hotel;
    }
    return Icons.location_city;
  }

  // Color del ícono de las opciones
  static Color optionIconColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark ? AppColors.grey : AppColors.grey.withOpacity(0.6);
  }

  // Dimensiones y otros parámetros
  static const double optionsContainerWidthFactor = 0.9; // 90% del ancho de la pantalla
  static const double elevation = 4.0;
  static const EdgeInsets optionsPadding = EdgeInsets.zero;
  static const BorderRadius optionsBorderRadius = BorderRadius.all(Radius.circular(16));
}