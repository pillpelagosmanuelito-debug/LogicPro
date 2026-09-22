/// Analizador descendente recursivo de expresiones booleanas.
///
/// Puerto directo de ParserExpresion en calib/logic_prototype.py.
/// Gramatica: expr := or ; or := and ((OR|XOR) and)* ;
/// and := unario (AND unario)* ; unario := NOT unario | primario ;
/// primario := VAR | '(' expr ')'.
library;

import 'expr_ast.dart';
import 'expr_lexer.dart';
import 'logic_exceptions.dart';

class ParserExpresion {
  final List<TokenExpr> tokens;
  int pos = 0;

  ParserExpresion(this.tokens);

  TokenExpr actual() => tokens[pos];

  TokenExpr avanzar() {
    final t = tokens[pos];
    pos += 1;
    return t;
  }

  NodoExpr parsear() {
    final nodo = parsearOr();
    if (actual().tipo != TipoTokenExpr.fin) {
      throw ErrorExpresion('Token inesperado: ${actual().tipo}');
    }
    return nodo;
  }

  NodoExpr parsearOr() {
    var izq = parsearAnd();
    while (actual().tipo == TipoTokenExpr.or_ ||
        actual().tipo == TipoTokenExpr.xor_) {
      final op = avanzar().tipo;
      final der = parsearAnd();
      final operador =
          op == TipoTokenExpr.or_ ? OperadorBinario.or_ : OperadorBinario.xor_;
      izq = NodoBin(operador, izq, der);
    }
    return izq;
  }

  NodoExpr parsearAnd() {
    var izq = parsearUnario();
    while (actual().tipo == TipoTokenExpr.and_) {
      avanzar();
      final der = parsearUnario();
      izq = NodoBin(OperadorBinario.and_, izq, der);
    }
    return izq;
  }

  NodoExpr parsearUnario() {
    if (actual().tipo == TipoTokenExpr.not_) {
      avanzar();
      return NodoNot(parsearUnario());
    }
    return parsearPrimario();
  }

  NodoExpr parsearPrimario() {
    final t = actual();
    if (t.tipo == TipoTokenExpr.variable) {
      avanzar();
      return NodoVar(t.valor!);
    }
    if (t.tipo == TipoTokenExpr.parIzq) {
      avanzar();
      final nodo = parsearOr();
      if (actual().tipo != TipoTokenExpr.parDer) {
        throw const ErrorExpresion("Se esperaba ')'");
      }
      avanzar();
      return nodo;
    }
    throw ErrorExpresion('Token inesperado: ${t.tipo}');
  }
}

NodoExpr parsearExpresion(String fuente) {
  final tokens = tokenizarExpresion(fuente);
  return ParserExpresion(tokens).parsear();
}
