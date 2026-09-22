/// Evaluador de circuitos combinacionales: un grafo de compuertas resuelto
/// por orden topológico, con detección de ciclos.
///
/// Puerto directo de NodoCompuerta / TIPOS_COMPUERTA / evaluar_circuito()
/// en calib/logic_prototype.py.
library;

import 'logic_exceptions.dart';

/// Tipo de compuerta lógica soportado por el simulador de circuitos.
enum TipoCompuerta { and_, or_, not_, nand_, nor_, xor_, xnor_ }

/// Nombre corto para mostrar en la UI (AND, OR, NOT, NAND, NOR, XOR, XNOR).
String nombreCompuerta(TipoCompuerta tipo) {
  switch (tipo) {
    case TipoCompuerta.and_:
      return 'AND';
    case TipoCompuerta.or_:
      return 'OR';
    case TipoCompuerta.not_:
      return 'NOT';
    case TipoCompuerta.nand_:
      return 'NAND';
    case TipoCompuerta.nor_:
      return 'NOR';
    case TipoCompuerta.xor_:
      return 'XOR';
    case TipoCompuerta.xnor_:
      return 'XNOR';
  }
}

bool _aplicarCompuerta(TipoCompuerta tipo, List<bool> entradas) {
  switch (tipo) {
    case TipoCompuerta.and_:
      return entradas.every((x) => x);
    case TipoCompuerta.or_:
      return entradas.any((x) => x);
    case TipoCompuerta.not_:
      return !entradas[0];
    case TipoCompuerta.nand_:
      return !entradas.every((x) => x);
    case TipoCompuerta.nor_:
      return !entradas.any((x) => x);
    case TipoCompuerta.xor_:
      return entradas.where((x) => x).length.isOdd;
    case TipoCompuerta.xnor_:
      return entradas.where((x) => x).length.isEven;
  }
}

/// Prefijo usado en los ids de entrada de una compuerta para senalar que
/// referencian una entrada externa del circuito en vez de otra compuerta,
/// p.ej. 'ENT:A'.
const String prefijoEntradaExterna = 'ENT:';

class NodoCompuerta {
  final String id;
  final TipoCompuerta tipo;
  final List<String> entradas; // ids: 'ENT:A' o el id de otra compuerta

  const NodoCompuerta({
    required this.id,
    required this.tipo,
    required this.entradas,
  });
}

/// Evalua un circuito (lista de compuertas) contra un mapa de entradas
/// externas y devuelve el valor resuelto de cada compuerta por su id.
Map<String, bool> evaluarCircuito(
  List<NodoCompuerta> compuertas,
  Map<String, bool> entradasExternas,
) {
  final porId = <String, NodoCompuerta>{
    for (final c in compuertas) c.id: c,
  };
  final resueltos = <String, bool>{};

  bool resolver(String idNodo, Set<String> pila) {
    if (idNodo.startsWith(prefijoEntradaExterna)) {
      final nombre = idNodo.substring(prefijoEntradaExterna.length);
      final valor = entradasExternas[nombre];
      if (valor == null) {
        throw ErrorCircuito('Entrada externa sin valor: $nombre');
      }
      return valor;
    }
    final yaResuelto = resueltos[idNodo];
    if (yaResuelto != null) return yaResuelto;
    if (pila.contains(idNodo)) {
      throw ErrorCircuito("Ciclo detectado en el circuito en '$idNodo'");
    }
    final nodo = porId[idNodo];
    if (nodo == null) {
      throw ErrorCircuito('Compuerta no encontrada: $idNodo');
    }
    final nuevaPila = {...pila, idNodo};
    final valoresEntrada =
        nodo.entradas.map((e) => resolver(e, nuevaPila)).toList();
    if (nodo.tipo == TipoCompuerta.not_ && valoresEntrada.length != 1) {
      throw const ErrorCircuito('NOT requiere exactamente 1 entrada');
    }
    if (nodo.tipo != TipoCompuerta.not_ && valoresEntrada.length < 2) {
      throw ErrorCircuito(
          '${nombreCompuerta(nodo.tipo)} requiere al menos 2 entradas');
    }
    final resultado = _aplicarCompuerta(nodo.tipo, valoresEntrada);
    resueltos[idNodo] = resultado;
    return resultado;
  }

  for (final c in compuertas) {
    resolver(c.id, <String>{});
  }
  return resueltos;
}
