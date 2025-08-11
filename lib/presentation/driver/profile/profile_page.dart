import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/models/taxista_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  // Controllers para los campos editables
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _capacityController = TextEditingController();
  final TextEditingController _mun_origenController = TextEditingController();

  // Rutas disponibles del sistema
  final List<String> _availableRoutes = ['Occidente', 'Centro', 'Oriente'];
  
  String driverName = '';
  String apellidos = '';
  String email = '';
  String? profileImageUrl;
  String? vehiclePhotoUrl;
  String licenseNumber = '';
  String? municipio_de_origen;
  String phoneNumber = '';
  int vehicleCapacity = 0;
  bool viajes_locales = false;
  List<String> routes = [];
  Set<String> selectedRoutes = {}; // Para manejar los checkboxes
  bool isAvailable = true;
  String driverStatus = 'pending';
  double rating = 0.0;
  int totalTrips = 0;
  bool isLoading = true;
  bool isEditing = false;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadProfile();
  }

  void _setupAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }
  
  

  @override
  void dispose() {
    _fadeController.dispose();
    _nameController.dispose();
    _mun_origenController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _capacityController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() => _handleSupabaseQuery(() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) throw Exception('No authenticated user');

    final profileResponse =
        await Supabase.instance.client
            .from('user_profiles')
            .select('nombre, apellidos, email, phone_number, photo_url')
            .eq('id', user.id)
            .single();

    final driverResponse =
        await Supabase.instance.client
    .from('drivers')
    .select(
      '''
      license_number, 
      vehicle_photo_url, 
      vehicle_capacity, 
      routes, 
      is_available, 
      rating, 
      total_trips, 
      id_municipio_de_origen, 
      viajes_locales,  
      driver_status, 
      origen:ubicaciones_cuba!id_municipio_de_origen(
        id,
        nombre,
        codigo,
        region,
        tipo,
        provincia
      )
      '''
    )
    .eq('id', user.id)
    .single();

     
       
      
     

    setState(() {
      driverName = profileResponse['nombre'] ?? 'Conductor';
      apellidos = profileResponse['apellidos'] ?? '';
      email = profileResponse['email'] ?? '';
      phoneNumber = profileResponse['phone_number'] ?? '';
      profileImageUrl = profileResponse['photo_url'];
      licenseNumber = driverResponse['license_number'] ?? '';
      vehiclePhotoUrl = driverResponse['vehicle_photo_url'];
      vehicleCapacity = driverResponse['vehicle_capacity'] ?? 0;
      routes = List<String>.from(driverResponse['routes'] ?? []);
      selectedRoutes = Set<String>.from(routes); // Inicializar selectedRoutes
      isAvailable = driverResponse['is_available'] ?? true;
      rating = (driverResponse['rating'] ?? 0.0).toDouble();
      totalTrips = driverResponse['total_trips'] ?? 0;
      driverStatus = driverResponse['driver_status'] ?? 'pending';
      isLoading = false;
    });

    // Llenar los controladores con los datos actuales
    _nameController.text = driverName;
    _lastNameController.text = apellidos;
    _phoneController.text = phoneNumber;
    _licenseController.text = licenseNumber;
    _capacityController.text = vehicleCapacity.toString();

    _fadeController.forward();
  }, errorMessage: 'Error al cargar el perfil');

  Future<void> _handleSupabaseQuery(
    Future<void> Function() query, {
    required String errorMessage,
  }) async {
    try {
      await query();
    } catch (e) {
      print('$errorMessage: $e');
      setState(() => isLoading = false);
      if (mounted) {
        _showSnackBar(errorMessage, isError: true);
      }
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    _scaffoldMessengerKey.currentState?.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
      if (!isEditing) {
        // Si cancelamos la edición, restauramos los valores originales
        _nameController.text = driverName;
        _lastNameController.text = apellidos;
        _phoneController.text = phoneNumber;
        _licenseController.text = licenseNumber;
        _capacityController.text = vehicleCapacity.toString();
        selectedRoutes = Set<String>.from(routes);
      }
    });
  }

  Future<void> _saveChanges() async {
    if (isSaving) return;

    // Validar formulario
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Por favor corrige los errores en el formulario', isError: true);
      return;
    }

    // Validar que tenga al menos una ruta seleccionada
    if (selectedRoutes.isEmpty) {
      _showSnackBar('Debe seleccionar al menos una ruta', isError: true);
      return;
    }

    setState(() => isSaving = true);

    await _handleSupabaseQuery(() async {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) throw Exception('No authenticated user');

      final updatedRoutes = selectedRoutes.toList();

      // Actualizar perfil de usuario
      await Supabase.instance.client
          .from('user_profiles')
          .update({
            'nombre': _nameController.text.trim(),
            'apellidos': _lastNameController.text.trim(),
            'phone_number': _phoneController.text.trim(),
          })
          .eq('id', user.id);

      // Actualizar información del conductor
      await Supabase.instance.client
          .from('drivers')
          .update({
            'license_number': _licenseController.text.trim(),
            'vehicle_capacity': int.parse(_capacityController.text),
            'routes': updatedRoutes,
            'is_available': isAvailable,
            'viajes_locales': viajes_locales,
            //'id_municipio_de_origen': municipio_de_origen            
          })
          .eq('id', user.id);

      // Actualizar el estado local
      setState(() {
        driverName = _nameController.text.trim();
        apellidos = _lastNameController.text.trim();
        phoneNumber = _phoneController.text.trim();
        licenseNumber = _licenseController.text.trim();
        vehicleCapacity = int.parse(_capacityController.text);
        routes = updatedRoutes;
        isEditing = false;
        isSaving = false;
      });

      _showSnackBar('Perfil actualizado exitosamente');
    }, errorMessage: 'Error al guardar los cambios');

    if (mounted) {
      setState(() => isSaving = false);
    }
  }

  // Validadores
  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es requerido';
    }
    if (value.trim().length < 2) {
      return 'Debe tener al menos 2 caracteres';
    }
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(value.trim())) {
      return 'Solo se permiten letras';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El teléfono es requerido';
    }
    // Validar formato de teléfono básico
    if (!RegExp(r'^[0-9+\-\s()]+$').hasMatch(value.trim())) {
      return 'Formato de teléfono inválido';
    }
    if (value.replaceAll(RegExp(r'[^0-9]'), '').length < 8) {
      return 'Número de teléfono muy corto';
    }
    return null;
  }

  String? _validateLicense(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'El número de licencia es requerido';
    }
    if (value.trim().length < 5) {
      return 'Número de licencia muy corto';
    }
    return null;
  }

  String? _validateCapacity(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'La capacidad es requerida';
    }
    final capacity = int.tryParse(value.trim());
    if (capacity == null) {
      return 'Debe ser un número válido';
    }
    if (capacity < 1 || capacity > 50) {
      return 'La capacidad debe estar entre 1 y 50';
    }
    return null;
  }

  Future<void> _editProfileImage() async {
    _showSnackBar('Funcionalidad de edición de foto de perfil en desarrollo');
  }

  Future<void> _editCarImage() async {
    _showSnackBar('Funcionalidad de edición de foto del vehículo en desarrollo');
  }

  void _toggleAvailability() {
    setState(() {
      isAvailable = !isAvailable;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldMessengerKey,
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? _buildLoadingState()
          : Form(
              key: _formKey,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          _buildProfilePhotos(),
                          const SizedBox(height: 16),
                          _buildProfileName(),
                          const SizedBox(height: 8),
                          _buildStatsSection(),
                          _buildPersonalInfoSection(),
                          _buildVehicleSection(),
                          _buildRoutesSection(),
                          _buildActionsSection(),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfilePhotos() {
    return Stack(
      children: [
        Image.network(
          vehiclePhotoUrl ?? '',
          errorBuilder:
              (context, error, stackTrace) => _buildDefaultBackground(),
          width: double.infinity,
          height: 180,
          fit: BoxFit.cover,
        ),
        Container(
          width: double.infinity,
          height: 180,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withOpacity(0.4), Colors.transparent],
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 8,
          child: GestureDetector(
            onTap: _editCarImage,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.primary,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
        _buildProfileHeader(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cargando perfil...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.directions_car_rounded,
          size: 80,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Transform.translate(
      offset: const Offset(10, 110),
      child: Column(
        children: [
          Hero(
            tag: 'profile_image',
            child: Stack(
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 48,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: profileImageUrl != null
                        ? NetworkImage(profileImageUrl!)
                        : null,
                    child: profileImageUrl == null
                        ? Icon(
                            Icons.person_rounded,
                            size: 48,
                            color: Colors.grey[400],
                          )
                        : null,
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: GestureDetector(
                    onTap: _editProfileImage,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileName() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          '$driverName $apellidos',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          email,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            'Calificación',
            rating.toStringAsFixed(1),
            Icons.star_rounded,
            Colors.amber.shade600,
          ),
          _buildVerticalDivider(),
          _buildStatItem(
            'Viajes',
            totalTrips.toString(),
            Icons.route_rounded,
            AppColors.primary,
          ),
          _buildVerticalDivider(),
          _buildAvailabilityToggle(),
        ],
      ),
    );
  }

  Widget _buildAvailabilityToggle() {
    return Expanded(
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleAvailability,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: ( Colors.green).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isAvailable ? Icons.check_circle : Icons.cancel,
                color:  Colors.green.shade600 ,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Aprobado',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Estado',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalDivider() {
    return Container(height: 50, width: 1, color: Colors.grey[300]);
  }

  Widget _buildPersonalInfoSection() {
    return _buildSection(
      'Información Personal',
      Icons.person_outline_rounded,
      Colors.blue.shade50,
      Colors.blue.shade600,
      [
        _buildEditableInfoRow(
          'Nombre',
          _nameController,
          Icons.badge_rounded,
          validator: _validateName,
        ),

        _buildEditableInfoRow(
          'Municipio donde Radica',
          _lastNameController,
          Icons.badge_rounded,
          validator: _validateName,
        ),
        
        _buildEditableInfoRow(
          'Apellidos',
          _lastNameController,
          Icons.badge_rounded,
          validator: _validateName,
        ),
        _buildEditableInfoRow(
          'Teléfono',
          _phoneController,
          Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          validator: _validatePhone,
        ),
        _buildInfoRow('Correo', email, Icons.email_rounded),
      ],
    );
  }

  Widget _buildVehicleSection() {
    return _buildSection(
      'Información del Vehículo',
      Icons.directions_car_outlined,
      Colors.green.shade50,
      Colors.green.shade600,
      [
        _buildEditableInfoRow(
          'Número de Licencia',
          _licenseController,
          Icons.card_membership_rounded,
          validator: _validateLicense,
        ),
        _buildEditableInfoRow(
          'Capacidad del Vehículo',
          _capacityController,
          Icons.people_rounded,
          keyboardType: TextInputType.number,
          suffix: 'pasajeros',
          validator: _validateCapacity,
        ),
        _buildInfoRow(
          'Estado del Conductor',
          _getDriverStatusText(),
          Icons.verified_user_rounded,
        ),
      ],
    );
  }

  Widget _buildRoutesSection() {
    return _buildSection(
      'Rutas Disponibles',
      Icons.route_rounded,
      Colors.purple.shade50,
      Colors.purple.shade600,
      [_buildRoutesSelection()],
    );
  }

  Widget _buildRoutesSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isEditing) ...[
          Text(
            'Selecciona las rutas que cubres:',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          
          ..._availableRoutes.map((route) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: selectedRoutes.contains(route) 
                      ? Colors.purple.shade50 
                      : Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selectedRoutes.contains(route)
                        ? Colors.purple.shade200
                        : Colors.grey.shade200,
                  ),
                ),
                child: CheckboxListTile(
                  title: Text(
                    route,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: selectedRoutes.contains(route)
                          ? Colors.purple.shade700
                          : Colors.grey.shade700,
                    ),
                  ),
                  value: selectedRoutes.contains(route),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        selectedRoutes.add(route);
                      } else {
                        selectedRoutes.remove(route);
                      }
                    });
                  },
                  activeColor: Colors.purple.shade600,
                  checkColor: Colors.white,
                  controlAffinity: ListTileControlAffinity.leading,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                ),
              )).toList(),
          if (selectedRoutes.isEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red.shade600, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Debe seleccionar al menos una ruta',
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
        ] else ...[
          _buildRoutesDisplay(),
        ],
      ],
    );
  }

  Widget _buildRoutesDisplay() {
    if (routes.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Center(
          child: Column(
            children: [
              Icon(Icons.route_rounded, color: Colors.grey[400], size: 32),
              const SizedBox(height: 8),
              Text(
                'No hay rutas configuradas',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: routes
          .map(
            (route) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple.shade200),
              ),
              child: Text(
                route,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.purple.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _buildSection(
    String title,
    IconData titleIcon,
    Color backgroundColor,
    Color accentColor,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(titleIcon, color: accentColor, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 1,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            color: Colors.grey[200],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableInfoRow(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    String? suffix,
    String? Function(String?)? validator,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                if (isEditing)
                  TextFormField(
                    controller: controller,
                    keyboardType: keyboardType,
                    validator: validator,
                    decoration: InputDecoration(
                      suffixText: suffix,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColors.primary),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red.shade600),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.red.shade600),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      errorStyle: TextStyle(
                        fontSize: 12,
                        color: Colors.red.shade600,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                else
                  Text(
                    controller.text.isEmpty
                        ? 'No especificado'
                        : '${controller.text}${suffix != null ? ' $suffix' : ''}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.grey[600], size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black87,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        children: [
          if (!isEditing) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: _toggleEditMode,
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                label: const Text('Editar Perfil'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ] else ...[
            // Botones de guardar y cancelar cuando está en modo edición
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green.shade600,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton.icon(
                      onPressed: isSaving ? null : _saveChanges,
                      icon: isSaving
                          ? SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Icon(Icons.save_rounded, color: Colors.white),
                      label: Text(isSaving ? 'Guardando...' : 'Guardar'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isSaving ? null : _toggleEditMode,
                    icon: const Icon(Icons.cancel_rounded),
                    label: const Text('Cancelar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red.shade600,
                      side: BorderSide(
                        color: Colors.red.shade300,
                        width: 1.5,
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          
        ],
      ),
    );
  }

  String _getDriverStatusText() {
    switch (driverStatus) {
      case 'approved':
        return 'Conductor Aprobado';
      case 'pending':
        return 'Esperando Aprobación';
      case 'rejected':
        return 'Solicitud Rechazada';
      default:
        return 'Estado Desconocido';
    }
  }
}