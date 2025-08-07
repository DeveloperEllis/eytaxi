import 'package:eytaxi/core/enum/Trip_status.dart';
import 'package:eytaxi/models/guest_contact_model.dart';
import 'package:eytaxi/models/ubicacion_model.dart';

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
       origen: json['origen'] != null ? Ubicacion.fromJson(json['origen'] as Map<String, dynamic>) : null,
      destino: json['destino'] != null ? Ubicacion.fromJson(json['destino'] as Map<String, dynamic>) : null,
      contact: json['contact'] != null ? GuestContact.fromJson(json['contact'] as Map<String, dynamic>) : null,
      driverResponseCount: (json['driver_response_count'] as List<dynamic>?)?.isNotEmpty == true
          ? (json['driver_response_count'][0]['count'] as int? ?? 0)
          : 0,
    );
  }

  Map<String, dynamic> toJson({bool includeId = false}) {
    final data = {
      'user_id': userId,
      'driver_id': driverId,
      'origen_id': origenId,
      'destino_id': destinoId,
      'taxi_type': taxiType,
      'cantidad_personas': cantidadPersonas,
      'trip_date': tripDate.toIso8601String(),
      'status': status.toString().split('.').last,
      'price': price,
      'distance_km': distanceKm,
      'estimated_time_minutes': estimatedTimeMinutes,
      'created_at': createdAt.toIso8601String(),
    };
    if (includeId && id != null) {
      data['id'] = id;
    }
    return data;
  }

  static TripStatus _parseStatus(String status) {
    switch (status.toLowerCase()) {
      case 'accepted':
        return TripStatus.accepted;
      case 'rejected':
        return TripStatus.rejected;
      case 'completed':
        return TripStatus.completed;
      case 'cancelled':
        return TripStatus.cancelled;
      default:
        return TripStatus.pending;
    }
  }
}