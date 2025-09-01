import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:eytaxi/core/constants/app_colors.dart';

class PhotosStep extends StatelessWidget {
  final bool hasProfilePhoto;
  final bool hasVehiclePhoto;
  final VoidCallback onPickProfilePhoto;
  final VoidCallback onPickVehiclePhoto;
  final Uint8List? profilePhotoBytes;
  final Uint8List? vehiclePhotoBytes;
  final File? profilePhotoFile;
  final File? vehiclePhotoFile;

  const PhotosStep({
    super.key,
    required this.hasProfilePhoto,
    required this.hasVehiclePhoto,
    required this.onPickProfilePhoto,
    required this.onPickVehiclePhoto,
    this.profilePhotoBytes,
    this.vehiclePhotoBytes,
    this.profilePhotoFile,
    this.vehiclePhotoFile,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildSectionTitle('Documentación Fotográfica', Icons.camera_alt_outlined),
          const SizedBox(height: 8),
          const Text(
            'Sube las fotos requeridas para completar tu registro:',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const SizedBox(height: 24),
          _buildPhotoSelector(
            label: 'Foto de Perfil',
            subtitle: 'Una foto clara de tu rostro',
            isPersonal: true,
            icon: Icons.person,
            hasPhoto: hasProfilePhoto,
            onPickPhoto: onPickProfilePhoto,
            photoBytes: profilePhotoBytes,
            photoFile: profilePhotoFile,
          ),
          const SizedBox(height: 24),
          _buildPhotoSelector(
            label: 'Foto del Vehículo',
            subtitle: 'Foto exterior completa del vehículo',
            isPersonal: false,
            icon: Icons.directions_car,
            hasPhoto: hasVehiclePhoto,
            onPickPhoto: onPickVehiclePhoto,
            photoBytes: vehiclePhotoBytes,
            photoFile: vehiclePhotoFile,
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

  Widget _buildPhotoSelector({
    required String label,
    required String subtitle,
    required bool isPersonal,
    required IconData icon,
    required bool hasPhoto,
    required VoidCallback onPickPhoto,
    Uint8List? photoBytes,
    File? photoFile,
  }) {
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
            onTap: onPickPhoto,
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
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(16),
                      ),
                      child: kIsWeb
                          ? Image.memory(
                              photoBytes!,
                              fit: BoxFit.cover,
                            )
                          : Image.file(
                              photoFile!,
                              fit: BoxFit.cover,
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
}