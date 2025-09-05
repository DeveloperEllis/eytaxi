import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';

abstract class DriverRequestsRepository {
  Future<List<TripRequest>> fetchPendingRequests(String driverId);
  Stream<List<TripRequest>> watchPendingRequests(String driverId);
  Future<bool> hasDriverResponded(String requestId, String driverId);
  Future<bool> acceptTripRequest(String requestId, String driverId);
  Future<bool> rejectTripRequest(String requestId, String driverId);
}
