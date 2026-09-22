/// Generador de tablas de verdad a partir de una expresion booleana.
/// Puerto directo de generar_tabla_verdad() en calib/logic_prototype.py.
library;

import 'expr_ast.dart';
import 'expr_evaluator.dart';
import 'expr_parser.dart';

/// Una fila de la tabla: el entorno usado (valores de cada variable) y el
/// resultado booleano de la expresion para ese entorno.
class FilaTablaVerdad {
  final Map<String, bool> entorno;
  final bool resultado;
  const FilaTablaVerdad(this.entorno, this.resultado);
}

class TablaVerdad {
  final List<String> variables;
  final List<FilaTablaVerdad> filas;
  const TablaVerdad(this.variables, this.filas);
}

/// Determina si dos expresiones booleanas son logicamente equivalentes,
/// evaluando ambas sobre TODAS las combinaciones de la union de sus
/// variables (no solo las de una de ellas), para que la comparacion sea
/// valida incluso cuando una expresion tiene menos variables que la otra.
bool sonEquivalentes(String expresion1, String expresion2) {
  final nodo1 = parsearExpresion(expresion1);
  final nodo2 = parsearExpresion(expresion2);
  final variables = variablesDe(nodo1).union(variablesDe(nodo2)).toList()
    ..sort();
  final n = variables.length;
  final totalCombinaciones = 1 << n;
  for (var combinacion = 0; combinacion < totalCombinaciones; combinacion++) {
    final entorno = <String, bool>{};
    for (var idx = 0; idx < n; idx++) {
      final bit = (combinacion >> (n - idx - 1)) & 1;
      entorno[variables[idx]] = bit == 1;
    }
    if (evaluarNodo(nodo1, entorno) != evaluarNodo(nodo2, entorno)) {
      return false;
    }
  }
  return true;
}

TablaVerdad generarTablaVerdad(String fuente) {
  final nodo = parsearExpresion(fuente);
  final variables = variablesDe(nodo).toList()..sort();
  final filas = <FilaTablaVerdad>[];
  final n = variables.length;
  final totalCombinaciones = 1 << n;
  for (var combinacion = 0; combinacion < totalCombinaciones; combinacion++) {
    final entorno = <String, bool>{};
    for (var idx = 0; idx < n; idx++) {
      final bit = (combinacion >> (n - idx - 1)) & 1;
      entorno[variables[idx]] = bit == 1;
    }
    final resultado = evaluarNodo(nodo, entorno);
    filas.add(FilaTablaVerdad(Map<String, bool>.from(entorno), resultado));
  }
  return TablaVerdad(variables, filas);
}
