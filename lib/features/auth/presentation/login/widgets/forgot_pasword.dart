import 'package:eytaxi/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eytaxi/core/widgets/messages/logs.dart';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/core/styles/button_style.dart';

// Uso: await showForgotPasswordDialog(context, prefillEmail: currentEmail);
Future<void> showForgotPasswordDialog(
  BuildContext context, {
  String? prefillEmail,
}) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (_) {
      // Obtener el tamaño de la pantalla
      final screenSize = MediaQuery.of(context).size;
      return Dialog(
        // Establecer el ancho al 90% del ancho de la pantalla
        insetPadding: EdgeInsets.symmetric(horizontal: screenSize.width * 0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: _ForgotPasswordDialog(prefillEmail: prefillEmail ?? ''),
      );
    },
  );
}

// Botón reutilizable para colocar en Login u otras pantallas
class ForgotPasswordButton extends StatelessWidget {
  final String? prefillEmail;
  final Widget? child;
  const ForgotPasswordButton({super.key, this.prefillEmail, this.child});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed:
          () => showForgotPasswordDialog(context, prefillEmail: prefillEmail),

      child:
          child ??
          const Text(
            '¿Olvidaste tu contraseña?',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
          ),
    );
  }
}

class _ForgotPasswordDialog extends StatefulWidget {
  final String prefillEmail;
  const _ForgotPasswordDialog({required this.prefillEmail});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _emailController;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.prefillEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: isDarkMode ? AppColors.backgroundDark : AppColors.white,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título con icono
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    color: AppColors.primary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Recuperar contraseña',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: isDarkMode ? AppColors.white : AppColors.black,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed:
                      _submitting ? null : () => Navigator.of(context).pop(),
                  color: AppColors.grey,
                  tooltip: 'Cerrar',
                ),
              ],
            ),
          ),

          const Divider(),

          // Texto explicativo
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'Ingresa tu correo electrónico registrado y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(
                color: isDarkMode ? AppColors.grey : Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Campo de correo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: AppInputDecoration.buildEmailInputDecoration(
                context: context,
                labelText: 'Correo electrónico',
              ),
              enabled: !_submitting,
              autofocus: true,
            ),
          ),

          const SizedBox(height: 24),

          // Botones
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed:
                      _submitting ? null : () => Navigator.of(context).pop(),
                  style: AppButtonStyles.textButtonStyle(context),
                  child: const Text('Cancelar'),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: _submitting ? null : _onSubmit,
                  style: AppButtonStyles.primaryButtonStyle(context),
                  child:
                      _submitting
                          ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.white,
                              ),
                            ),
                          )
                          : const Text('Enviar'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Future<void> _onSubmit() async {
    final email = _emailController.text.trim();

    // Validación de email mejorada
    if (Validators.validateEmail(email) != null) {
      LogsMessages.showWarning(context,
        'Por favor, ingresa un correo electrónico válido.',
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      // Primero verificamos si el email existe en la base de datos
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('id')
          .eq('email', email)
          .limit(1);

      // Si la respuesta está vacía, el email no existe
      if (response.isEmpty) {
        LogsMessages.showError(context,
          'No encontramos ninguna cuenta con ese correo electrónico',
        );
        setState(() => _submitting = false);
        return;
      }

      // Si llegamos aquí, el email existe, así que enviamos el enlace
      if (!mounted) return;
      Navigator.of(context).pop();

      // Mensaje de éxito
      LogsMessages.showSuccess(context,
        'Te enviamos un enlace para restablecer tu contraseña. Revisa tu correo.',
      );
      await Supabase.instance.client.auth.resetPasswordForEmail(email);
    } on AuthException catch (e) {
      final msg = e.message.toLowerCase();
      String message = 'No pudimos procesar tu solicitud.';

      if (msg.contains('failed to fetch') ||
          msg.contains('network') ||
          msg.contains('connection')) {
        message =
            'No se pudo conectar al servidor. Verifica tu conexión a internet.';
      } else if (msg.contains('user') &&
          msg.contains('not') &&
          msg.contains('found')) {
        message = 'No encontramos una cuenta con ese correo.';
      } else if (e.message.isNotEmpty) {
        message = e.message;
      }

      // Usar LogsMessages.showError en lugar de showInfoError para consistencia
      LogsMessages.showError(context,message);
    } catch (e) {
      LogsMessages.showError(context,
        'Ocurrió un error inesperado. Intenta nuevamente.',
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }
}
