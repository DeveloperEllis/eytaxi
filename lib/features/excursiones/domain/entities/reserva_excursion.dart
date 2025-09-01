class ReservaExcursion {
  final String? id;
  final String? excursionId;
  final double precio;
  final String cantidadPersonas;
  final DateTime fecha;
  final bool incluirGuia;

  ReservaExcursion({
    this.id,
    this.excursionId,
    required this.precio,
    required this.cantidadPersonas,
    required this.fecha,
    required this.incluirGuia,
  });
}
