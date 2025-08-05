import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';

class LoginRequiredDialog {
  Future<void> show(BuildContext context) async {
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Inicio de sesión requerido"),
        content: const Text("Debes iniciar sesión para continuar."),
        actions: [
          TextButton(
            child: const Text("Cancelar"),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text("Iniciar sesión"),
            onPressed: () {
              Navigator.of(context).pop();
              // Aquí puedes agregar redirección a login si es necesario
            },
          ),
        ],
      ),
    );
  }
}
