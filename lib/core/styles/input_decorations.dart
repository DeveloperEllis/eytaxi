import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class AppInputDecoration {
  // Decoración genérica para campos de texto
  static InputDecoration buildInputDecoration({
    required BuildContext context,
    required String labelText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    String? hintText,
    EdgeInsets contentPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return InputDecoration(
      hintText: hintText,
      labelText: labelText,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: isDarkMode ? AppColors.white : AppColors.black.withOpacity(0.7),
          ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: isDarkMode ? AppColors.primary : AppColors.primary)
          : null,
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: isDarkMode ? AppColors.borderInputDark : AppColors.borderInput,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.grey,
          width: 1.5,
        ),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDarkMode ? AppColors.grey : AppColors.borderInput,
          width: 1.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: AppColors.primary,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.redAccent : Colors.red,
          width: 1.5,
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(
          color: isDarkMode ? Colors.redAccent : Colors.red,
          width: 2,
        ),
      ),
      contentPadding: contentPadding,
    );
  }

  // Decoración estándar (sin prefijo)
  static InputDecoration buildStandardInputDecoration({
    required BuildContext context,
    required String labelText,
    Widget? suffixIcon,
  }) {
    return buildInputDecoration(
      context: context,
      labelText: labelText,
      suffixIcon: suffixIcon,
    );
  }

  // Decoración para campos de teléfono
  static InputDecoration buildPhoneInputDecoration({
    required BuildContext context,
    String labelText = 'Teléfono',
    Widget? suffixIcon,
  }) {
    return buildInputDecoration(
      context: context,
      labelText: labelText,
      prefixIcon: Icons.phone,
      suffixIcon: suffixIcon,
    );
  }

  // Decoración para campos de código de país
  static InputDecoration buildCountryCodeInputDecoration({
    required BuildContext context,
    String labelText = 'Código',
    Widget? suffixIcon,
  }) {
    return buildInputDecoration(
      context: context,
      labelText: labelText,
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  // Decoración para campos de correo electrónico
  static InputDecoration buildEmailInputDecoration({
    required BuildContext context,
    required String labelText,
    IconData? prefixIcon = Icons.email,
    Widget? suffixIcon,
  }) {
    return buildInputDecoration(
      context: context,
      labelText: labelText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  

  
}