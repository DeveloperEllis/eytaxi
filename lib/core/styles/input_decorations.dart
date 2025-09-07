import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

/// App-wide input decoration styles
/// Provides consistent styling for all form inputs across the application
class AppInputDecoration {
  // Private constructor to prevent instantiation
  AppInputDecoration._();

  // ===========================================================================
  // CONSTANTS
  // ===========================================================================

  /// Default border radius for input fields
  static const double _defaultBorderRadius = 16.0;
  
  /// Default border width for normal state
  static const double _defaultBorderWidth = 1.5;
  
  /// Focused border width
  static const double _focusedBorderWidth = 2.0;
  
  /// Default content padding
  static const EdgeInsets _defaultContentPadding = EdgeInsets.symmetric(
    horizontal: 16, 
    vertical: 12,
  );
  
  /// Compact content padding for smaller fields
  static const EdgeInsets _compactContentPadding = EdgeInsets.symmetric(
    horizontal: 12, 
    vertical: 8,
  );

  // ===========================================================================
  // THEME HELPERS
  // ===========================================================================

  /// Returns appropriate colors based on theme brightness
  static _InputColors _getThemeColors(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return _InputColors(
      fillColor: isDarkMode ? AppColors.borderInputDark : AppColors.borderInput,
      labelColor: isDarkMode ? AppColors.grey : AppColors.black.withOpacity(0.7),
      iconColor: AppColors.primary,
      enabledBorderColor: isDarkMode ? AppColors.grey : AppColors.borderInput,
      focusedBorderColor: AppColors.primary,
      errorColor: isDarkMode ? Colors.redAccent : Colors.red,
    );
  }

  // ===========================================================================
  // BASE DECORATION BUILDERS
  // ===========================================================================

  /// Base method for creating input decorations with consistent styling
  static InputDecoration _buildBaseDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    EdgeInsets? contentPadding,
    double? borderRadius,
    bool filled = true,
    Color? fillColor,
    TextStyle? labelStyle,
    TextStyle? hintStyle,
  }) {
    final colors = _getThemeColors(context);
    final radius = borderRadius ?? _defaultBorderRadius;

    return InputDecoration(
      // Text properties
      labelText: labelText,
      hintText: hintText,
      labelStyle: labelStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colors.labelColor,
        fontWeight: FontWeight.w500,
      ),
      hintStyle: hintStyle ?? Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colors.labelColor.withOpacity(0.6),
      ),
      
      // Icons
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: colors.iconColor, size: 20)
          : null,
      suffixIcon: suffixIcon,
      
      // Fill properties
      filled: filled,
      fillColor: fillColor ?? colors.fillColor,
      
      // Content padding
      contentPadding: contentPadding ?? _defaultContentPadding,
      
      // Borders
      border: _buildBorder(radius, colors.enabledBorderColor, _defaultBorderWidth),
      enabledBorder: _buildBorder(radius, colors.enabledBorderColor, _defaultBorderWidth),
      focusedBorder: _buildBorder(radius, colors.focusedBorderColor, _focusedBorderWidth),
      errorBorder: _buildBorder(radius, colors.errorColor, _defaultBorderWidth),
      focusedErrorBorder: _buildBorder(radius, colors.errorColor, _focusedBorderWidth),
      disabledBorder: _buildBorder(radius, colors.enabledBorderColor.withOpacity(0.5), _defaultBorderWidth),
    );
  }

  /// Helper method to build consistent borders
  static OutlineInputBorder _buildBorder(double radius, Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  // ===========================================================================
  // PUBLIC DECORATION METHODS
  // ===========================================================================

  /// Standard input decoration with customizable options
  static InputDecoration buildInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
    EdgeInsets? contentPadding,
    double? borderRadius,
    bool filled = true,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: contentPadding,
      borderRadius: borderRadius,
      filled: filled,
    );
  }

  /// Standard decoration without prefix icon
  static InputDecoration buildStandardInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
    );
  }

  // ===========================================================================
  // SPECIALIZED INPUT DECORATIONS
  // ===========================================================================

  /// Email input decoration with email icon
  static InputDecoration buildEmailInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    IconData? prefixIcon = Icons.email_outlined,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText ?? 'example@email.com',
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
    );
  }

  /// Phone input decoration with phone icon
  static InputDecoration buildPhoneInputDecoration({
    required BuildContext context,
    String labelText = 'Teléfono',
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.phone_outlined,
      suffixIcon: suffixIcon,
    );
  }

  /// Password input decoration with lock icon
  static InputDecoration buildPasswordInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
    bool obscureText = true,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.lock_outline,
      suffixIcon: suffixIcon,
    );
  }

  /// Search input decoration with search icon
  static InputDecoration buildSearchInputDecoration({
    required BuildContext context,
    String labelText = 'Buscar',
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText ?? 'Ingrese su búsqueda...',
      prefixIcon: Icons.search_outlined,
      suffixIcon: suffixIcon,
    );
  }

  /// Address input decoration with location icon
  static InputDecoration buildAddressInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.location_on_outlined,
      suffixIcon: suffixIcon,
    );
  }

  /// Country code input decoration (compact style)
  static InputDecoration buildCountryCodeInputDecoration({
    required BuildContext context,
    String labelText = 'Código',
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      suffixIcon: suffixIcon,
      contentPadding: _compactContentPadding,
    );
  }

  /// Date input decoration with calendar icon
  static InputDecoration buildDateInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText ?? 'DD/MM/YYYY',
      prefixIcon: Icons.calendar_today_outlined,
      suffixIcon: suffixIcon,
    );
  }

  /// Time input decoration with clock icon
  static InputDecoration buildTimeInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText ?? 'HH:MM',
      prefixIcon: Icons.access_time_outlined,
      suffixIcon: suffixIcon,
    );
  }

  /// Number input decoration with numbers icon
  static InputDecoration buildNumberInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: Icons.numbers_outlined,
      suffixIcon: suffixIcon,
    );
  }

  /// Money input decoration with currency icon
  static InputDecoration buildMoneyInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    String currency = '\$',
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText ?? '0.00',
      prefixIcon: Icons.attach_money_outlined,
      suffixIcon: suffixIcon,
    );
  }

  // ===========================================================================
  // SPECIALIZED STYLES
  // ===========================================================================

  /// Compact input decoration for smaller spaces
  static InputDecoration buildCompactInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      contentPadding: _compactContentPadding,
      borderRadius: 12.0,
    );
  }

  /// Minimal input decoration with no borders (underline style)
  static InputDecoration buildMinimalInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    final colors = _getThemeColors(context);
    
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: colors.labelColor,
      ),
      prefixIcon: prefixIcon != null
          ? Icon(prefixIcon, color: colors.iconColor, size: 20)
          : null,
      suffixIcon: suffixIcon,
      filled: false,
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      border: UnderlineInputBorder(
        borderSide: BorderSide(color: colors.enabledBorderColor),
      ),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colors.enabledBorderColor),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colors.focusedBorderColor, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: colors.errorColor),
      ),
    );
  }

  /// Elevated input decoration with shadow effect
  static InputDecoration buildElevatedInputDecoration({
    required BuildContext context,
    required String labelText,
    String? hintText,
    IconData? prefixIcon,
    Widget? suffixIcon,
  }) {
    return _buildBaseDecoration(
      context: context,
      labelText: labelText,
      hintText: hintText,
      prefixIcon: prefixIcon,
      suffixIcon: suffixIcon,
      borderRadius: 20.0,
    );
  }
}

// ===========================================================================
// HELPER CLASSES
// ===========================================================================

/// Internal class to hold theme-specific colors
class _InputColors {
  final Color fillColor;
  final Color labelColor;
  final Color iconColor;
  final Color enabledBorderColor;
  final Color focusedBorderColor;
  final Color errorColor;

  const _InputColors({
    required this.fillColor,
    required this.labelColor,
    required this.iconColor,
    required this.enabledBorderColor,
    required this.focusedBorderColor,
    required this.errorColor,
  });
}