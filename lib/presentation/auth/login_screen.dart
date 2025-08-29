import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/services/supabase_api.dart';
import 'package:eytaxi/core/styles/button_style.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(onPressed: () {
          AppRoutes.router.go(AppRoutes.home);
        }, icon: Icon(Icons.arrow_back_ios_new_outlined)
        ),
      ),
      backgroundColor: isDarkMode? AppColors.backgroundDark: AppColors.background,
      body: Center(
        child: SingleChildScrollView(
          child: Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 36),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.local_taxi, size: 64, color: AppColors.primary),
                    const SizedBox(height: 12),
                    Text(
                      'Iniciar Sesión',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      decoration: AppInputDecoration.buildInputDecoration(context: context,
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      onChanged: (value) => _email = value,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Ingrese su correo'
                                  : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      decoration: AppInputDecoration.buildInputDecoration(context: context,
                        labelText: 'Contraseña',
                        prefixIcon: Icons.lock_outline,
                      ),
                      obscureText: true,
                      onChanged: (value) => _password = value,
                      validator:
                          (value) =>
                              value == null || value.isEmpty
                                  ? 'Ingrese su contraseña'
                                  : null,
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _loading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      setState(() => _loading = true);
                                      await Login(_email, _password, context);
                                    } catch (e) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: ${e.toString()}')),
                                      );
                                    } finally {
                                      setState(() => _loading = false);
                                    }
                                  }
                                },
                        style: AppButtonStyles.elevatedButtonStyle(context),
                        child:
                            _loading
                                ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                                : const Text('Entrar'),
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextButton(
                      onPressed: () {
                        AppRoutes.router.go('/register');
                      },
                      style: AppButtonStyles.textButtonStyle(context),
                      child: const Text('¿No tienes cuenta? Regístrate'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
