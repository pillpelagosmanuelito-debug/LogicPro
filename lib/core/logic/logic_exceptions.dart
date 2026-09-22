/// Excepciones del motor de lógica digital (lib/core/logic/).
///
/// Puerto directo de las excepciones definidas en el prototipo Python
/// (calib/logic_prototype.py): ErrorExpresion y ErrorCircuito.
library;

/// Error al tokenizar, parsear o evaluar una expresion booleana.
class ErrorExpresion implements Exception {
  final String mensaje;
  const ErrorExpresion(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Error al evaluar un circuito de compuertas (ciclo, entrada faltante,
/// número de entradas invalido para el tipo de compuerta, etc.).
class ErrorCircuito implements Exception {
  final String mensaje;
  const ErrorCircuito(this.mensaje);

  @override
  String toString() => mensaje;
}
