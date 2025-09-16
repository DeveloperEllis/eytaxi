import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/utils/validators.dart';
import 'package:eytaxi/core/widgets/messages/logs.dart';
import 'package:eytaxi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:eytaxi/core/styles/button_style.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/features/auth/data/repositories/auth_repositories.dart';
import 'package:flutter/material.dart';
import 'package:eytaxi/features/auth/presentation/login/widgets/forgot_pasword.dart';

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
  bool _obscurePassword = true;
  late AuthRepositoryImpl _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = AuthRepositoryImpl(AuthRemoteDataSource());
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () {
            AppRoutes.router.go(AppRoutes.home);
          },
          icon: Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
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

                    const SizedBox(height: 16),
                    TextFormField(
                      decoration: AppInputDecoration.buildInputDecoration(
                        context: context,
                        labelText: 'Email',
                        prefixIcon: Icons.email_outlined,
                      ),
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onChanged: (value) => _email = value,
                      validator: Validators.validateEmail,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      decoration: AppInputDecoration.buildInputDecoration(
                        context: context,
                        labelText: 'Contraseña',
                        prefixIcon: Icons.lock_outline,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: AppColors.primary,
                          ),
                          onPressed:
                              () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              ),
                        ),
                      ),
                      obscureText: _obscurePassword,
                      onChanged: (value) => _password = value,
                      validator:
                          Validators.validatePassword,
                    ),
                    const SizedBox(height: 2),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: ForgotPasswordButton(),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _loading
                                ? null
                                : () async {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() => _loading = true);
                                    try {
                                      await _authRepository.signInWithPassword(
                                        _email,
                                        _password,
                                      );
                                      // Si llega aquí sin excepción, login exitoso
                                      // Verificar estado del conductor antes de redirigir
                                      await _authRepository
                                          .handlePostLoginRedirection();
                                    } on AuthException catch (e) {
                                      String message =
                                          'Error al iniciar sesión.';
                                      final msg = e.message.toLowerCase();
                                      if (msg.contains(
                                        'invalid login credentials',
                                      )) {
                                        message =
                                            'Correo o contraseña incorrectos.';
                                      } else if (msg.contains(
                                            'failed to fetch',
                                          ) ||
                                          msg.contains('network') ||
                                          msg.contains('connection')) {
                                        message =
                                            'No se pudo conectar al servidor. Verifica tu conexión a internet.';
                                      } else if (e.message.isNotEmpty &&
                                          !msg.contains('clientexception')) {
                                        message = e.message;
                                      } else {
                                        message =
                                            'Ocurrió un error inesperado. Intenta nuevamente.';
                                      }
                                      LogsMessages.showInfoError(
                                        context,
                                        message,
                                      );
                                    } catch (e) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Ocurrió un error inesperado. Intenta nuevamente.',
                                          ),
                                        ),
                                      );
                                    } finally {
                                      if (mounted) {
                                        setState(() => _loading = false);
                                      }
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
