import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;

class DashboardStats {
  final int excursionReservations;
  final int totalRequests;
  final int pendingRequests;
  final int totalDrivers;
  final int pendingDrivers;
  final int acceptedRequests;

  const DashboardStats({
    required this.excursionReservations,
    required this.totalRequests,
    required this.pendingRequests,
    required this.totalDrivers,
    required this.pendingDrivers,
    required this.acceptedRequests,
  });

  factory DashboardStats.empty() {
    return const DashboardStats(
      excursionReservations: 0,
      totalRequests: 0,
      pendingRequests: 0,
      totalDrivers: 0,
      pendingDrivers: 0,
      acceptedRequests: 0,
    );
  }
}

class AdminDashboardService {
  final SupabaseClient _client = Supabase.instance.client;

  Future<DashboardStats> fetchDashboardStats() async {
    try {
      developer.log('🔄 AdminDashboardService: Obteniendo estadísticas del dashboard...', name: 'AdminDashboardService');
      
      // Ejecutar todas las consultas en paralelo para mejor rendimiento
      final results = await Future.wait([
        _getExcursionReservations(),
        _getTotalRequests(),
        _getPendingRequests(),
        _getTotalDrivers(),
        _getPendingDrivers(),
        _getAcceptedRequests(),
      ]);

      final stats = DashboardStats(
        excursionReservations: results[0],
        totalRequests: results[1],
        pendingRequests: results[2],
        totalDrivers: results[3],
        pendingDrivers: results[4],
        acceptedRequests: results[5],
      );
      
      developer.log('✅ AdminDashboardService: Estadísticas obtenidas - Pendientes: ${stats.pendingRequests}, Total: ${stats.totalRequests}', name: 'AdminDashboardService');
      
      return stats;
    } catch (e) {
      developer.log('❌ AdminDashboardService: Error al obtener estadísticas: $e', name: 'AdminDashboardService');
      return DashboardStats.empty();
    }
  }

  Future<int> _getExcursionReservations() async {
    final response = await _client
        .from('reservas_excursiones')
        .select();
    return (response as List).length;
  }

  Future<int> _getTotalRequests() async {
    final response = await _client
        .from('trip_requests')
        .select();
    return (response as List).length;
  }

  Future<int> _getPendingRequests() async {
    // Usar la misma lógica que AdminTripRequestService para consistencia
    try {
      developer.log('🔍 AdminDashboardService: Obteniendo solicitudes pendientes (desde hoy con lógica de respuestas)...', name: 'AdminDashboardService');
      
      // Paso 1: Obtener solicitudes desde hoy con status 'pending'
      final today = DateTime.now();
      final todayStart = DateTime(today.year, today.month, today.day);
      
      final allRequests = await _client
          .from('trip_requests')
          .select('id, status, trip_date')
          .eq('status', 'pending')
          .gte('trip_date', todayStart.toIso8601String());
      
      developer.log('📊 AdminDashboardService: ${allRequests.length} solicitudes pendientes desde hoy encontradas', name: 'AdminDashboardService');
      
      // Paso 2: Obtener todas las respuestas de conductores
      final responses = await _client
          .from('driver_responses')
          .select('request_id, status');
      
      developer.log('📊 AdminDashboardService: ${responses.length} respuestas de conductores obtenidas', name: 'AdminDashboardService');
      
      // Paso 3: Filtrar solicitudes realmente pendientes
      int pendingCount = 0;
      
      for (final request in allRequests) {
        final requestId = request['id'] as String?;
        if (requestId == null) continue;
        
        // Obtener respuestas para esta solicitud
        final requestResponses = responses
            .where((response) => response['request_id'] == requestId)
            .toList();
        
        // Si no tiene respuestas, es pendiente
        if (requestResponses.isEmpty) {
          pendingCount++;
          continue;
        }
        
        // Si solo tiene respuestas 'rejected', también es pendiente
        final hasAccepted = requestResponses
            .any((response) => response['status'] == 'accepted');
        
        if (!hasAccepted) {
          pendingCount++;
        }
      }
      
      developer.log('✅ AdminDashboardService: $pendingCount solicitudes realmente pendientes identificadas', name: 'AdminDashboardService');
      
      return pendingCount;
    } catch (e) {
      developer.log('❌ AdminDashboardService: Error al obtener solicitudes pendientes: $e', name: 'AdminDashboardService');
      // Fallback a consulta simple si falla
      final response = await _client
          .from('trip_requests')
          .select()
          .eq('status', 'pending');
      return (response as List).length;
    }
  }

  Future<int> _getTotalDrivers() async {
    final response = await _client
        .from('drivers')
        .select();
    return (response as List).length;
  }

  Future<int> _getPendingDrivers() async {
    final response = await _client
        .from('drivers')
        .select()
        .eq('driver_status', 'pending');
    return (response as List).length;
  }

  Future<int> _getAcceptedRequests() async {
    final response = await _client
        .from('driver_responses')
        .select('request_id')
        .not('request_id', 'is', null);
    return (response as List).length;
  }

  // Método para refrescar estadísticas en tiempo real
  Stream<DashboardStats> get statsStream {
    return Stream.periodic(const Duration(seconds: 30))
        .asyncMap((_) => fetchDashboardStats());
  }
}
