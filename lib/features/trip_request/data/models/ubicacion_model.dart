class Ubicacion {
	final int id;
	final String nombre;
	final String codigo;
	final String region;
	final String tipo;
	final String provincia;

	Ubicacion({
		required this.id,
		required this.nombre,
		required this.codigo,
		required this.region,
		required this.tipo,
		required this.provincia,
	});

	factory Ubicacion.fromJson(Map<String, dynamic> json) {
		return Ubicacion(
			id: json['id'] as int,
			nombre: json['nombre'] as String,
			codigo: json['codigo'] as String,
			region: json['region'] as String,
			tipo: json['tipo'] as String,
			provincia: json['provincia'] as String,
		);
	}

	Map<String, dynamic> toJson() {
		return {
			'id': id,
			'nombre': nombre,
			'codigo': codigo,
			'region': region,
			'tipo': tipo,
			'provincia': provincia,
		};
	}

	@override
	String toString() {
		return '$nombre ($codigo)';
	}
}
