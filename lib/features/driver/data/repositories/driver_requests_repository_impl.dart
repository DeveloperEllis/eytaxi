import 'package:eytaxi/features/driver/data/datasources/driver_requests_remote_datasource.dart';
import 'package:eytaxi/features/driver/domain/repositories/driver_requests_repository.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';

class DriverRequestsRepositoryImpl implements DriverRequestsRepository {
  final DriverRequestsRemoteDataSource remote;
  DriverRequestsRepositoryImpl(this.remote);

  @override
  Future<List<TripRequest>> fetchPendingRequests(String driverId) {
    return remote.fetchPendingRequests(driverId);
  }

  @override
  Stream<List<TripRequest>> watchPendingRequests(String driverId) {
    return remote.watchPendingRequests(driverId);
  }

  @override
  Future<bool> acceptTripRequest(String requestId, String driverId) {
    return remote.acceptTripRequest(requestId, driverId);
  }

  @override
  Future<bool> hasDriverResponded(String requestId, String driverId) {
    return remote.hasDriverResponded(requestId, driverId);
  }

  @override
  Future<bool> rejectTripRequest(String requestId, String driverId) {
    return remote.rejectTripRequest(requestId, driverId);
  }
}
