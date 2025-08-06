import 'package:eytaxi/presentation/passengers/excursion/widgets/contact_widget.dart';
import 'package:eytaxi/presentation/passengers/excursion/widgets/excursion_card.dart';
import 'package:eytaxi/presentation/passengers/excursion/widgets/location_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


class ExcursionTab extends StatefulWidget {
  const ExcursionTab({super.key});

  @override
  State<ExcursionTab> createState() => _ExcursionTabState();
}

class _ExcursionTabState extends State<ExcursionTab> {
  final _formKey = GlobalKey<FormState>();
  String? _ubicacion = 'Trinidad';
  List<Map<String, dynamic>> _excursiones = [];
  List<String> _ubicacionesDisponibles = [];
  bool _loading = false;
  bool _loadingUbicaciones = true;

  @override
  void initState() {
    super.initState();
    _fetchUbicaciones();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildLocationDropdown(),
            const SizedBox(height: 10),
            _buildAvailableExcursionsTitle(),
            const SizedBox(height: 8),
            _buildExcursionsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationDropdown() {
    return _loadingUbicaciones
        ? const Center(child: CircularProgressIndicator())
        : LocationDropdown(
            value: _ubicacion,
            items: _ubicacionesDisponibles,
            onChanged: (value) {
              setState(() => _ubicacion = value);
              if (value != null && value.isNotEmpty) {
                _buscarExcursiones();
              }
            },
          );
  }

  Widget _buildAvailableExcursionsTitle() {
    if (_ubicacion == null || _ubicacion!.isEmpty) return const SizedBox.shrink();
    
    return const Padding(
      padding: EdgeInsets.only(bottom: 0),
      child: Align(
        alignment: Alignment.centerLeft,
      ),
    );
  }

  Widget _buildExcursionsList() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_excursiones.isEmpty) {
      return const Center(
        child: Text('No hay excursiones disponibles en esta área.'),
      );
    }

    return Expanded(
      child: ListView.builder(
        itemCount: _excursiones.length,
        itemBuilder: (context, index) {
          final excursion = _excursiones[index];
          return ExcursionCard(
            excursion: excursion,
            onReservePressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return ReservationFormDialog(excursion: excursion ); // Retorna tu widget de diálogo
                },
              );
            },
          );
        },
      ),
    );
  }

  

  Future<void> _fetchUbicaciones() async {
    try {
      setState(() => _loadingUbicaciones = true);
      
      final response = await Supabase.instance.client
          .from('excursiones')
          .select('ubicacion');
      
      final ubicaciones = (response as List)
          .map((e) => e['ubicacion'] as String)
          .toSet()
          .toList();

      setState(() {
        _ubicacionesDisponibles = ubicaciones;
        if (_ubicacionesDisponibles.isNotEmpty) {
          if (_ubicacion == null || !_ubicacionesDisponibles.contains(_ubicacion)) {
            _ubicacion = _ubicacionesDisponibles.first;
          }
        } else {
          _ubicacion = null;
        }
        _loadingUbicaciones = false;
      });

      if (_ubicacion != null) {
        _buscarExcursiones();
      }
    } catch (e) {
      setState(() {
        _loadingUbicaciones = false;
        _ubicacionesDisponibles = [];
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar ubicaciones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _buscarExcursiones() async {
    if (_ubicacion == null || _ubicacion!.isEmpty) return;
    
    setState(() {
      _loading = true;
      _excursiones = [];
    });

    try {
      final response = await Supabase.instance.client
          .from('excursiones')
          .select()
          .eq('ubicacion', _ubicacion!.trim());
      
      setState(() {
        _excursiones = List<Map<String, dynamic>>.from(response);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _excursiones = [];
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al cargar excursiones: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
