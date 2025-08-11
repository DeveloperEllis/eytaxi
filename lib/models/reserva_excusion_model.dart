class ReservaExc {
  final String? id; // Optional ID for database or API reference
  final String? exc_id; // Optional ID for database or API reference
  final double precio; // From ReservaExc['precio']
  final String cantidad_personas;// From contactoController (includes country code for WhatsApp)
  final DateTime fecha; // From selectedfecha
  final bool incluir_guia; // From incluir_guia checkbox

  ReservaExc({
    this.id,
    this.exc_id,
    required this.precio,
    required this.cantidad_personas,
    required this.fecha,
    required this.incluir_guia,
  });

  // Convert ReservaExc to JSON for API or storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'exc_id': exc_id,
      'precio': precio,
      'nombre': cantidad_personas,
      'fecha': fecha.toIso8601String(),
      'guia': incluir_guia,
    };
  }

  // Create ReservaExc from JSON
  factory ReservaExc.fromJson(Map<String, dynamic> json) {
    return ReservaExc(
      id: json['id'] as String?,
      exc_id: json['exc_id'] as String?,
      precio: (json['precio'] as num).toDouble(),
      cantidad_personas: json['nombre'] as String,
      fecha: DateTime.parse(json['fecha'] as String),
      incluir_guia: json['guia'] as bool,
    );
  }
}
