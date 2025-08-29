import 'dart:io';
import 'dart:typed_data';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/services/storage_service.dart';
import 'package:eytaxi/core/services/supabase_api.dart';
import 'package:eytaxi/core/services/supabase_service.dart';
import 'package:eytaxi/core/styles/button_style.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/core/utils/regex_utils.dart';
import 'package:eytaxi/core/widgets/messages/logs.dart';
import 'package:eytaxi/core/widgets/messages/mesages.dart';
import 'package:eytaxi/models/ubicacion_model.dart';
import 'package:eytaxi/models/user_model.dart';
import 'package:eytaxi/presentation/passengers/widgets/locatio_autocomplete.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:firebase_messaging/firebase_messaging.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _vehicleCapacityController =
      TextEditingController();
  final TextEditingController _mun_origenController = TextEditingController();

  // State variables
  String _email = '';
  String _name = '';
  bool _loading = false;
  int _currentStep = 0;
  final String _selectedCountryCode = '+53';
  final List<String> _selectedRoutes = [];
  bool viajes_locales = false;
  Ubicacion? _municipio;
  SupabaseApi supabaseApi = SupabaseApi();
  final SupabaseService _supabaseService = SupabaseService();

  // Image handling
  File? _profilePhotoFile;
  File? _vehiclePhotoFile;
  Uint8List? _profilePhotoBytes;
  Uint8List? _vehiclePhotoBytes;
  final ImagePicker _picker = ImagePicker();

  bool get hasProfilePhoto =>
      kIsWeb ? _profilePhotoBytes != null : _profilePhotoFile != null;
  bool get hasVehiclePhoto =>
      kIsWeb ? _vehiclePhotoBytes != null : _vehiclePhotoFile != null;

  // Password visibility
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Steps configuration
  final List<String> _stepTitles = [
    'Información Personal',
    'Datos de Conductor',
    'Fotos y Verificación',
  ];

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDarkMode ? AppColors.backgroundDark : AppColors.background,
      appBar: AppBar(
        title: Text(
          'Registro de Conductor',
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
        ),
        backgroundColor: AppColors.transparent,
        foregroundColor: isDarkMode ? Colors.white : Colors.black87,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: () => AppRoutes.router.go(AppRoutes.login),
          icon: const Icon(Icons.arrow_back_ios_new_outlined),
        ),
      ),
      body: Column(
        children: [
          // Progress indicator
          _buildProgressIndicator(),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                _buildPersonalInfoStep(),
                _buildDriverInfoStep(),
                _buildPhotosStep(),
              ],
            ),
          ),

          // Navigation buttons
          _buildNavigationButtons(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Step indicators
          Row(
            children: List.generate(_stepTitles.length, (index) {
              final isActive = index == _currentStep;
              final isCompleted = index < _currentStep;

              return Expanded(
                child: Row(
                  children: [
                    // Circle indicator
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color:
                            isCompleted
                                ? AppColors.primary
                                : isActive
                                ? AppColors.primary
                                : Colors.grey[300],
                        border: Border.all(
                          color:
                              isActive ? AppColors.primary : Colors.grey[400]!,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child:
                            isCompleted
                                ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                )
                                : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color:
                                        isActive
                                            ? Colors.white
                                            : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                      ),
                    ),

                    // Line connector (except for last item)
                    if (index < _stepTitles.length - 1)
                      Expanded(
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color:
                              index < _currentStep
                                  ? AppColors.primary
                                  : Colors.grey[300],
                        ),
                      ),
                  ],
                ),
              );
            }),
          ),

          const SizedBox(height: 12),

          // Current step title
          Text(
            _stepTitles[_currentStep],
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            _buildSectionTitle('Datos Personales', Icons.person_outline),

            const SizedBox(height: 16),

            TextFormField(
              controller: _nombreController,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Nombre',
                prefixIcon: Icons.person_outline,
              ),
              onChanged: (value) => _name = value,
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Ingrese su nombre'
                          : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _apellidosController,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Apellidos',
                prefixIcon: Icons.person,
              ),
              validator:
                  (value) =>
                      value == null || value.isEmpty
                          ? 'Ingrese sus apellidos'
                          : null,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _emailController,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Correo Electrónico',
                prefixIcon: Icons.email_outlined,
              ),
              keyboardType: TextInputType.emailAddress,
              onChanged: (value) => _email = value,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ingrese su correo';
                } else if (!RegexUtils.isValidEmail(value)) {
                  return 'Ingrese un correo válido';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Phone number with country code
            _buildPhoneInput(),

            const SizedBox(height: 24),

            _buildSectionTitle('Contraseña', Icons.lock_outline),

            const SizedBox(height: 16),

            TextFormField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Contraseña',
                prefixIcon: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                ),
              ),
              validator: _validatePassword,
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _confirmPasswordController,
              obscureText: _obscureConfirmPassword,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Confirmar Contraseña',
                prefixIcon: Icons.lock,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscureConfirmPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: AppColors.primary,
                  ),
                  onPressed:
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Confirme su contraseña';
                }
                if (value != _passwordController.text) {
                  return 'Las contraseñas no coinciden';
                }
                return null;
              },
            ),

            const SizedBox(height: 20),

            // Password requirements
            _buildPasswordRequirements(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildDriverInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          _buildSectionTitle('Información del Conductor', Icons.badge_outlined),

          const SizedBox(height: 16),

          _BuildselectedOrigen(),

          const SizedBox(height: 16),

          TextFormField(
            controller: _licenseController,
            decoration: AppInputDecoration.buildInputDecoration(
              context: context,
              labelText: 'Número de Licencia',
              prefixIcon: Icons.badge,
              hintText: 'Ej: ABC123456',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su número de licencia';
              }
              if (!RegexUtils.isValidLicencia(value)) {
                return 'Ingrese un número de licencia válido';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.only(right: 2),
            child: DropdownButtonFormField<String>(
              value:
                  _vehicleCapacityController.text.isEmpty
                      ? null
                      : _vehicleCapacityController.text,
              decoration: AppInputDecoration.buildInputDecoration(
                context: context,
                labelText: 'Capacidad del Vehículo',
                prefixIcon: Icons.airline_seat_recline_normal,
                hintText: 'Seleccione el número de asientos',
              ),
              items:
                  List.generate(16, (index) => (index + 1).toString())
                      .map(
                        (value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text('$value pasajeros'),
                        ),
                      )
                      .toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  _vehicleCapacityController.text = newValue;
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Seleccione la capacidad del vehículo';
                }
                return null;
              },
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionTitle('Rutas de Operación', Icons.route),

          const SizedBox(height: 8),

          const Text(
            'Seleccione las regiones donde desea operar:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 16),

          _buildViajesLocales(),

          _buildImprovedRoutesSelector(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _BuildselectedOrigen() {
    return LocationAutocomplete(
      controller: _mun_origenController,
      labelText: 'Municipio de Origen',
      selectedLocation: _municipio,
      onSelected: (Ubicacion? selection) {
        setState(() {
          _municipio = selection;
        });
      },
      supabaseService: _supabaseService,
      user: UserType.driver,
    );
  }

  Widget _buildViajesLocales() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            setState(() {
              viajes_locales = !viajes_locales;
            });
          },
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: viajes_locales ? AppColors.primary : Colors.grey[300]!,
                width: viajes_locales ? 2 : 1,
              ),
              color: viajes_locales ? AppColors.primary.withOpacity(0.1) : null,
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on, // Puedes cambiar este ícono
                  color: viajes_locales ? AppColors.primary : Colors.grey[600],
                  size: 24,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Viajes locales',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                          color: viajes_locales ? AppColors.primary : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Selecciona si opera en rutas locales o dentro de la Provincia',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Icon(
                  viajes_locales
                      ? Icons.check_circle
                      : Icons.radio_button_unchecked,
                  color: viajes_locales ? AppColors.primary : Colors.grey[400],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotosStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          _buildSectionTitle(
            'Documentación Fotográfica',
            Icons.camera_alt_outlined,
          ),

          const SizedBox(height: 8),

          const Text(
            'Sube las fotos requeridas para completar tu registro:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 24),

          _buildImprovedPhotoSelector(
            label: 'Foto de Perfil',
            subtitle: 'Una foto clara de tu rostro',
            isPersonal: true,
            icon: Icons.person,
          ),

          const SizedBox(height: 24),

          _buildImprovedPhotoSelector(
            label: 'Foto del Vehículo',
            subtitle: 'Foto exterior completa del vehículo',
            isPersonal: false,
            icon: Icons.directions_car,
          ),

          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 24),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildPhoneInput() {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Row(
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
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: AppInputDecoration.buildInputDecoration(
              context: context,
              labelText: 'Número de Teléfono',
              prefixIcon: Icons.phone_outlined,
              hintText: '12345678',
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ingrese su teléfono';
              } else if (!RegexUtils.isValidPhone(value)) {
                return 'Ingrese un número válido';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'La contraseña debe contener:',
            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
          const SizedBox(height: 8),
          _buildRequirement('Al menos 8 caracteres', password.length >= 8),
          _buildRequirement(
            'Una letra mayúscula',
            RegExp(r'[A-Z]').hasMatch(password),
          ),
          _buildRequirement(
            'Una letra minúscula',
            RegExp(r'[a-z]').hasMatch(password),
          ),
          _buildRequirement('Un número', RegExp(r'\d').hasMatch(password)),
          _buildRequirement(
            'Un carácter especial (!@#\$&*~._-)',
            RegExp(r'[!@#\$&*~._-]').hasMatch(password),
          ),
        ],
      ),
    );
  }

  Widget _buildRequirement(String text, bool isMet) {
    return Row(
      children: [
        Icon(
          isMet ? Icons.check_circle : Icons.radio_button_unchecked,
          color: isMet ? Colors.green : Colors.grey,
          size: 16,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              color: isMet ? Colors.green : Colors.grey[600],
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImprovedRoutesSelector() {
    final routes = [
      {
        'name': 'oriente',
        'description': 'Santiago, Granma, Guantánamo, Las Tunas, Holguín',
        'icon': Icons.east,
      },
      {
        'name': 'centro',
        'description':
            'Villa Clara, Cienfuegos, Sancti Spíritus, Ciego de Ávila, Camagüey',
        'icon': Icons.center_focus_strong,
      },
      {
        'name': 'occidente',
        'description':
            'La Habana, Matanzas, Pinar del Río, Artemisa, Mayabeque',
        'icon': Icons.west,
      },
    ];

    return Column(
      children:
          routes.map((route) {
            final isSelected = _selectedRoutes.contains(route['name']);

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap:
                      () => _updateRoutes(route['name'] as String, !isSelected),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color:
                            isSelected ? AppColors.primary : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                      color:
                          isSelected
                              ? AppColors.primary.withOpacity(0.1)
                              : null,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          route['icon'] as IconData,
                          color:
                              isSelected ? AppColors.primary : Colors.grey[600],
                          size: 24,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                route['name'] as String,
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                  color: isSelected ? AppColors.primary : null,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                route['description'] as String,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          isSelected
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          color:
                              isSelected ? AppColors.primary : Colors.grey[400],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
    );
  }

  Widget _buildImprovedPhotoSelector({
    required String label,
    required String subtitle,
    required bool isPersonal,
    required IconData icon,
  }) {
    final hasPhoto = isPersonal ? hasProfilePhoto : hasVehiclePhoto;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasPhoto ? AppColors.primary : Colors.grey[300]!,
          width: hasPhoto ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: AppColors.primary),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),

          InkWell(
            onTap: () => _pickImage(isPersonal),
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(16),
            ),
            child: Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
              ),
              child:
                  hasPhoto
                      ? ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          bottom: Radius.circular(16),
                        ),
                        child: Stack(
                          children: [
                            SizedBox(
                              width: double.infinity,
                              height: double.infinity,
                              child:
                                  kIsWeb
                                      ? Image.memory(
                                        isPersonal
                                            ? _profilePhotoBytes!
                                            : _vehiclePhotoBytes!,
                                        fit: BoxFit.cover,
                                      )
                                      : Image.file(
                                        isPersonal
                                            ? _profilePhotoFile!
                                            : _vehiclePhotoFile!,
                                        fit: BoxFit.cover,
                                      ),
                            ),
                            Positioned(
                              top: 8,
                              right: 8,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.primary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                      : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_a_photo,
                            size: 48,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Toca para seleccionar',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (_currentStep > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: _goToPreviousStep,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    side: BorderSide(color: AppColors.primary),
                  ),
                  child: const Text('Anterior'),
                ),
              ),

            if (_currentStep > 0) const SizedBox(width: 16),

            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: _loading ? null : _handleNextStep,
                style: AppButtonStyles.elevatedButtonStyle(context).copyWith(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
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
                        : Text(_currentStep == 2 ? 'Registrarse' : 'Siguiente'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Navigation methods
  void _goToPreviousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _handleNextStep() {
    if (_currentStep == 0) {
      if (_validatePersonalInfo()) {
        _goToNextStep();
      }
    } else if (_currentStep == 1) {
      if (_validateDriverInfo()) {
        _goToNextStep();
      }
    } else if (_currentStep == 2) {
      if (_validatePhotos()) {
        _register();
      }
    }
  }

  void _goToNextStep() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  // Validation methods
  bool _validatePersonalInfo() {
    return _formKey.currentState?.validate() ?? false;
  }

  bool _validateDriverInfo() {
    if (_licenseController.text.isEmpty) {
      LogsMessages.showInfoError(context, 'Ingrese su número de licencia');
      return false;
    }

    if (!RegexUtils.isValidLicencia(_licenseController.text)) {
      LogsMessages.showInfoError(
        context,
        'Ingrese un número de licencia válido',
      );
      return false;
    }

    if (_vehicleCapacityController.text.isEmpty) {
      LogsMessages.showInfoError(
        context,
        'Seleccione la capacidad del vehículo',
      );
      return false;
    }

    if (_selectedRoutes.isEmpty && !viajes_locales) {
      LogsMessages.showInfoError(context, 'Debe seleccionar al menos una ruta');
      return false;
    }

    return true;
  }

  bool _validatePhotos() {
    if (!hasProfilePhoto) {
      LogsMessages.showInfoError(context, 'Debe subir una foto de perfil');
      return false;
    }

    if (!hasVehiclePhoto) {
      LogsMessages.showInfoError(context, 'Debe subir la foto del vehículo');
      return false;
    }

    return true;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese su contraseña';
    }
    if (value.length < 8) {
      return 'Debe tener al menos 8 caracteres';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Debe tener al menos una mayúscula';
    }
    if (!RegExp(r'[a-z]').hasMatch(value)) {
      return 'Debe tener al menos una minúscula';
    }
    if (!RegExp(r'\d').hasMatch(value)) {
      return 'Debe tener al menos un número';
    }
    if (!RegExp(r'[!@#\$&*~._-]').hasMatch(value)) {
      return 'Debe tener al menos un carácter especial';
    }
    return null;
  }

  // Existing methods (register, image picker, etc.)
  Future<void> _register() async {
    setState(() => _loading = true);
    String? userId;

    try {
      final existingUsers = await supabaseApi.client
          .from('user_profiles')
          .select()
          .eq('email', _emailController.text.trim());

      if (existingUsers.isNotEmpty) {
        LogsMessages.showInfoError(context, 'Email ya registrado');
        return;
      }

      final authResponse = await supabaseApi.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (authResponse.user == null) {
        LogsMessages.showInfoError(context, 'Error en el registro');
        return;
      }

      userId = authResponse.user!.id;

      final storageService = StorageService(SupabaseApi().client);

      final profilePhotoUrl = await storageService
          .uploadImage(
            imageData: kIsWeb ? _profilePhotoBytes : _profilePhotoFile,
            userId: userId,
            type: 'profile',
          )
          .onError((error, stackTrace) {
            throw Exception('Error al subir foto de perfil');
          });

      final vehiclePhotoUrl = await storageService
          .uploadImage(
            imageData: kIsWeb ? _vehiclePhotoBytes : _vehiclePhotoFile,
            userId: userId,
            type: 'vehicle',
          )
          .onError((error, stackTrace) {
            throw Exception('Error al subir foto del vehículo');
          });

      await _createDriverProfile(
        userId: userId,
        profilePhotoUrl: profilePhotoUrl!,
        vehiclePhotoUrl: vehiclePhotoUrl!,
      );

      _showSuccessMessage();
    } catch (e) {
      LogsMessages.showInfoError(context, e.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _createDriverProfile({
    required String userId,
    required String profilePhotoUrl,
    required String vehiclePhotoUrl,
  }) async {
    final token = await FirebaseMessaging.instance.getToken();
    try {
      await SupabaseApi().client.from('user_profiles').insert({
        'id': userId,
        'email': _emailController.text.trim(),
        'nombre': _nombreController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'phone_number': _phoneController.text,
        'user_type': 'driver',
        'photo_url': profilePhotoUrl,
        'fcm_token': token,
      });

      await SupabaseApi().client.from('drivers').insert({
        'id': userId,
        'license_number': _licenseController.text.trim(),
        'vehicle_capacity': int.parse(_vehicleCapacityController.text),
        'routes': _selectedRoutes,
        'is_available': true,
        'driver_status': 'pending',
        'vehicle_photo_url': vehiclePhotoUrl,
        'id_municipio_de_origen': _municipio?.id,
        'viajes_locales': viajes_locales,
      });

      SupabaseApi().signOut();
    } catch (e) {
      throw Exception('Error al crear perfil: ${e.toString()}');
    }
  }

  void _updateRoutes(String route, bool selected) {
    setState(() {
      if (selected) {
        _selectedRoutes.add(route.toLowerCase());
      } else {
        _selectedRoutes.remove(route);
      }
    });
  }

  Future<void> _pickImage(bool isPersonal) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          setState(() {
            if (isPersonal) {
              _profilePhotoBytes = bytes;
            } else {
              _vehiclePhotoBytes = bytes;
            }
          });
        } else {
          setState(() {
            if (isPersonal) {
              _profilePhotoFile = File(image.path);
            } else {
              _vehiclePhotoFile = File(image.path);
            }
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al seleccionar imagen: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSuccessMessage() {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return CustomDialog(
          showAnimation: true,
          message:
              'Tu solicitud está en revisión.\nTe notificaremos cuando esté lista.',
          buttonText: 'Continuar',
          onPressed: () {
            AppRoutes.router.go(AppRoutes.home);
          },
          title: 'Registro Exitoso',
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _vehicleCapacityController.dispose();
    super.dispose();
  }
}
