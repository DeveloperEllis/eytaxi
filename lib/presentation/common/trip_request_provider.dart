import 'package:eytaxi/core/services/trip_request__service.dart';
import 'package:eytaxi/models/trip_request_model.dart';
import 'package:eytaxi/models/ubicacion_model.dart';
import 'package:flutter/material.dart';

class TripRequestProvider extends ChangeNotifier {
  TripRequestService service = TripRequestService();
  TripRequest? _trip;

  TripRequest? get trip => _trip;

  void setTrip(TripRequest trip) {
    _trip = trip;
    notifyListeners();
  }

  void clear() {
    _trip = null;
    notifyListeners();
  }
  // Estado del formulario
  String taxiType = 'colectivo';
  Ubicacion? origen;
  Ubicacion? destino;
  int personas = 1;
  DateTime? fechaHora;

  double? precio;
  double? distanciaKm;
  double? tiempoMin;

  bool precioCalculado = false;
  bool loading = false;
  bool camposEditados = false;

  // Setters que actualizan estado y notifican UI

  void setTaxiType(String value) {
    taxiType = value;
    fechaHora = null;
    resetPrecio();
    notifyListeners();
  }

  void setOrigen(Ubicacion? value) {
    origen = value;
    resetPrecio();
    notifyListeners();
  }

  void setDestino(Ubicacion? value) {
    destino = value;
    resetPrecio();
    notifyListeners();
  }

  void setPersonas(int value) {
    personas = value;
    resetPrecio();
    notifyListeners();
  }

  void setFechaHora(DateTime value) {
    fechaHora = value;
    resetPrecio();
    notifyListeners();
  }

  void resetPrecio() {
    precio = null;
    distanciaKm = null;
    tiempoMin = null;
    precioCalculado = false;
    camposEditados = true;
  }

  void resetAll() {
    taxiType = 'colectivo';
    origen = null;
    destino = null;
    personas = 1;
    fechaHora = null;
    resetPrecio();
    loading = false;
    notifyListeners();
  }

  // Función para calcular precio llamando al servicio

  Future<bool> calcularPrecio() async {
    if (origen == null || destino == null) return false;

    loading = true;
    notifyListeners();

    final data = await service.calculateReservationDetails(
      origen!.id,
      destino!.id,
    );

    if (data != null) {
      double precioBase = (data['precio'] is int)
          ? (data['precio'] as int).toDouble()
          : double.tryParse(data['precio'].toString()) ?? 0.0;
      double distanciaKmTemp = (data['distancia_km'] is int)
          ? (data['distancia_km'] as int).toDouble()
          : double.tryParse(data['distancia_km'].toString()) ?? 0.0;
      double tiempoMinTemp = (data['tiempo_min'] is int)
          ? (data['tiempo_min'] as int).toDouble()
          : double.tryParse(data['tiempo_min'].toString()) ?? 0.0;

      double precioFinal = taxiType == 'colectivo'
          ? (precioBase / 4) * personas
          : personas <= 4
              ? precioBase
              : (precioBase / 4) * personas;

      precio = precioFinal;
      distanciaKm = distanciaKmTemp;
      tiempoMin = tiempoMinTemp;
      precioCalculado = true;
      camposEditados = false;
      loading = false;
      notifyListeners();
      return true;
    } else {
      loading = false;
      notifyListeners();
      return false;
    }
  }

  // Función para enviar la solicitud a supabase

  
}
