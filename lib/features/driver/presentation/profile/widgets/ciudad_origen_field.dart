import 'package:flutter/material.dart';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/data/models/user_model.dart';
import 'package:eytaxi/features/trip_request/presentation/pages/widgets/location_autocomplete.dart';

class CiudadOrigenField extends StatelessWidget {
  final TextEditingController ciudadOrigenController;
  final Ubicacion? selectedCiudadOrigen;
  final Function(Ubicacion?) onSelected;

  const CiudadOrigenField({
    super.key,
    required this.ciudadOrigenController,
    required this.selectedCiudadOrigen,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return LocationAutocomplete(
      controller: ciudadOrigenController,
      labelText: 'Selecciona tu ciudad de residencia',
      selectedLocation: selectedCiudadOrigen,
      onSelected: onSelected,
      user: UserType.driver,
    );
  }
}
