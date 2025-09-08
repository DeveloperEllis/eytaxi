import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/core/enum/Trip_status.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class AdminTripRequestService {
  final SupabaseClient client = Supabase.instance.client;

  /// Obtener TODAS las solicitudes de viaje (para admin) - SIN filtro de fecha
  Future<List<TripRequest>> getAllTripRequests() async {
    try {
      developer.log('🔍 AdminTripRequestService: Obteniendo todas las solicitudes (sin filtro de fecha)...', name: 'AdminTripRequestService');
      
      final data = await client
          .from('trip_requests')
          .select('''
            *,
            origen:origen_id(*),
            destino:destino_id(*),
            contact:contact_id(*)
          ''')
          .order('created_at', ascending: false);

      developer.log('📊 AdminTripRequestService: ${data.length} solicitudes obtenidas', name: 'AdminTripRequestService');
      
      return (data as List)
          .map((json) => TripRequest.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al obtener solicitudes: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      rethrow;
    }
  }

  /// Obtener solicitudes de viaje filtradas por fecha (desde hoy hacia adelante)
  Future<List<TripRequest>> getTripRequestsFromToday() async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      developer.log('🔍 AdminTripRequestService: Obteniendo solicitudes desde ${todayStart.toIso8601String()}...', name: 'AdminTripRequestService');
      
      final data = await client
          .from('trip_requests')
          .select('''
            *,
            origen:origen_id(*),
            destino:destino_id(*),
            contact:contact_id(*)
          ''')
          .gte('trip_date', todayStart.toIso8601String())
          .order('created_at', ascending: false);

      developer.log('📊 AdminTripRequestService: ${data.length} solicitudes desde hoy obtenidas', name: 'AdminTripRequestService');
      
      return (data as List)
          .map((json) => TripRequest.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al obtener solicitudes desde hoy: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      rethrow;
    }
  }

  /// Obtener solicitudes por estado
  Future<List<TripRequest>> getTripRequestsByStatus(String status) async {
    try {
      developer.log('🔍 AdminTripRequestService: Obteniendo solicitudes con estado: $status', name: 'AdminTripRequestService');
      
      final data = await client
          .from('trip_requests')
          .select('''
            *,
            origen:origen_id(*),
            destino:destino_id(*),
            contact:contact_id(*)
          ''')
          .eq('status', status)
          .order('created_at', ascending: false);

      developer.log('📊 AdminTripRequestService: ${data.length} solicitudes con estado $status obtenidas', name: 'AdminTripRequestService');
      
      return (data as List)
          .map((json) => TripRequest.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al obtener solicitudes por estado: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      rethrow;
    }
  }

  /// Obtener solicitudes por estado específico con filtro de fecha (desde hoy)
  Future<List<TripRequest>> getTripRequestsByStatusFromToday(String status) async {
    try {
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      developer.log('🔍 AdminTripRequestService: Obteniendo solicitudes con estado $status desde ${todayStart.toIso8601String()}...', name: 'AdminTripRequestService');
      
      final data = await client
          .from('trip_requests')
          .select('''
            *,
            origen:origen_id(*),
            destino:destino_id(*),
            contact:contact_id(*)
          ''')
          .eq('status', status)
          .gte('trip_date', todayStart.toIso8601String())
          .order('created_at', ascending: false);

      developer.log('📊 AdminTripRequestService: ${data.length} solicitudes con estado $status desde hoy obtenidas', name: 'AdminTripRequestService');
      
      return (data as List)
          .map((json) => TripRequest.fromJson(json))
          .toList();
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al obtener solicitudes por estado desde hoy: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      rethrow;
    }
  }

  /// Actualizar estado de una solicitud
  Future<void> updateTripRequestStatus(String id, String newStatus) async {
    try {
      developer.log('🔄 AdminTripRequestService: Actualizando solicitud $id a estado $newStatus', name: 'AdminTripRequestService');
      
      await client
          .from('trip_requests')
          .update({'status': newStatus})
          .eq('id', id);

      developer.log('✅ AdminTripRequestService: Estado actualizado exitosamente', name: 'AdminTripRequestService');
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al actualizar estado: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      rethrow;
    }
  }

  /// Obtener solicitudes pendientes (sin respuesta o solo rechazadas)
  Future<List<TripRequest>> getPendingRequests() async {
    try {
      developer.log('🔍 AdminTripRequestService: Obteniendo solicitudes pendientes (desde hoy)...', name: 'AdminTripRequestService');
      
      // Paso 1: Obtener solicitudes desde hoy
      final allRequests = await getTripRequestsFromToday();
      
      // Paso 2: Obtener todas las respuestas de conductores
      final responses = await client
          .from('driver_responses')
          .select('request_id, status');
      
      developer.log('📊 AdminTripRequestService: ${responses.length} respuestas de conductores obtenidas', name: 'AdminTripRequestService');
      
      // Paso 3: Filtrar solicitudes pendientes
      final pendingRequests = <TripRequest>[];
      
      for (final request in allRequests) {
        final requestId = request.id;
        if (requestId == null) continue;
        
        // IMPORTANTE: Solo considerar solicitudes con status 'pending'
        if (request.status != TripStatus.pending) {
          continue;
        }
        
        // Obtener respuestas para esta solicitud
        final requestResponses = responses
            .where((response) => response['request_id'] == requestId)
            .toList();
        
        // Si no tiene respuestas, es pendiente
        if (requestResponses.isEmpty) {
          pendingRequests.add(request);
          continue;
        }
        
        // Si solo tiene respuestas 'rejected', también es pendiente
        final hasAccepted = requestResponses
            .any((response) => response['status'] == 'accepted');
        
        if (!hasAccepted) {
          pendingRequests.add(request);
        }
      }

      developer.log('📊 AdminTripRequestService: ${pendingRequests.length} solicitudes pendientes identificadas', name: 'AdminTripRequestService');
      
      return pendingRequests;
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al obtener solicitudes pendientes: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      rethrow;
    }
  }

  /// Contar solicitudes por estado (desde hoy, excepto para "all")
  Future<Map<String, int>> getRequestCountsByStatus() async {
    try {
      developer.log('📊 AdminTripRequestService: Obteniendo contadores por estado (desde hoy)...', name: 'AdminTripRequestService');
      
      // Para los contadores usar solicitudes desde hoy
      final todayRequests = await getTripRequestsFromToday();
      final pendingRequests = await getPendingRequests(); // Ya filtradas desde hoy
      
      final counts = <String, int>{
        'pending': pendingRequests.length, // Usar contador real de pendientes
        'accepted': 0,
        'started': 0,
        'completed': 0,
        'cancelled': 0,
        'rejected': 0,
      };
      
      for (final request in todayRequests) {
        final status = request.status.name.toLowerCase();
        if (counts.containsKey(status) && status != 'pending') {
          counts[status] = counts[status]! + 1;
        }
      }
      
      developer.log('📊 AdminTripRequestService: Contadores obtenidos: $counts', name: 'AdminTripRequestService');
      return counts;
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al obtener contadores: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      return <String, int>{
        'pending': 0,
        'accepted': 0,
        'started': 0,
        'completed': 0,
        'cancelled': 0,
        'rejected': 0,
      };
    }
  }

  /// Contar solicitudes por tipo de taxi
  Future<Map<String, int>> getRequestCountsByTaxiType() async {
    try {
      developer.log('📊 AdminTripRequestService: Obteniendo contadores por tipo de taxi (desde hoy)...', name: 'AdminTripRequestService');
      
      // Usar solicitudes desde hoy para los contadores
      final todayRequests = await getTripRequestsFromToday();
      final counts = <String, int>{
        'colectivo': 0,
        'privado': 0,
      };
      
      for (final request in todayRequests) {
        final taxiType = request.taxiType.toLowerCase();
        if (counts.containsKey(taxiType)) {
          counts[taxiType] = counts[taxiType]! + 1;
        }
      }
      
      developer.log('📊 AdminTripRequestService: Contadores por tipo obtenidos: $counts', name: 'AdminTripRequestService');
      return counts;
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al obtener contadores por tipo: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      return <String, int>{
        'colectivo': 0,
        'privado': 0,
      };
    }
  }

  /// Eliminar una solicitud de viaje
  Future<void> deleteTripRequest(String id) async {
    try {
      developer.log('🗑️ AdminTripRequestService: Eliminando solicitud $id...', name: 'AdminTripRequestService');
      
      await client
          .from('trip_requests')
          .delete()
          .eq('id', id);
      
      developer.log('✅ AdminTripRequestService: Solicitud $id eliminada exitosamente', name: 'AdminTripRequestService');
    } catch (e, stackTrace) {
      developer.log('❌ AdminTripRequestService: Error al eliminar solicitud $id: $e', name: 'AdminTripRequestService');
      developer.log('📚 AdminTripRequestService: StackTrace: $stackTrace', name: 'AdminTripRequestService');
      rethrow;
    }
  }
}
