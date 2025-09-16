import 'dart:io';
import 'dart:typed_data';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/constants/app_routes.dart';
import 'package:eytaxi/core/services/storage_service.dart';
import 'package:eytaxi/core/widgets/messages/mesages.dart';
import 'package:eytaxi/features/auth/data/datasources/auth_remote_datasource.dart';
import 'package:eytaxi/core/services/supabase_service.dart';
import 'package:eytaxi/core/widgets/messages/logs.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/features/auth/data/repositories/auth_repositories.dart';
import 'package:eytaxi/features/auth/domain/usecases/register_driver_usecase.dart';
import 'package:eytaxi/features/auth/utils/register_validators.dart';
import 'package:eytaxi/features/auth/presentation/registro/widgets/driver_info_step.dart';
import 'package:eytaxi/features/auth/presentation/registro/widgets/improved_routes_selector.dart';
import 'package:eytaxi/features/auth/presentation/registro/widgets/personal_info_step.dart';
import 'package:eytaxi/features/auth/presentation/registro/widgets/photos_step.dart';
import 'package:eytaxi/features/auth/presentation/registro/widgets/register_navigation_buttons.dart';
import 'package:eytaxi/features/auth/presentation/registro/widgets/register_progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  AuthRepositoryImpl _authRepository = AuthRepositoryImpl(
    AuthRemoteDataSource(),
  );

  late final RegisterDriverUseCase registerDriverUseCase =
      RegisterDriverUseCase(
        authRepository: _authRepository,
        storageService: StorageService(_supabaseService.client),
        supabaseService: _supabaseService,
      );
  // State variables
  String _email = '';
  String _name = '';
  bool _loading = false;
  int _currentStep = 0;
  final String _selectedCountryCode = '+53';
  final List<String> _selectedRoutes = [];
  bool viajes_locales = false;
  Ubicacion? _municipio;
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
          RegisterProgressIndicator(
            currentStep: _currentStep,
            stepTitles: _stepTitles,
          ),

          // Form content
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) => setState(() => _currentStep = index),
              children: [
                PersonalInfoStep(
                  formKey: _formKey,
                  nombreController: _nombreController,
                  apellidosController: _apellidosController,
                  emailController: _emailController,
                  phoneController: _phoneController,
                  passwordController: _passwordController,
                  confirmPasswordController: _confirmPasswordController,
                  obscurePassword: _obscurePassword,
                  obscureConfirmPassword: _obscureConfirmPassword,
                  onTogglePasswordVisibility:
                      () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                  onToggleConfirmPasswordVisibility:
                      () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                  validatePassword: RegisterValidators.validatePassword,
                  onNameChanged: (value) => _name = value,
                  onEmailChanged: (value) => _email = value,
                  validateConfirmPassword:
                      (value) => RegisterValidators.validateConfirmPassword(
                        value,
                        _passwordController.text,
                      ),
                ),
                DriverInfoStep(
                  licenseController: _licenseController,
                  vehicleCapacityController: _vehicleCapacityController,
                  munOrigenController: _mun_origenController,
                  municipio: _municipio,
                  onMunicipioSelected: (ubicacion) {
                    setState(() {
                      _municipio = ubicacion;
                    });
                  },
                  viajesLocales: viajes_locales,
                  onToggleViajesLocales: () {
                    setState(() {
                      viajes_locales = !viajes_locales;
                    });
                  },
                  selectedRoutes: _selectedRoutes,
                  onUpdateRoutes: (route, isSelected) {
                    setState(() {
                      if (isSelected) {
                        _selectedRoutes.add(route);
                      } else {
                        _selectedRoutes.remove(route);
                      }
                    });
                  },
                  buildImprovedRoutesSelector:
                      () => ImprovedRoutesSelector(
                        selectedRoutes: _selectedRoutes,
                        onUpdateRoutes: _updateRoutes,
                      ),
                ),
                PhotosStep(
                  hasProfilePhoto: hasProfilePhoto,
                  hasVehiclePhoto: hasVehiclePhoto,
                  onPickProfilePhoto: () => _pickImage(true),
                  onPickVehiclePhoto: () => _pickImage(false),
                  profilePhotoBytes: _profilePhotoBytes,
                  vehiclePhotoBytes: _vehiclePhotoBytes,
                  profilePhotoFile: _profilePhotoFile,
                  vehiclePhotoFile: _vehiclePhotoFile,
                ),
              ],
            ),
          ),

          // Navigation buttons
          RegisterNavigationButtons(
            currentStep: _currentStep,
            loading: _loading,
            onPrevious: _goToPreviousStep,
            onNext: _handleNextStep,
            isLastStep: _currentStep == 2,
          ),
        ],
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
      if (RegisterValidators.validateDriverInfo(
            _licenseController.text,
            _vehicleCapacityController.text,
            _selectedRoutes,
            viajes_locales,
          ) ==
          null) {
        _goToNextStep();
      } else {
        LogsMessages.showInfoError(
          context,
          RegisterValidators.validateDriverInfo(
            _licenseController.text,
            _vehicleCapacityController.text,
            _selectedRoutes,
            viajes_locales,
          )!,
        );
      }
    } else if (_currentStep == 2) {
      if (RegisterValidators.validateProfilePhoto(_profilePhotoBytes) == null &&
          RegisterValidators.validateVehiclePhoto(_vehiclePhotoBytes) == null) {
        _register();
      } else {
        LogsMessages.showInfoError(
          context,
          'Por favor, debe de subir ambas fotos',
        );
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

  // Existing methods (register, image picker, etc.)
  Future<void> _register() async {
    setState(() => _loading = true);

    RegisterDriverParams params = new RegisterDriverParams(
      email: _emailController.text,
      password: _passwordController.text,
      nombre: _nombreController.text,
      apellidos: _apellidosController.text,
      phone: _phoneController.text,
      licenseNumber: _licenseController.text,
      vehicleCapacity: _vehicleCapacityController.text,
      routes: _selectedRoutes,
      viajesLocales: viajes_locales,
      municipio: _municipio,
      profilePhotoBytes: _profilePhotoBytes,
      vehiclePhotoBytes: _vehiclePhotoBytes,
      profilePhotoFile: _profilePhotoFile,
      vehiclePhotoFile: _vehiclePhotoFile,
    );
    try {
      final error = await registerDriverUseCase(params);
      if (error != null) {
        LogsMessages.showInfoError(context, error);
      } else {
        // Mostrar el diálogo de éxito primero
        if (mounted) {
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) {
              return CustomDialog(
                title: 'Éxito',
                message: 'Su solicitud está pendiente a revisión, le notificaremos',
                buttonText: 'Ok',
                onPressed: () {
                  Navigator.of(context).pop();
                },
              );
            },
          );
          // Navegar al home después de cerrar el diálogo
          AppRoutes.router.go(AppRoutes.home);
        }
      }
    } catch (e) {
      LogsMessages.showInfoError(context, e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
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
