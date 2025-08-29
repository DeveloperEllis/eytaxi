import 'package:eytaxi/models/ubicacion_model.dart';
import 'package:eytaxi/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationsService {
  Future<List<Ubicacion>> fetchUbicaciones(String query) async {
    try {
      if (query.length < 2) {
        print('Input too short: $query');
        return [];
      }

      final sanitizedQuery = query.trim().toLowerCase();

      final response = await Supabase.instance.client
          .from('ubicaciones_cuba')
          .select('id, nombre, codigo, tipo, provincia, region')
          .or(
            'nombre.ilike.%$sanitizedQuery%,provincia.ilike.%$sanitizedQuery%',
          );

      print('Supabase response for query "$sanitizedQuery": $response');

      if (response.isEmpty) {
        print('No results found for query: $sanitizedQuery');
      }

      return response
          .map((json) {
            try {
              return Ubicacion.fromJson(json);
            } catch (e) {
              print('Error parsing JSON: $json, error: $e');
              return null;
            }
          })
          .where((ubicacion) => ubicacion != null)
          .cast<Ubicacion>()
          .toList();
    } catch (e) {
      print('Error fetching ubicaciones: $e');
      return [];
    }
  }
}
