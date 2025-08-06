import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

enum LogsType { success, error, warning, info, offline, online }

class LogsMessages {
  LogsMessages(BuildContext context, String message);

  // Método principal para mostrar snackbars personalizados
  static void _showCustomSnackBar(
    BuildContext context,
    String message,
    LogsType type, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getSnackBarConfig(type);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                config.icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        elevation: 6,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white.withOpacity(0.8),
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Configuración de estilos para cada tipo
  static _SnackBarConfig _getSnackBarConfig(LogsType type) {
    switch (type) {
      case LogsType.success:
        return _SnackBarConfig(
          icon: Icons.check_circle_rounded,
          backgroundColor: const Color(0xFF4CAF50),
        );
      case LogsType.error:
        return _SnackBarConfig(
          icon: Icons.error_rounded,
          backgroundColor: const Color(0xFFE53E3E),
        );
      case LogsType.warning:
        return _SnackBarConfig(
          icon: Icons.warning_rounded,
          backgroundColor: const Color(0xFFFF9800),
        );
      case LogsType.info:
        return _SnackBarConfig(
          icon: Icons.info_rounded,
          backgroundColor: AppColors.primary,
        );
      case LogsType.offline:
        return _SnackBarConfig(
          icon: Icons.wifi_off_rounded,
          backgroundColor: const Color(0xFF6B7280),
        );
      case LogsType.online:
        return _SnackBarConfig(
          icon: Icons.wifi_rounded,
          backgroundColor: const Color(0xFF10B981),
        );
    }
  }

  // Métodos públicos simplificados
  static void showSuccess(BuildContext context, String message) {
    _showCustomSnackBar(context, message, LogsType.success);
  }

  static void showError(BuildContext context, String message) {
    _showCustomSnackBar(context, message, LogsType.error);
  }

  static void showWarning(BuildContext context, String message) {
    _showCustomSnackBar(context, message, LogsType.warning);
  }

  static void showInfo(BuildContext context, String message) {
    _showCustomSnackBar(context, message, LogsType.info);
  }

  static void showInfoError(BuildContext context, String message) {
    _showCustomSnackBar(context, message, LogsType.error);
  }

  static void showOfflineDriver(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message,
      LogsType.offline,
      duration: const Duration(seconds: 4),
    );
  }

  static void showOnlineDriver(BuildContext context, String message) {
    _showCustomSnackBar(
      context,
      message,
      LogsType.online,
      duration: const Duration(seconds: 4),
    );
  }

  // Snackbar con acción personalizada
  static void showWithAction(
    BuildContext context,
    String message,
    String actionLabel,
    VoidCallback onAction, {
    LogsType type = LogsType.info,
  }) {
    final config = _getSnackBarConfig(type);
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                config.icon,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: config.backgroundColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 5),
        elevation: 6,
        action: SnackBarAction(
          label: actionLabel,
          textColor: Colors.white,
          backgroundColor: Colors.white.withOpacity(0.2),
          onPressed: onAction,
        ),
      ),
    );
  }

  // Snackbar simple sin icono (para casos especiales)
  static void showSimple(
    BuildContext context,
    String message, {
    Color? backgroundColor,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: backgroundColor ?? AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: duration,
        elevation: 6,
      ),
    );
  }
}

// Clase auxiliar para configuración
class _SnackBarConfig {
  final IconData icon;
  final Color backgroundColor;

  const _SnackBarConfig({
    required this.icon,
    required this.backgroundColor,
  });
}