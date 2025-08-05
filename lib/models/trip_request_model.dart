class TripRequest {
  final String? id;
  final String? contactId;
  final String? driverId;
  final int? origenId;
  final int? destinoId;
  final String taxiType; // 'colectivo' o 'privado'
  final int cantidadPersonas;
  final DateTime tripDate;
  final String status; // 'pending', 'confirmed', etc.
  final double? price;
  final double? distanceKm;
  final int? estimatedTimeMinutes;
  final DateTime createdAt;

  TripRequest({
    this.id,
    this.contactId,
    this.driverId,
    this.origenId,
    this.destinoId,
    required this.taxiType,
    required this.cantidadPersonas,
    required this.tripDate,
    required this.status,
    this.price,
    this.distanceKm,
    this.estimatedTimeMinutes,
    required this.createdAt,
  });

  factory TripRequest.fromJson(Map<String, dynamic> json) {
    return TripRequest(
      id: json['id'],
      contactId: json['contact_id'],
      driverId: json['driver_id'],
      origenId: json['origen_id'],
      destinoId: json['destino_id'],
      taxiType: json['taxi_type'],
      cantidadPersonas: json['cantidad_personas'],
      tripDate: DateTime.parse(json['trip_date']),
      status: json['status'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : null,
      distanceKm:
          json['distance_km'] != null
              ? double.parse(json['distance_km'].toString())
              : null,
      estimatedTimeMinutes: json['estimated_time_minutes'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'contact_id': contactId,
      'driver_id': driverId,
      'origen_id': origenId,
      'destino_id': destinoId,
      'taxi_type': taxiType,
      'cantidad_personas': cantidadPersonas,
      'trip_date': tripDate.toIso8601String(),
      'status': status,
      'price': price,
      'distance_km': distanceKm,
      'estimated_time_minutes': estimatedTimeMinutes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
