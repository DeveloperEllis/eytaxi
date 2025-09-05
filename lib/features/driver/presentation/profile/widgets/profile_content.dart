import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/features/driver/presentation/profile/driver_profile_view_model.dart';
import 'package:eytaxi/features/driver/presentation/profile/widgets/capacity_dropdown.dart';
import 'package:eytaxi/features/driver/presentation/profile/widgets/ciudad_origen_field.dart';
import 'package:eytaxi/features/driver/presentation/profile/widgets/driver_info.dart';
import 'package:eytaxi/features/driver/presentation/profile/widgets/profile_header.dart';
import 'package:eytaxi/features/driver/presentation/profile/widgets/profile_info.dart';
import 'package:eytaxi/features/driver/presentation/profile/widgets/routes_dropdown.dart';
import 'package:flutter/material.dart';

class ProfileContent extends StatelessWidget {
  final DriverProfileViewModel model;
  final bool isEditing;
  final GlobalKey<FormState> formKey;
  
  // Controllers
  final TextEditingController nombreController;
  final TextEditingController apellidosController;
  final TextEditingController phoneController;
  final TextEditingController licenseController;
  final TextEditingController ciudadOrigenController;
  
  // State variables
  final Ubicacion? selectedCiudadOrigen;
  final int? selectedCapacity;
  final Set<String> selectedRoutes;
  final bool viajesLocales;
  final List<int> capacityOptions;
  final List<String> availableRoutes;
  
  // Callbacks
  final VoidCallback onToggleEdit;
  final VoidCallback onCancelEdit;
  final VoidCallback onSaveChanges;
  final Function(Ubicacion?) onCiudadOrigenSelected;
  final Function(int?) onCapacityChanged;
  final Function(String, bool) onRouteChanged;
  final VoidCallback onViajesLocalesToggle;
  final VoidCallback onEditProfilePhoto;
  final VoidCallback onEditVehiclePhoto;

  const ProfileContent({
    super.key,
    required this.model,
    required this.isEditing,
    required this.formKey,
    required this.nombreController,
    required this.apellidosController,
    required this.phoneController,
    required this.licenseController,
    required this.ciudadOrigenController,
    required this.selectedCiudadOrigen,
    required this.selectedCapacity,
    required this.selectedRoutes,
    required this.viajesLocales,
    required this.capacityOptions,
    required this.availableRoutes,
    required this.onToggleEdit,
    required this.onCancelEdit,
    required this.onSaveChanges,
    required this.onCiudadOrigenSelected,
    required this.onCapacityChanged,
    required this.onRouteChanged,
    required this.onViajesLocalesToggle,
    required this.onEditProfilePhoto,
    required this.onEditVehiclePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: formKey,
        child: CustomScrollView(
          slivers: [
            // Header with cover photo and profile photo
            _buildProfileHeader(),

            // Profile info and other content
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // Profile Info Card
                  ProfileInfo(
                    isEditing: isEditing,
                    nombreController: nombreController,
                    apellidosController: apellidosController,
                    phoneController: phoneController,
                    profilePhotoUrl: _getProfilePhotoUrl(),
                    onEditProfilePhoto: onEditProfilePhoto,
                  ),

                  // Driver Info Card
                  DriverInfo(
                    isEditing: isEditing,
                    driver: model.driver,
                    licenseController: licenseController,
                    capacityDropdown: _buildCapacityDropdown(),
                    ciudadOrigenField: _buildCiudadOrigenField(),
                    routesDropdown: _buildRoutesDropdown(),
                  ),

                  const SizedBox(height: 100), // Space for FAB
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: model.loading ? null : _buildFloatingActionButton(),
    );
  }

  Widget _buildProfileHeader() {
    return ProfileHeader(
      profilePhotoUrl: _getProfilePhotoUrl(),
      vehiclePhotoUrl: model.driver?.vehiclePhotoUrl,
      isEditing: isEditing,
      onEditProfilePhoto: onEditProfilePhoto,
      onEditVehiclePhoto: onEditVehiclePhoto,
    );
  }

  Widget _buildCapacityDropdown() {
    return CapacityDropdown(
      selectedCapacity: selectedCapacity,
      onChanged: onCapacityChanged,
      capacityOptions: capacityOptions,
    );
  }

  Widget _buildCiudadOrigenField() {
    return CiudadOrigenField(
      controller: ciudadOrigenController,
      selectedLocation: selectedCiudadOrigen,
      onSelected: onCiudadOrigenSelected,
    );
  }

  Widget _buildRoutesDropdown() {
    return RoutesDropdown(
      selectedRoutes: selectedRoutes,
      viajesLocales: viajesLocales,
      availableRoutes: availableRoutes,
      onRouteChanged: onRouteChanged,
      onViajesLocalesToggle: onViajesLocalesToggle,
    );
  }

  Widget _buildFloatingActionButton() {
    return isEditing
        ? Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                onPressed: onSaveChanges,
                icon: const Icon(Icons.check),
                label: const Text('Guardar'),
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                heroTag: "save",
              ),
              const SizedBox(width: 16),
              FloatingActionButton.extended(
                onPressed: onCancelEdit,
                icon: const Icon(Icons.close),
                label: const Text('Cancelar'),
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                heroTag: "cancel",
              ),
            ],
          )
        : FloatingActionButton.extended(
            onPressed: onToggleEdit,
            icon: const Icon(Icons.edit),
            label: const Text('Editar'),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            heroTag: "edit",
          );
  }

  String? _getProfilePhotoUrl() {
    final up = model.userProfile ?? {};
    return up['photo_url'] as String?;
  }
}
