import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

enum LogsType { success, error, warning, info, online, offline }

class LogsMessages {
  static void _showFlushbar(
    BuildContext context,
    String message,
    LogsType type, {
    Duration duration = const Duration(seconds: 3),
  }) {
    final config = _getConfig(type);

    Flushbar(
      message: message,
      duration: duration,
      icon: Icon(config.icon, color: Colors.white),
      backgroundColor: config.backgroundColor,
      margin: const EdgeInsets.all(16),
      borderRadius: BorderRadius.circular(12),
      flushbarPosition: FlushbarPosition.BOTTOM,
      animationDuration: const Duration(milliseconds: 350),
      mainButton: IconButton(
        icon: const Icon(Icons.close, color: Colors.white),
        onPressed: () {},
      ),
    ).show(context);
  }

  // Métodos públicos
  static void showSuccess(BuildContext context, String message) =>
      _showFlushbar(context, message, LogsType.success);

  static void showError(BuildContext context, String message) =>
      _showFlushbar(context, message, LogsType.error);

  static void showWarning(BuildContext context, String message) =>
      _showFlushbar(context, message, LogsType.warning);

  static void showInfo(BuildContext context, String message) =>
      _showFlushbar(context, message, LogsType.info);

  static void showOnline(BuildContext context, String message) => _showFlushbar(
    context,
    message,
    LogsType.online,
    duration: const Duration(seconds: 4),
  );

  static void showOffline(BuildContext context, String message) =>
      _showFlushbar(
        context,
        message,
        LogsType.offline,
        duration: const Duration(seconds: 4),
      );

  // Método de prueba
  static void test(BuildContext context) {
    showSuccess(context, "Mensaje de prueba con Flushbar");
  }

  static _SnackConfig _getConfig(LogsType type) {
    switch (type) {
      case LogsType.success:
        return const _SnackConfig(
          icon: Icons.check_circle_rounded,
          backgroundColor: Color(0xFF4CAF50),
        );
      case LogsType.error:
        return const _SnackConfig(
          icon: Icons.error_rounded,
          backgroundColor: Color(0xFFE53E3E),
        );
      case LogsType.warning:
        return const _SnackConfig(
          icon: Icons.warning_rounded,
          backgroundColor: Color(0xFFFF9800),
        );
      case LogsType.info:
        return _SnackConfig(
          icon: Icons.info_rounded,
          backgroundColor: AppColors.primary,
        );
      case LogsType.online:
        return const _SnackConfig(
          icon: Icons.wifi_rounded,
          backgroundColor: Color(0xFF10B981),
        );
      case LogsType.offline:
        return const _SnackConfig(
          icon: Icons.wifi_off_rounded,
          backgroundColor: Color(0xFF6B7280),
        );
    }
  }
}

class _SnackConfig {
  final IconData icon;
  final Color backgroundColor;

  const _SnackConfig({required this.icon, required this.backgroundColor});
}
