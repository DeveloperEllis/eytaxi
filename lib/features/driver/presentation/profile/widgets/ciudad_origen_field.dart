import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/data/models/user_model.dart';
import 'package:eytaxi/features/trip_request/presentation/pages/widgets/location_autocomplete.dart';
import 'package:flutter/material.dart';

class CiudadOrigenField extends StatelessWidget {
  final TextEditingController controller;
  final Ubicacion? selectedLocation;
  final ValueChanged<Ubicacion?> onSelected;

  const CiudadOrigenField({
    super.key,
    required this.controller,
    required this.selectedLocation,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LocationAutocomplete(
      controller: controller,
      labelText: 'Selecciona tu ciudad de residencia',
      selectedLocation: selectedLocation,
      onSelected: onSelected,
      user: UserType.driver,
    );
  }
}
