import 'package:supabase_flutter/supabase_flutter.dart';

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
      // Ejecutar todas las consultas en paralelo para mejor rendimiento
      final results = await Future.wait([
        _getExcursionReservations(),
        _getTotalRequests(),
        _getPendingRequests(),
        _getTotalDrivers(),
        _getPendingDrivers(),
        _getAcceptedRequests(),
      ]);

      return DashboardStats(
        excursionReservations: results[0],
        totalRequests: results[1],
        pendingRequests: results[2],
        totalDrivers: results[3],
        pendingDrivers: results[4],
        acceptedRequests: results[5],
      );
    } catch (e) {
      print('Error fetching dashboard stats: $e');
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
    final response = await _client
        .from('trip_requests')
        .select()
        .eq('status', 'pending');
    return (response as List).length;
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
