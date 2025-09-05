import 'package:eytaxi/core/constants/app_colors.dart';
import 'package:eytaxi/features/auth/utils/register_validators.dart';
import 'package:flutter/material.dart';

class ProfileInfo extends StatelessWidget {
  final bool isEditing;
  final TextEditingController nombreController;
  final TextEditingController apellidosController;
  final TextEditingController phoneController;
  final String? profilePhotoUrl;
  final VoidCallback onEditProfilePhoto;

  const ProfileInfo({
    super.key,
    required this.isEditing,
    required this.nombreController,
    required this.apellidosController,
    required this.phoneController,
    this.profilePhotoUrl,
    required this.onEditProfilePhoto,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Foto de perfil
            Stack(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.primary, width: 4),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child: profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                        ? Image.network(
                            profilePhotoUrl!,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey.shade300,
                                child: Icon(
                                  Icons.person,
                                  size: 60,
                                  color: Colors.grey.shade600,
                                ),
                              );
                            },
                          )
                        : Container(
                            color: Colors.grey.shade300,
                            child: Icon(
                              Icons.person,
                              size: 60,
                              color: Colors.grey.shade600,
                            ),
                          ),
                  ),
                ),
                if (isEditing)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: FloatingActionButton.small(
                      heroTag: "edit_profile",
                      onPressed: onEditProfilePhoto,
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.camera_alt, color: Colors.white),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),

            // Nombre y apellidos
            if (isEditing) ...[
              _buildEditableField(
                label: 'Nombre',
                controller: nombreController,
                icon: Icons.person,
                validator: (value) => RegisterValidators.validateNonEmpty(value, 'nombre'),
              ),
              const SizedBox(height: 16),
              _buildEditableField(
                label: 'Apellidos',
                controller: apellidosController,
                icon: Icons.person_outline,
                validator: (value) => RegisterValidators.validateNonEmpty(value, 'apellidos'),
              ),
              const SizedBox(height: 16),
            ] else ...[
              Text(
                '${nombreController.text} ${apellidosController.text}'
                        .trim()
                        .isNotEmpty
                    ? '${nombreController.text} ${apellidosController.text}'
                    : 'Nombre no disponible',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
            ],

            // Teléfono
            if (isEditing) ...[
              _buildEditableField(
                label: 'Teléfono',
                controller: phoneController,
                icon: Icons.phone,
                keyboardType: TextInputType.phone,
                validator: RegisterValidators.validatePhone,
              ),
              const SizedBox(height: 16),
            ] else if (phoneController.text.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone, size: 16, color: Colors.grey.shade600),
                  const SizedBox(width: 4),
                  Text(
                    phoneController.text,
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
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
}
