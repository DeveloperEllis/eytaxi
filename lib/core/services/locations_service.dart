import 'dart:developer';
import 'package:eytaxi/data/models/ubicacion_model.dart';
import 'package:eytaxi/data/models/user_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LocationsService {
  Future<List<Ubicacion>> fetchUbicaciones(String query) async {
    try {
      if (query.length < 2) {
        log('Input too short: $query');
        return [];
      }

      final sanitizedQuery = _sanitizeQuery(query);

      // 🔹 Usamos un RPC para poder aplicar unaccent directamente en SQL
      final response = await Supabase.instance.client.rpc(
        'search_ubicaciones',
        params: {'search_text': sanitizedQuery},
      );

      log('Supabase response for query "$sanitizedQuery": $response');

      if (response == null || (response is List && response.isEmpty)) {
        log('No results found for query: $sanitizedQuery');
        return [];
      }

      if (response is! List) {
        log('Unexpected response format: $response');
        throw Exception('Invalid response format');
      }

      return response
          .map((json) {
            try {
              return Ubicacion.fromJson(json);
            } catch (e) {
              log('Error parsing JSON: $json, error: $e');
              return null;
            }
          })
          .where((ubicacion) => ubicacion != null)
          .cast<Ubicacion>()
          .toList();
    } catch (e, stackTrace) {
      log('Error fetching ubicaciones: $e', stackTrace: stackTrace);
      throw Exception('Failed to fetch locations');
    }
  }

  String _sanitizeQuery(String query) {
    // quitamos tildes en DB, no aquí
    return query.trim().toLowerCase();
  }
}
