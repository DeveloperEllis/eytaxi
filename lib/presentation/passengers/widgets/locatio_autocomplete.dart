import 'package:eytaxi/core/services/locations_service.dart';
import 'package:eytaxi/core/services/supabase_service.dart';
import 'package:eytaxi/core/styles/button_style.dart';
import 'package:eytaxi/core/styles/input_decorations.dart';
import 'package:eytaxi/core/styles/locations_autocomplete_style.dart';
import 'package:eytaxi/models/ubicacion_model.dart';
import 'package:flutter/material.dart';

class LocationAutocomplete extends StatefulWidget {
  final TextEditingController controller;
  final String labelText;
  final Ubicacion? selectedLocation;
  final ValueChanged<Ubicacion?> onSelected;
  final SupabaseService supabaseService;

  const LocationAutocomplete({
    super.key,
    required this.controller,
    required this.labelText,
    required this.selectedLocation,
    required this.onSelected,
    required this.supabaseService,
  });

  @override
  _LocationAutocompleteState createState() => _LocationAutocompleteState();
}

class _LocationAutocompleteState extends State<LocationAutocomplete> {
  bool _isLoading = false;
  LocationsService service = LocationsService();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {}); // Reconstruir para actualizar el suffixIcon
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Autocomplete<Ubicacion>(
      optionsBuilder: (TextEditingValue textEditingValue) async {
        if (textEditingValue.text.length < 2) {
          print('Input too short: ${textEditingValue.text}');
          return [];
        }
        setState(() {
          _isLoading = true;
        });
        try {
          final results = await service.fetchUbicaciones(textEditingValue.text);
          return results;
        } catch (e) {
          return [];
        } finally {
          setState(() {
            _isLoading = false;
          });
        }
      },
      displayStringForOption:
          (Ubicacion option) => '${option.nombre} (${option.codigo ?? 'N/A'})',
      onSelected: (Ubicacion selection) {
        widget.controller.text =
            '${selection.nombre} (${selection.codigo ?? 'N/A'})';
        widget.onSelected(selection);
        print('Selected location: ${selection.nombre}');
      },
      fieldViewBuilder: (
        BuildContext context,
        TextEditingController textEditingController,
        FocusNode focusNode,
        VoidCallback onFieldSubmitted,
      ) {
        if (widget.controller.text.isNotEmpty &&
            textEditingController.text.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            textEditingController.text = widget.controller.text;
          });
        }
        textEditingController.addListener(() {
          if (widget.controller.text != textEditingController.text) {
            widget.controller.text = textEditingController.text;
          }
        });
        return TextFormField(
          controller: textEditingController,
          focusNode: focusNode,
          decoration: AppInputDecoration.buildInputDecoration(
            context: context,
            labelText: widget.labelText,
            prefixIcon: Icons.location_on,
            suffixIcon:
                _isLoading
                    ? const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : textEditingController.text.isNotEmpty
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        textEditingController.clear();
                        widget.controller.clear();
                        widget.onSelected(null);
                        setState(() {});
                        print('Cleared text field');
                      },
                    )
                    : null,
          ),
          onChanged: (value) {
            if (widget.selectedLocation != null &&
                value !=
                    '${widget.selectedLocation!.nombre} (${widget.selectedLocation!.codigo ?? 'N/A'})') {
              widget.onSelected(null);
              print('Cleared selected location via onChanged');
            }
          },
          validator:
              (value) =>
                  value == null || value.isEmpty
                      ? 'Ingrese ${widget.labelText}'
                      : null,
          onFieldSubmitted: (String value) {
            onFieldSubmitted();
          },
        );
      },
      optionsViewBuilder: (
        BuildContext context,
        AutocompleteOnSelected<Ubicacion> onSelected,
        Iterable<Ubicacion> options,
      ) {
        return Align(
          alignment: Alignment.topLeft,
          child: Material(
            elevation: LocationAutocompleteStyles.elevation,
            shape: const RoundedRectangleBorder(
              borderRadius: LocationAutocompleteStyles.optionsBorderRadius,
            ),
            child: Container(
              width:
                  MediaQuery.of(context).size.width *
                  LocationAutocompleteStyles.optionsContainerWidthFactor,
              decoration: LocationAutocompleteStyles.optionsContainerDecoration(
                context,
              ),
              child: ListView.builder(
                padding: LocationAutocompleteStyles.optionsPadding,
                shrinkWrap: true,
                itemCount: options.length,
                itemBuilder: (BuildContext context, int index) {
                  final Ubicacion option = options.elementAt(index);
                  return ListTile(
                    leading: Icon(
                      LocationAutocompleteStyles.getIconForUbicacion(option),
                      color: LocationAutocompleteStyles.optionIconColor(
                        context,
                      ),
                    ),
                    title: Text(
                      option.nombre,
                      style: LocationAutocompleteStyles.optionTitleStyle(
                        context,
                      ),
                    ),
                    subtitle: Text(
                      '${option.tipo ?? 'N/A'} · ${option.provincia ?? 'N/A'}',
                      style: LocationAutocompleteStyles.optionSubtitleStyle(
                        context,
                      ),
                    ),
                    onTap: () => onSelected(option),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
