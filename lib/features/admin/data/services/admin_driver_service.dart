import 'dart:developer' as dev;
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDriverService {
  final SupabaseClient _client;

  AdminDriverService(this._client);

  // Obtener todos los conductores disponibles con información de perfil
  Future<List<Driver>> getAvailableDrivers() async {
    try {
      dev.log('📊 AdminDriverService: Obteniendo conductores disponibles...');
      
      final response = await _client
          .from('drivers')
          .select('''
            id,
            license_number,
            vehicle_capacity,
            routes,
            is_available,
            rating,
            total_trips,
            driver_status,
            viajes_locales,
            user_profiles!inner (
              id,
              nombre,
              apellidos,
              phone_number,
              email,
              photo_url
            )
          ''')
          .eq('driver_status', 'approved')
          .eq('is_available', true);

      dev.log('✅ AdminDriverService: ${response.length} conductores obtenidos');
      
      // Convertir la respuesta al formato Driver esperado
      return (response as List).map((json) {
        final userProfile = json['user_profiles'];
        final driverData = {
          'id': json['id'],
          'nombre': userProfile['nombre'],
          'apellidos': userProfile['apellidos'],
          'phoneNumber': userProfile['phone_number'],
          'email': userProfile['email'],
          'licenseNumber': json['license_number'],
          'vehicleCapacity': json['vehicle_capacity'],
          'routes': json['routes'],
          'isAvailable': json['is_available'],
          'rating': json['rating'],
          'totalTrips': json['total_trips'],
          'viajesLocales': json['viajes_locales'],
        };
        return Driver.fromJson(driverData);
      }).toList();
    } catch (e) {
      dev.log('❌ AdminDriverService: Error al obtener conductores: $e');
      throw Exception('Error al obtener conductores: $e');
    }
  }

  // Obtener conductores que han respondido a una solicitud específica
  Future<List<Map<String, dynamic>>> getDriverResponsesForRequest(String requestId) async {
    try {
      dev.log('📊 AdminDriverService: Obteniendo respuestas para solicitud $requestId...');
      
      // Primero obtenemos las respuestas con la información del user_profile
      final response = await _client
          .from('driver_responses')
          .select('''
            id,
            status,
            created_at,
            driver_id,
            user_profiles!inner (
              id,
              nombre,
              apellidos,
              phone_number,
              email,
              photo_url
            )
          ''')
          .eq('request_id', requestId)
          .order('created_at', ascending: false);

      dev.log('🔍 AdminDriverService: ${response.length} respuestas básicas obtenidas');
      
      // Ahora obtenemos la información adicional del conductor para cada respuesta
      List<Map<String, dynamic>> enrichedResponses = [];
      
      for (final item in response) {
        final driverId = item['driver_id'] as String;
        
        // Obtener información adicional del conductor
        final driverInfo = await _client
            .from('drivers')
            .select('''
              id,
              license_number,
              vehicle_capacity,
              routes,
              rating,
              total_trips,
              viajes_locales
            ''')
            .eq('id', driverId)
            .maybeSingle();
        
        final userProfile = item['user_profiles'];
        
        enrichedResponses.add({
          'id': item['id'],
          'status': item['status'],
          'response': item['status'], // Para compatibilidad
          'created_at': item['created_at'],
          'driver_id': item['driver_id'],
          'driver': {
            'id': driverId,
            'nombre': userProfile['nombre'],
            'apellidos': userProfile['apellidos'],
            'phoneNumber': userProfile['phone_number'],
            'phone_number': userProfile['phone_number'],
            'email': userProfile['email'],
            'licenseNumber': driverInfo?['license_number'] ?? 'N/A',
            'license_number': driverInfo?['license_number'] ?? 'N/A',
            'vehicleCapacity': driverInfo?['vehicle_capacity'] ?? 0,
            'vehicle_capacity': driverInfo?['vehicle_capacity'] ?? 0,
            'routes': driverInfo?['routes'] ?? [],
            'rating': driverInfo?['rating'] ?? 0.0,
            'total_trips': driverInfo?['total_trips'] ?? 0,
            'viajes_locales': driverInfo?['viajes_locales'] ?? false,
          }
        });
      }

      dev.log('✅ AdminDriverService: ${enrichedResponses.length} respuestas enriquecidas obtenidas');
      return enrichedResponses;
      
    } catch (e) {
      dev.log('❌ AdminDriverService: Error al obtener respuestas: $e');
      throw Exception('Error al obtener respuestas de conductores: $e');
    }
  }

  // Buscar conductores por nombre, apellido o número de licencia
  Future<List<Driver>> searchDrivers(String query) async {
    try {
      dev.log('🔍 AdminDriverService: Buscando conductores con query: $query');
      
      final response = await _client
          .from('drivers')
          .select('''
            id,
            license_number,
            vehicle_capacity,
            routes,
            is_available,
            rating,
            total_trips,
            driver_status,
            viajes_locales,
            user_profiles!inner (
              id,
              nombre,
              apellidos,
              phone_number,
              email,
              photo_url
            )
          ''')
          .eq('driver_status', 'approved')
          .or('license_number.ilike.%$query%,user_profiles.nombre.ilike.%$query%,user_profiles.apellidos.ilike.%$query%');

      dev.log('✅ AdminDriverService: ${response.length} conductores encontrados');
      
      // Convertir la respuesta al formato Driver esperado
      return (response as List).map((json) {
        final userProfile = json['user_profiles'];
        final driverData = {
          'id': json['id'],
          'nombre': userProfile['nombre'],
          'apellidos': userProfile['apellidos'],
          'phoneNumber': userProfile['phone_number'],
          'email': userProfile['email'],
          'licenseNumber': json['license_number'],
          'vehicleCapacity': json['vehicle_capacity'],
          'routes': json['routes'],
          'isAvailable': json['is_available'],
          'rating': json['rating'],
          'totalTrips': json['total_trips'],
          'viajesLocales': json['viajes_locales'],
        };
        return Driver.fromJson(driverData);
      }).toList();
    } catch (e) {
      dev.log('❌ AdminDriverService: Error en búsqueda: $e');
      throw Exception('Error al buscar conductores: $e');
    }
  }

  // Asignar conductor a una solicitud (desde admin)
  Future<bool> assignDriverToRequest({
    required String requestId,
    required String driverId,
    required String adminId,
  }) async {
    try {
      dev.log('📝 AdminDriverService: Asignando conductor $driverId a solicitud $requestId...');
      
      // Primero verificar si ya existe una respuesta de este conductor
      final existingResponse = await _client
          .from('driver_responses')
          .select('id')
          .eq('request_id', requestId)
          .eq('driver_id', driverId)
          .maybeSingle();

      if (existingResponse != null) {
        // Actualizar respuesta existente
        await _client
            .from('driver_responses')
            .update({
              'status': 'accepted',
            })
            .eq('request_id', requestId)
            .eq('driver_id', driverId);
      } else {
        // Crear nueva respuesta
        await _client
            .from('driver_responses')
            .insert({
              'request_id': requestId,
              'driver_id': driverId,
              'status': 'accepted',
            });
      }

      // Actualizar la solicitud para marcarla como aceptada
      await _client
          .from('trip_requests')
          .update({
            'status': 'accepted',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', requestId);

      dev.log('✅ AdminDriverService: Conductor asignado exitosamente');
      return true;
    } catch (e) {
      dev.log('❌ AdminDriverService: Error al asignar conductor: $e');
      throw Exception('Error al asignar conductor: $e');
    }
  }

  // Obtener detalles de un conductor específico
  Future<Driver?> getDriverById(String driverId) async {
    try {
      dev.log('📊 AdminDriverService: Obteniendo detalles del conductor $driverId...');
      
      final response = await _client
          .from('drivers')
          .select('''
            id,
            license_number,
            vehicle_capacity,
            routes,
            is_available,
            rating,
            total_trips,
            driver_status,
            viajes_locales,
            created_at,
            user_profiles!inner (
              id,
              nombre,
              apellidos,
              phone_number,
              email,
              photo_url,
              created_at
            )
          ''')
          .eq('id', driverId)
          .maybeSingle();

      if (response != null) {
        dev.log('✅ AdminDriverService: Detalles del conductor obtenidos');
        final userProfile = response['user_profiles'];
        final driverData = {
          'id': response['id'],
          'nombre': userProfile['nombre'],
          'apellidos': userProfile['apellidos'],
          'phoneNumber': userProfile['phone_number'],
          'email': userProfile['email'],
          'licenseNumber': response['license_number'],
          'vehicleCapacity': response['vehicle_capacity'],
          'routes': response['routes'],
          'isAvailable': response['is_available'],
          'rating': response['rating'],
          'totalTrips': response['total_trips'],
          'viajesLocales': response['viajes_locales'],
        };
        return Driver.fromJson(driverData);
      } else {
        dev.log('⚠️ AdminDriverService: Conductor no encontrado');
        return null;
      }
    } catch (e) {
      dev.log('❌ AdminDriverService: Error al obtener detalles: $e');
      return null;
    }
  }

  // Obtener estadísticas de respuestas del conductor
  Future<Map<String, int>> getDriverResponseStats(String driverId) async {
    try {
      dev.log('📊 AdminDriverService: Obteniendo estadísticas del conductor $driverId...');
      
      final response = await _client
          .from('driver_responses')
          .select('status')
          .eq('driver_id', driverId);

      int accepted = 0;
      int rejected = 0;
      int pending = 0;

      for (final row in response) {
        switch (row['status'] as String) {
          case 'accepted':
            accepted++;
            break;
          case 'rejected':
            rejected++;
            break;
          default:
            pending++;
            break;
        }
      }

      final stats = {
        'accepted': accepted,
        'rejected': rejected,
        'pending': pending,
        'total': response.length,
      };

      dev.log('✅ AdminDriverService: Estadísticas obtenidas: $stats');
      return stats;
    } catch (e) {
      dev.log('❌ AdminDriverService: Error al obtener estadísticas: $e');
      return {'accepted': 0, 'rejected': 0, 'pending': 0, 'total': 0};
    }
  }

  // Obtener estadísticas generales de conductores
  Future<Map<String, int>> getDriverStats() async {
    try {
      dev.log('📊 AdminDriverService: Obteniendo estadísticas generales...');
      
      final allDrivers = await _client
          .from('drivers')
          .select('driver_status, is_available');

      final stats = <String, int>{
        'total': allDrivers.length,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'available': 0,
      };

      for (final driver in allDrivers) {
        final status = driver['driver_status'] as String?;
        final isAvailable = driver['is_available'] as bool?;
        
        if (status != null) {
          stats[status] = (stats[status] ?? 0) + 1;
        }
        
        if (isAvailable == true) {
          stats['available'] = (stats['available'] ?? 0) + 1;
        }
      }

      dev.log('✅ AdminDriverService: Estadísticas generales obtenidas: $stats');
      return stats;
    } catch (e) {
      dev.log('❌ AdminDriverService: Error al obtener estadísticas generales: $e');
      return {
        'total': 0,
        'approved': 0,
        'pending': 0,
        'rejected': 0,
        'available': 0,
      };
    }
  }
}
