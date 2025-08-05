class Ubicacion {
  final int id;
  final String nombre;
  final String codigo;
  final String region;
  final String tipo; // Add the 'tipo' field
  final String provincia; // Add the 'tipo' field

  Ubicacion({
    required this.id,
    required this.nombre,
    required this.codigo,
    required this.region,
    required this.tipo,
    required this.provincia,
  }); // Update constructor



  // Factory constructor to create Ubicacion from Supabase row Map
  factory Ubicacion.fromJson(Map<String, dynamic> json) {
    return Ubicacion(
      id: json['id'] as int,
      nombre: json['nombre'] as String,
      codigo: json['codigo'] as String,
      region: json['region'] as String,
      tipo: json['tipo'] as String, // Parse the 'tipo' field
      provincia: json['provincia'] as String, // Parse the 'tipo' field
    );
  }
  // Method to convert Ubicacion to a Map for Supabase insert/update
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'codigo': codigo,
      'region': region,
      'tipo': tipo, // Include the 'tipo' field
      'provincia': provincia, // Include the 'tipo' field
    };
  }

  // Override toString for potential display in Autocomplete suggestions
  @override
  String toString() {
    return '$nombre ($codigo)';
  }
}