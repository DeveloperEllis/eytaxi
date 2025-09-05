import 'dart:io';
import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/core/services/storage_service.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/data/models/user_model.dart';
import 'package:eytaxi/features/auth/utils/register_validators.dart';
import 'package:eytaxi/features/driver/data/datasources/driver_profile_remote_datasource.dart';
import 'package:eytaxi/features/driver/data/repositories/driver_profile_repository_impl.dart';
import 'package:eytaxi/features/driver/presentation/profile/driver_profile_view_model.dart';
import 'package:eytaxi/features/trip_request/presentation/pages/widgets/location_autocomplete.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final DriverProfileViewModel _vm;
  bool _isEditing = false;

  // Form key para validaciones
  final _formKey = GlobalKey<FormState>();

  // Controllers para los campos editables
  late final TextEditingController _nombreController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _phoneController;
  late final TextEditingController _licenseController;
  late final TextEditingController _capacityController;
  late final TextEditingController _routesController;
  late final TextEditingController _ciudadOrigenController;

  // Variables para la ciudad de origen
  Ubicacion? _selectedCiudadOrigen;

  // Dropdown para capacidad
  int? _selectedCapacity;
  final List<int> _capacityOptions = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    10,
    12,
    15,
    20,
  ];

  // Rutas con checkboxes
  final List<String> _availableRoutes = ['oriente', 'occidente', 'centro'];
  final Set<String> _selectedRoutes = {};

  // Variable separada para viajes locales
  bool _viajesLocales = false;

  @override
  void initState() {
    super.initState();

    // Inicializar controllers
    _nombreController = TextEditingController();
    _apellidosController = TextEditingController();
    _phoneController = TextEditingController();
    _licenseController = TextEditingController();
    _capacityController = TextEditingController();
    _routesController = TextEditingController();
    _ciudadOrigenController = TextEditingController();

    final user = Supabase.instance.client.auth.currentUser;
    final repo = DriverProfileRepositoryImpl(
      DriverProfileRemoteDataSource(Supabase.instance.client),
    );
    final storage = StorageService(Supabase.instance.client);
    _vm = DriverProfileViewModel(
      repo: repo,
      storage: storage,
      userId: user?.id ?? '',
    );

    // Cargar datos después de que el widget se haya construido
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _vm.load();
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidosController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _capacityController.dispose();
    _routesController.dispose();
    _ciudadOrigenController.dispose();
    super.dispose();
  }

  void _updateControllers(DriverProfileViewModel model) {
    final up = model.userProfile ?? {};
    _nombreController.text = up['nombre'] as String? ?? '';
    _apellidosController.text = up['apellidos'] as String? ?? '';
    _phoneController.text = up['phone_number'] as String? ?? '';

    if (model.driver != null) {
      _licenseController.text = model.driver!.licenseNumber;
      _capacityController.text = model.driver!.vehicleCapacity.toString();
      _selectedCapacity =
          model.driver!.vehicleCapacity > 0
              ? model.driver!.vehicleCapacity
              : null;
      _routesController.text = model.driver!.routes.join(', ');

      // Actualizar rutas seleccionadas
      _selectedRoutes.clear();
      _selectedRoutes.addAll(model.driver!.routes);

      // Actualizar viajes locales
      _viajesLocales = model.driver!.viajes_locales;

      // Actualizar ciudad de origen
      _selectedCiudadOrigen = model.driver!.origen;
      if (_selectedCiudadOrigen != null) {
        final ciudadText = '${_selectedCiudadOrigen!.nombre} (${_selectedCiudadOrigen!.codigo})';
        _ciudadOrigenController.text = ciudadText;
        print('DEBUG: Ciudad de origen cargada: $ciudadText');
        print('DEBUG: Ubicacion objeto: $_selectedCiudadOrigen');
      } else {
        _ciudadOrigenController.text = '';
        print('DEBUG: Ciudad de origen es nula');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _vm,
      child: Consumer<DriverProfileViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            backgroundColor: Colors.grey.shade100,
            body:
                model.loading
                    ? const Center(child: CircularProgressIndicator())
                    : _buildProfileContent(model),
            floatingActionButton:
                !model.loading && model.error == null
                    ? _isEditing
                        ? Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            FloatingActionButton.extended(
                              onPressed: () => _saveChanges(model),
                              icon: const Icon(Icons.save),
                              label: const Text('Guardar'),
                              backgroundColor: AppColors.primary,
                              foregroundColor: Colors.white,
                              heroTag: "save",
                            ),
                            const SizedBox(width: 10),
                            FloatingActionButton.extended(
                              onPressed: () {
                                setState(() {
                                  _isEditing = false;
                                });
                                _updateControllers(model);
                              },
                              icon: const Icon(Icons.close),
                              label: const Text('Cancelar'),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              heroTag: "cancel",
                            ),
                          ],
                        )
                        : FloatingActionButton.extended(
                          onPressed: () {
                            setState(() {
                              _isEditing = true;
                            });
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('Editar'),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          heroTag: "edit",
                        )
                    : null,
          );
        },
      ),
    );
  }

  Widget _buildProfileContent(DriverProfileViewModel model) {
    if (model.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              'Error al cargar el perfil',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.red.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              model.error!,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                model.clearError();
                model.load();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Reintentar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Form(
      key: _formKey,
      child: CustomScrollView(
        slivers: [
          // Header with cover photo and profile photo
          _buildProfileHeader(model),

          // Profile info and other content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
              children: [
                const SizedBox(height: 10), // Space for profile photo
                _buildUserInfo(model),
                const SizedBox(height: 20),
                // Botón para recargar datos
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildProfileHeader(DriverProfileViewModel model) {
    final up = model.userProfile ?? {};
    final profilePhotoUrl = up['photo_url'] as String?;
    final vehiclePhotoUrl = model.driver?.vehiclePhotoUrl;

    return SliverAppBar(
      expandedHeight: 250,
      floating: false,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Foto del vehículo como fondo (cover photo)
            _buildCoverPhoto(vehiclePhotoUrl, model),

            // Foto de perfil superpuesta
            Positioned(
              bottom: 20,
              left: 20,
              child: _buildProfilePhoto(profilePhotoUrl, model),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverPhoto(
    String? vehiclePhotoUrl,
    DriverProfileViewModel model,
  ) {
    return GestureDetector(
      onTap: () => _pickAndUploadVehiclePhoto(model, ImageSource.gallery),
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          image:
              vehiclePhotoUrl != null
                  ? DecorationImage(
                    image: NetworkImage(vehiclePhotoUrl),
                    fit: BoxFit.cover,
                  )
                  : null,
        ),
        child:
            vehiclePhotoUrl == null
                ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary.withOpacity(0.7),
                        AppColors.primary.withOpacity(0.9),
                      ],
                    ),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.directions_car,
                          size: 48,
                          color: Colors.white,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Toca para agregar foto del vehículo',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                )
                : Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.3),
                      ],
                    ),
                  ),
                  child: const Align(
                    alignment: Alignment.topRight,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Icon(
                        Icons.camera_alt,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                ),
      ),
    );
  }

  Widget _buildProfilePhoto(
    String? profilePhotoUrl,
    DriverProfileViewModel model,
  ) {
    return GestureDetector(
      onTap: () => _pickAndUploadProfilePhoto(model, ImageSource.gallery),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: CircleAvatar(
          radius: 56,
          backgroundColor: Colors.grey.shade300,
          backgroundImage:
              profilePhotoUrl != null ? NetworkImage(profilePhotoUrl) : null,
          child:
              profilePhotoUrl == null
                  ? const Icon(Icons.person, size: 50, color: Colors.grey)
                  : null,
        ),
      ),
    );
  }

  Widget _buildUserInfo(DriverProfileViewModel model) {
    // Actualizar controllers cuando cambien los datos
    if (!_isEditing) {
      _updateControllers(model);
    }

    final up = model.userProfile ?? {};
    final email = up['email'] as String? ?? '';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Nombre y apellidos
          if (_isEditing) ...[
            _buildEditableField(
              label: 'Nombre',
              controller: _nombreController,
              icon: Icons.person,
              validator: (value) => RegisterValidators.validateNonEmpty(value, 'nombre'),
            ),
            const SizedBox(height: 16),
            _buildEditableField(
              label: 'Apellidos',
              controller: _apellidosController,
              icon: Icons.person_outline,
              validator: (value) => RegisterValidators.validateNonEmpty(value, 'apellidos'),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Text(
              '${_nombreController.text} ${_apellidosController.text}'
                      .trim()
                      .isNotEmpty
                  ? '${_nombreController.text} ${_apellidosController.text}'
                      .trim()
                  : 'Usuario sin nombre',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          // Email (no editable - solo mostrar cuando no esté editando)
          if (!_isEditing && email.isNotEmpty) ...[
            Text(
              email,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
          ],

          // Teléfono
          if (_isEditing) ...[
            _buildEditableField(
              label: 'Teléfono',
              controller: _phoneController,
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              validator: RegisterValidators.validatePhone,
            ),
            const SizedBox(height: 16),
          ] else if (_phoneController.text.isNotEmpty) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  _phoneController.text,
                  style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],

          // Estado del conductor (solo mostrar cuando no esté editando)
          if (!_isEditing && model.driver != null) ...[
            const SizedBox(height: 12),
          ],

          // Información adicional del conductor
          if (model.driver != null) ...[
            if (_isEditing) ...[
              _buildEditableField(
                label: 'Número de licencia',
                controller: _licenseController,
                icon: Icons.credit_card,
                validator: (value) => RegisterValidators.validateNonEmpty(value, 'número de licencia'),
              ),
              const SizedBox(height: 16),
              _buildCiudadOrigenField(),
              const SizedBox(height: 16),
              _buildCapacityDropdown(),
              const SizedBox(height: 16),
              _buildRoutesDropdown(),
              const SizedBox(height: 16),
            ] else ...[
              if (_licenseController.text.isNotEmpty) ...[
                _buildInfoRow(
                  icon: Icons.credit_card,
                  label: 'Licencia',
                  value: _licenseController.text,
                ),
                const SizedBox(height: 8),
              ],

              if (_capacityController.text.isNotEmpty &&
                  _capacityController.text != '0') ...[
                _buildInfoRow(
                  icon: Icons.people,
                  label: 'Capacidad',
                  value: '${_capacityController.text} pasajeros',
                ),
                const SizedBox(height: 8),
              ],

              if (model.driver!.routes.isNotEmpty) ...[
                _buildInfoRow(
                  icon: Icons.route,
                  label: 'Rutas',
                  value: model.driver!.routes.join(', '),
                ),
                const SizedBox(height: 8),
              ],

              // Mostrar viajes locales
              _buildInfoRow(
                icon: Icons.location_on,
                label: 'Viajes locales',
                value: model.driver!.viajes_locales ? 'Sí' : 'No',
              ),
              const SizedBox(height: 8),

              // Mostrar ciudad de origen
              if (model.driver!.origen != null) ...[
                _buildInfoRow(
                  icon: Icons.home_work,
                  label: 'Ciudad de residencia',
                  value:
                      '${model.driver!.origen!.nombre} (${model.driver!.origen!.codigo})',
                ),
              ],
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildCapacityDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCapacity,
      decoration: InputDecoration(
        labelText: 'Capacidad de vehículo',
        prefixIcon: Icon(Icons.people, color: AppColors.primary),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
      hint: const Text('Selecciona la capacidad'),
      items:
          _capacityOptions.map((int capacity) {
            return DropdownMenuItem<int>(
              value: capacity,
              child: Text(
                '$capacity ${capacity == 1 ? 'pasajero' : 'pasajeros'}',
              ),
            );
          }).toList(),
      onChanged: (int? newValue) {
        setState(() {
          _selectedCapacity = newValue;
          if (newValue != null) {
            _capacityController.text = newValue.toString();
          }
        });
      },
    );
  }

  Widget _buildRoutesDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.route, color: AppColors.primary, size: 20),
            const SizedBox(width: 8),
            Text(
              'Rutas de operación',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(12),
            color: Colors.grey.shade50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rutas principales (Oriente, Occidente, Centro)
              ..._availableRoutes.map((route) {
                return CheckboxListTile(
                  title: Text(
                    route.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  value: _selectedRoutes.contains(route),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _selectedRoutes.add(route);
                      } else {
                        _selectedRoutes.remove(route);
                      }
                      // Actualizar el controller para mantener compatibilidad
                      _routesController.text = _selectedRoutes.join(', ');
                    });
                  },
                  activeColor: AppColors.primary,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }),

              // Separador visual
              if (_availableRoutes.isNotEmpty) ...[
                const SizedBox(height: 8),
                Divider(color: Colors.grey.shade300, thickness: 1),
                const SizedBox(height: 8),
              ],

              // Checkbox para Viajes Locales
              CheckboxListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'VIAJES LOCALES',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      'Rutas locales dentro de la provincia',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                value: _viajesLocales,
                onChanged: (bool? value) {
                  setState(() {
                    _viajesLocales = value ?? false;
                  });
                },
                activeColor: Colors.green,
                checkColor: Colors.white,
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                dense: true,
              ),
            ],
          ),
        ),
        if (_selectedRoutes.isNotEmpty) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.primary.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Seleccionadas: ${_selectedRoutes.join(', ')}',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCiudadOrigenField() {
    return LocationAutocomplete(
      controller: _ciudadOrigenController,
      labelText: 'Selecciona tu ciudad de residencia',
      selectedLocation: _selectedCiudadOrigen,
      onSelected: (Ubicacion? selected) {
        setState(() {
          _selectedCiudadOrigen = selected;
        });
      },
      user: UserType.driver,
    );
  }

  String? _validateAdditionalFields() {
    // Validar información del conductor si existe
    if (_vm.driver != null) {
      // Validar capacidad del vehículo
      if (_selectedCapacity == null || _selectedCapacity! <= 0) {
        return 'Seleccione la capacidad del vehículo';
      }

      // Validar rutas y viajes locales
      if (_selectedRoutes.isEmpty && !_viajesLocales) {
        return 'Seleccione al menos una ruta o active la opción de viajes locales';
      }

      // Validar ciudad de origen
      if (_selectedCiudadOrigen == null) {
        return 'Seleccione su ciudad de origen';
      }
    }

    return null; // Todo válido
  }

  Future<void> _saveChanges(DriverProfileViewModel model) async {
    // Validar formulario antes de guardar
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, corrija los errores en el formulario'),
          backgroundColor: Colors.red,
        ),
      );
      return; // No continuar si hay errores de validación
    }

    // Validar campos adicionales que no están en el formulario
    final validationError = _validateAdditionalFields();
    if (validationError != null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(validationError),
            backgroundColor: Colors.red,
          ),
        );
      }
      return; // No continuar si hay errores de validación
    }

    // Mostrar indicador de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => const AlertDialog(
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(width: 16),
                Text('Guardando cambios...'),
              ],
            ),
          ),
    );

    try {
      // Actualizar perfil de usuario
      final userProfileSuccess = await model.updateProfile(
        nombre: _nombreController.text.trim(),
        apellidos: _apellidosController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
      );

      // Actualizar información del conductor si existe
      bool driverInfoSuccess = true;
      if (model.driver != null) {
        // Preparar las rutas desde las selecciones
        List<String>? routes;
        if (_selectedRoutes.isNotEmpty) {
          routes = _selectedRoutes.toList();
        }

        driverInfoSuccess = await model.updateDriverInfo(
          licenseNumber: _licenseController.text.trim(),
          vehicleCapacity: _selectedCapacity,
          routes: routes,
          viajesLocales: _viajesLocales,
          idMunicipioDeOrigen: _selectedCiudadOrigen?.id,
        );
      }

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (userProfileSuccess && driverInfoSuccess) {
        setState(() {
          _isEditing = false;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Perfil actualizado correctamente'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(model.error ?? 'Error al actualizar el perfil'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar diálogo de carga si está abierto
      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _pickAndUploadProfilePhoto(
    DriverProfileViewModel model,
    ImageSource source,
  ) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) return;

      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Subiendo foto de perfil...'),
                  ],
                ),
              ),
        );
      }

      bool success = false;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        success = await model.changePhoto(webBytes: bytes);
      } else {
        success = await model.changePhoto(file: File(pickedFile.path));
      }

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Foto de perfil actualizada exitosamente'
                : 'Error al actualizar la foto de perfil',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _pickAndUploadVehiclePhoto(
    DriverProfileViewModel model,
    ImageSource source,
  ) async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile == null) return;

      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder:
              (context) => const AlertDialog(
                content: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(width: 16),
                    Text('Subiendo foto del vehículo...'),
                  ],
                ),
              ),
        );
      }

      bool success = false;

      if (kIsWeb) {
        final bytes = await pickedFile.readAsBytes();
        success = await model.changeVehiclePhoto(webBytes: bytes);
      } else {
        success = await model.changeVehiclePhoto(file: File(pickedFile.path));
      }

      // Cerrar diálogo de carga
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success
                ? 'Foto del vehículo actualizada exitosamente'
                : 'Error al actualizar la foto del vehículo',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
