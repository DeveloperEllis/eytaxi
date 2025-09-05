import 'package:eytaxi/core/services/theme_notifier.dart';
import 'package:eytaxi/features/driver/data/datasources/driver_requests_remote_datasource.dart';
import 'package:eytaxi/features/driver/data/repositories/driver_requests_repository_impl.dart';
import 'package:eytaxi/features/driver/presentation/home/driver_dashboard_view_model.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'widgets/active_requests_card.dart';

class DriverDashboard extends StatefulWidget {
  const DriverDashboard({super.key});

  @override
  State<DriverDashboard> createState() => _DriverDashboardState();
}

class _DriverDashboardState extends State<DriverDashboard> {
  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  ThemeNotifier? _themeNotifier;
  DriverDashboardViewModel? _vm;

  @override
  void initState() {
    super.initState();
    _themeNotifier = Provider.of<ThemeNotifier>(context, listen: false);
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final repo = DriverRequestsRepositoryImpl(
        DriverRequestsRemoteDataSource(Supabase.instance.client),
      );
      _vm = DriverDashboardViewModel(repo: repo, driverId: user.id);
      _vm!.setOnline(_themeNotifier!.isOnline);
    }
    _themeNotifier!.addListener(_handleDriverStateChange);
  }

  void _handleDriverStateChange() {
    if (_vm == null) return;
    _vm!.setOnline(_themeNotifier!.isOnline);
  }

  @override
  void dispose() {
    _vm?.dispose();
    _themeNotifier?.removeListener(_handleDriverStateChange);
    super.dispose();
  }

  Future<void> _handleRequestAccepted(TripRequest request) async {
    final vm = _vm;
    if (vm == null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('No disponible en este momento'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final success = await vm.accept(request);
      if (success) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Solicitud aceptada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final already = await vm.hasResponded(request.id!);
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(already
                ? 'Ya has respondido a esta solicitud'
                : 'No se pudo completar la acción (posible sin conexión)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Error al aceptar la solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _handleRequestRejected(TripRequest request) async {
    final vm = _vm;
    if (vm == null) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('No disponible en este momento'), backgroundColor: Colors.red),
      );
      return;
    }
    try {
      final success = await vm.reject(request);
      if (success) {
        _scaffoldMessengerKey.currentState?.showSnackBar(
          const SnackBar(
            content: Text('Solicitud rechazada con éxito'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final already = await vm.hasResponded(request.id!);
        _scaffoldMessengerKey.currentState?.showSnackBar(
          SnackBar(
            content: Text(already
                ? 'Ya has respondido a esta solicitud'
                : 'No se pudo completar la acción (posible sin conexión)'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      _scaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(
          content: Text('Error al rechazar la solicitud'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = _vm;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || vm == null) {
      return const Center(
        child: Text(
          'No autenticado',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return ChangeNotifierProvider<DriverDashboardViewModel>.value(
      value: vm,
      child: Consumer<DriverDashboardViewModel>(
        builder: (context, model, _) {
          return Scaffold(
            key: _scaffoldMessengerKey,
            body: model.loading
                ? const Center(child: CircularProgressIndicator())
                : model.requests.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay solicitudes pendientes',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView(
                        padding: const EdgeInsets.only(left: 8, right: 8, top: 5, bottom: 8),
                        children: [
                          _buildRequestsSection(model.requests),
                        ],
                      ),
          );
        },
      ),
    );
  }

  Widget _buildRequestsSection(List<TripRequest> requests) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ActiveRequestsCard(
          requests: requests,
          onRequestAccepted: _handleRequestAccepted,
          onRequestRejected: _handleRequestRejected,
        ),
      ],
    );
  }
}
