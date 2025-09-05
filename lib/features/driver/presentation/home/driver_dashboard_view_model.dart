import 'dart:async';
import 'package:eytaxi/features/driver/domain/repositories/driver_requests_repository.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:flutter/foundation.dart';

class DriverDashboardViewModel extends ChangeNotifier {
  final DriverRequestsRepository repo;
  final String driverId;

  DriverDashboardViewModel({required this.repo, required this.driverId});

  final List<TripRequest> _requests = [];
  List<TripRequest> get requests => List.unmodifiable(_requests);

  bool _loading = false;
  bool get loading => _loading;

  String? _error;
  String? get error => _error;

  StreamSubscription<List<TripRequest>>? _sub;
  bool _online = true;
  Timer? _pollTimer;
  bool _isDisposed = false;

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  Future<void> initialize({bool withStream = true}) async {
    await refresh();
    if (withStream) _subscribe();
  }

  Future<void> refresh() async {
    _loading = true;
    _error = null;
    _safeNotify();
    try {
      final data = await repo.fetchPendingRequests(driverId);
      _requests
        ..clear()
        ..addAll(data);
    } catch (e) {
      _error = 'Error al cargar las solicitudes pendientes';
    } finally {
      _loading = false;
      _safeNotify();
    }
  }

  void _subscribe() {
    _sub?.cancel();
    _sub = repo.watchPendingRequests(driverId).listen(
      (data) {
    if (_isDisposed) return;
        _requests
          ..clear()
          ..addAll(data);
    _safeNotify();
        // Received data from stream, cancel any polling fallback
        _pollTimer?.cancel();
        _pollTimer = null;
      },
      onError: (e, st) {
    if (_isDisposed) return;
        if (_online) {
          Future.delayed(const Duration(seconds: 3), () {
      if (_online && !_isDisposed) _subscribe();
          });
          _ensurePolling();
        }
      },
      onDone: () {
    if (_isDisposed) return;
        if (_online) {
          Future.delayed(const Duration(seconds: 3), () {
      if (_online && !_isDisposed) _subscribe();
          });
          _ensurePolling();
        }
      },
      cancelOnError: false,
    );
  }

  void _ensurePolling() {
    if (_pollTimer != null) return;
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (_online) {
        refresh();
      } else {
        _pollTimer?.cancel();
        _pollTimer = null;
      }
    });
  }

  Future<bool> accept(TripRequest request) async {
    final has = await repo.hasDriverResponded(request.id!, driverId);
    if (has) return false;
    final ok = await repo.acceptTripRequest(request.id!, driverId);
    if (ok) {
      _requests.removeWhere((r) => r.id == request.id);
  _safeNotify();
      // Ensure server state is reflected even if stream is flaky
  unawaited(_silentRefresh());
    }
    return ok;
  }

  Future<bool> reject(TripRequest request) async {
    final has = await repo.hasDriverResponded(request.id!, driverId);
    if (has) return false;
    final ok = await repo.rejectTripRequest(request.id!, driverId);
    if (ok) {
      _requests.removeWhere((r) => r.id == request.id);
  _safeNotify();
  unawaited(_silentRefresh());
    }
    return ok;
  }

  Future<bool> hasResponded(String requestId) {
    return repo.hasDriverResponded(requestId, driverId);
  }

  @override
  void dispose() {
    _sub?.cancel();
  _pollTimer?.cancel();
    _isDisposed = true;
    super.dispose();
  }

  Future<void> setOnline(bool online) async {
    _online = online;
    if (online) {
      await initialize(withStream: true);
    } else {
      _sub?.cancel();
  _pollTimer?.cancel();
  _pollTimer = null;
      _requests.clear();
      _safeNotify();
    }
  }

  // Refresh without toggling the global loading state to avoid UI "reload" feel
  Future<void> _silentRefresh() async {
    try {
      final data = await repo.fetchPendingRequests(driverId);
      _requests
        ..clear()
        ..addAll(data);
  _safeNotify();
    } catch (_) {
      // ignore
    }
  }
}
