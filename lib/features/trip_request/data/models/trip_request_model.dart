import 'package:eytaxi/core/enum/Trip_status.dart';
import 'package:eytaxi/data/models/guest_contact_model.dart';
import 'package:eytaxi/data/models/driver_model.dart';
import 'package:eytaxi/features/trip_request/data/models/ubicacion_model.dart';

class TripRequest {
	final String? id;
	final String userId;
	final String? driverId;
	final int origenId;
	final int destinoId;
	final String taxiType;
	final int cantidadPersonas;
	final DateTime tripDate;
	final TripStatus status;
	final double? price;
	final double? distanceKm;
	final int? estimatedTimeMinutes;
	final DateTime createdAt;
	final Ubicacion? origen;
	final Ubicacion? destino;
	final GuestContact? contact;
	final int driverResponseCount;
	final Driver? driver; // Add driver property

	TripRequest({
		this.id,
		required this.userId,
		this.driverId,
		required this.origenId,
		required this.destinoId,
		required this.taxiType,
		required this.cantidadPersonas,
		required this.tripDate,
		required this.status,
		this.price,
		this.distanceKm,
		this.estimatedTimeMinutes,
		required this.createdAt,
		this.origen,
		this.destino,
		this.contact,
		this.driverResponseCount = 0,
		this.driver,
	});

		 factory TripRequest.fromJson(Map<String, dynamic> json) {
				 return TripRequest(
						 id: json['id'] as String?,
						 userId: json['user_id'] as String? ?? '',
						 driverId: json['driver_id'] as String?,
						 origenId: json['origen_id'] as int? ?? 0,
						 destinoId: json['destino_id'] as int? ?? 0,
						 taxiType: json['taxi_type'],
						 cantidadPersonas: json['cantidad_personas'] as int? ?? 1,
						 tripDate: json['trip_date'] != null ? DateTime.parse(json['trip_date'] as String) : DateTime.now(),
						 status: _parseStatus(json['status'] as String? ?? 'pending'),
						 price: json['price'] != null
										 ? (json['price'] is int ? (json['price'] as int).toDouble() : json['price'] as double)
										 : null,
						 distanceKm: json['distance_km'] != null
										 ? (json['distance_km'] is int ? (json['distance_km'] as int).toDouble() : json['distance_km'] as double)
										 : null,
						 estimatedTimeMinutes: json['estimated_time_minutes'] as int?,
						 createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : DateTime.now(),
						 origen: json['origen'] != null ? Ubicacion.fromJson(json['origen']) : null,
						 destino: json['destino'] != null ? Ubicacion.fromJson(json['destino']) : null,
						 contact: json['contact'] != null ? GuestContact.fromJson(json['contact']) : null,
						 driverResponseCount: json['driver_response_count'] as int? ?? 0,
						 driver: json['driver'] != null ? Driver.fromJson(json['driver']) : null, // Parse driver details
				 );
		 }


  Map<String, dynamic> toJson({required String contactId}) {
    return {
      'contact_id': contactId,
      'driver_id': driverId,
      'origen_id': origenId,
      'destino_id': destinoId,
      'taxi_type': taxiType,
      'cantidad_personas': cantidadPersonas,
      'trip_date': tripDate.toIso8601String(),
      'status': status.name,
      'price': price ?? 0.0,
      'distance_km': distanceKm ?? 0.0,
      'estimated_time_minutes': estimatedTimeMinutes ?? 0,
    };
  }

		 static TripStatus _parseStatus(String status) {
			 switch (status.toLowerCase()) {
				 case 'pending':
					 return TripStatus.pending;
				 case 'accepted':
					 return TripStatus.accepted;
				 case 'started':
					 return TripStatus.started;
				 case 'finished':
					 return TripStatus.finished;
				 case 'completed':
					 return TripStatus.completed;
				 case 'rejected':
					 return TripStatus.rejected;
				 case 'cancelled':
					 return TripStatus.cancelled;
				 default:
					 return TripStatus.pending;
			 }
		 }
		 // ...otros métodos y utilidades...

}
