/// Evaluador del AST de una expresion booleana contra un entorno de
/// variables. Puerto directo de evaluar_nodo() en calib/logic_prototype.py.
library;

import 'expr_ast.dart';
import 'logic_exceptions.dart';

bool evaluarNodo(NodoExpr nodo, Map<String, bool> entorno) {
  if (nodo is NodoVar) {
    final valor = entorno[nodo.nombre];
    if (valor == null) {
      throw ErrorExpresion('Variable sin valor: ${nodo.nombre}');
    }
    return valor;
  }
  if (nodo is NodoNot) {
    return !evaluarNodo(nodo.operando, entorno);
  }
  if (nodo is NodoBin) {
    final a = evaluarNodo(nodo.izquierda, entorno);
    final b = evaluarNodo(nodo.derecha, entorno);
    switch (nodo.operador) {
      case OperadorBinario.and_:
        return a && b;
      case OperadorBinario.or_:
        return a || b;
      case OperadorBinario.xor_:
        return a != b;
    }
  }
  throw const ErrorExpresion('Nodo AST desconocido');
}
