/// Nodos del arbol de sintaxis de una expresion booleana.
///
/// Puerto directo de las tuplas de Python ('VAR', ...), ('NOT', ...),
/// ('BIN', op, izq, der) del prototipo, como clases selladas equivalentes.
library;

sealed class NodoExpr {
  const NodoExpr();
}

class NodoVar extends NodoExpr {
  final String nombre;
  const NodoVar(this.nombre);
}

class NodoNot extends NodoExpr {
  final NodoExpr operando;
  const NodoNot(this.operando);
}

enum OperadorBinario { and_, or_, xor_ }

class NodoBin extends NodoExpr {
  final OperadorBinario operador;
  final NodoExpr izquierda;
  final NodoExpr derecha;
  const NodoBin(this.operador, this.izquierda, this.derecha);
}

/// Recorre el AST y devuelve el conjunto de nombres de variable usados,
/// en el mismo orden de descubrimiento que el prototipo Python
/// (variables_de).
Set<String> variablesDe(NodoExpr nodo) {
  if (nodo is NodoVar) return {nodo.nombre};
  if (nodo is NodoNot) return variablesDe(nodo.operando);
  if (nodo is NodoBin) {
    return variablesDe(nodo.izquierda).union(variablesDe(nodo.derecha));
  }
  throw StateError('Nodo AST desconocido');
}
