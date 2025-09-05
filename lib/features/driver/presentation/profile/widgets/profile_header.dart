import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ProfileHeader extends StatelessWidget {
  final String? profilePhotoUrl;
  final String? vehiclePhotoUrl;
  final bool isEditing;
  final VoidCallback onEditProfilePhoto;
  final VoidCallback onEditVehiclePhoto;

  const ProfileHeader({
    super.key,
    this.profilePhotoUrl,
    this.vehiclePhotoUrl,
    required this.isEditing,
    required this.onEditProfilePhoto,
    required this.onEditVehiclePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: AppColors.primary,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Foto del vehículo como fondo
            if (vehiclePhotoUrl != null && vehiclePhotoUrl!.isNotEmpty)
              Image.network(
                vehiclePhotoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: Icon(
                      Icons.directions_car,
                      size: 100,
                      color: Colors.grey.shade600,
                    ),
                  );
                },
              )
            else
              Container(
                color: Colors.grey.shade300,
                child: Icon(
                  Icons.directions_car,
                  size: 100,
                  color: Colors.grey.shade600,
                ),
              ),

            // Overlay para mejorar contraste
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),

            // Botón para editar foto del vehículo
            if (isEditing)
              Positioned(
                top: 100,
                right: 20,
                child: FloatingActionButton.small(
                  heroTag: "edit_vehicle",
                  onPressed: onEditVehiclePhoto,
                  backgroundColor: Colors.white.withOpacity(0.9),
                  child: Icon(Icons.camera_alt, color: AppColors.primary),
                ),
              ),
          ],
        ),
      ),
    );
  }

  static Future<void> showImagePickerDialog({
    required BuildContext context,
    required Function(ImageSource) onImageSelected,
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar imagen'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Cámara'),
              onTap: () {
                Navigator.pop(context);
                onImageSelected(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Galería'),
              onTap: () {
                Navigator.pop(context);
                onImageSelected(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }
}
