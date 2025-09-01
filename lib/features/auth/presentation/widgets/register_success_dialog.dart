import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

void showSuccessDialog(BuildContext context, {String? title, String? message, VoidCallback? onContinue}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primary, size: 64),
            const SizedBox(height: 16),
            Text(
              title ?? '¡Registro exitoso!',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              message ?? 'Tu solicitud está en revisión.\nTe notificaremos cuando esté lista.',
              style: const TextStyle(fontSize: 16, color: Colors.black54),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              icon: const Icon(Icons.arrow_forward, color: Colors.white),
              label: const Text('Continuar', style: TextStyle(color: Colors.white, fontSize: 16)),
              onPressed: () {
                if (onContinue != null) onContinue();
              },
            ),
          ],
        ),
      ),
    ),
  );
}