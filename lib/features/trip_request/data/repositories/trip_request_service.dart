
import 'package:eytaxi/data/models/guest_contact_model.dart';
import 'package:eytaxi/features/trip_request/data/datasources/trip_request_remote_datasource.dart';
import 'package:eytaxi/features/trip_request/data/models/trip_request_model.dart';
import 'package:eytaxi/features/trip_request/data/repositories/proxy_service.dart';

class TripRequestService {
	final TripRequestRemoteDataSource remoteDataSource;

	TripRequestService(this.remoteDataSource);

	/// Crear una nueva solicitud de viaje
		Future<void> createTripRequest(TripRequest request, GuestContact contact) async {
				final tripRequest = await remoteDataSource.createTripRequest(request, contact);
				ProxyService.crearTrip(tripRequest.id ?? '');
		}

		Future<Map<String, dynamic>?> calculateReservationDetails(int idOrigen, int idDestino) async {
			return await remoteDataSource.calculateReservationDetails(idOrigen, idDestino);
		}

	/// Obtener todas las solicitudes de un usuario
		Future<List<TripRequest>> getRequestsByUser(String userId) async {
			return await remoteDataSource.getRequestsByUser(userId);
		}

	/// Obtener una solicitud por ID
		Future<TripRequest?> getRequestById(String id) async {
			return await remoteDataSource.getRequestById(id);
		}

	/// Actualizar estado de la solicitud
		Future<void> updateStatus(String id, String newStatus) async {
			await remoteDataSource.updateStatus(id, newStatus);
		}

	/// Eliminar solicitud
		Future<void> deleteRequest(String id) async {
			await remoteDataSource.deleteRequest(id);
		}


}
