import 'package:eytaxi/core/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class PersonalInfoStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController apellidosController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final bool obscurePassword;
  final bool obscureConfirmPassword;
  final VoidCallback onTogglePasswordVisibility;
  final VoidCallback onToggleConfirmPasswordVisibility;
  final String? Function(String?) validatePassword;
  final String? Function(String?) validateConfirmPassword;
  final void Function(String) onNameChanged;
  final void Function(String) onEmailChanged;

  const PersonalInfoStep({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.apellidosController,
    required this.emailController,
    required this.phoneController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.obscurePassword,
    required this.obscureConfirmPassword,
    required this.onTogglePasswordVisibility,
    required this.onToggleConfirmPasswordVisibility,
    required this.validatePassword,
    required this.onNameChanged,
    required this.onEmailChanged,
    required this.validateConfirmPassword,
  });

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.person_outline, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Datos Personales',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: nombreController,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Nombre',
                prefixIcon: Icons.person_outline,
              ),
              onChanged: onNameChanged,
              validator: Validators.validateNombre,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: apellidosController,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Apellidos',
                prefixIcon: Icons.person,
              ),
              validator: Validators.validateApellidos,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: emailController,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Correo Electrónico',
                prefixIcon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: onEmailChanged,
              validator: Validators.validateEmail,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  width: 80,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: isDarkMode ? Colors.grey[800] : Colors.grey[100],
                    border: Border.all(
                      color: isDarkMode ? Colors.grey[600]! : Colors.grey[300]!,
                      width: 1.0,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      '🇨🇺 +53',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: AppInputDecoration.buildInputDecoration(
                      context: context,
                      labelText: 'Número de Teléfono',
                      prefixIcon: Icons.phone_outlined,
                      hintText: '12345678',
                    ),
                    validator: Validators.validatePhoneNumber,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Icon(Icons.lock_outline, color: AppColors.primary, size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Contraseña',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: onTogglePasswordVisibility,
                ),
              ),
              validator: validatePassword,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: obscureConfirmPassword,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Confirmar Contraseña',
                prefixIcon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed: onToggleConfirmPasswordVisibility,
                ),
              ),
              validator: validateConfirmPassword,
            ),
            const SizedBox(height: 20),
            // Puedes agregar aquí los requisitos de contraseña si lo deseas
          ],
        ),
      ),
    );
  }
}
