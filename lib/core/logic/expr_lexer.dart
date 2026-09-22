/// Tokenizador de expresiones booleanas.
///
/// Puerto directo de tokenizar_expresion() en calib/logic_prototype.py.
library;

import 'logic_exceptions.dart';

enum TipoTokenExpr { variable, not_, and_, or_, xor_, parIzq, parDer, fin }

class TokenExpr {
  final TipoTokenExpr tipo;
  final String? valor;
  const TokenExpr(this.tipo, this.valor);
}

List<TokenExpr> tokenizarExpresion(String fuente) {
  final tokens = <TokenExpr>[];
  var i = 0;
  final n = fuente.length;
  while (i < n) {
    final c = fuente[i];
    if (c.trim().isEmpty) {
      i += 1;
      continue;
    }
    final esLetra = RegExp(r'^[A-Za-z]$').hasMatch(c);
    if (esLetra) {
      tokens.add(TokenExpr(TipoTokenExpr.variable, c.toUpperCase()));
      i += 1;
      continue;
    }
    if (c == '!' || c == '~') {
      tokens.add(TokenExpr(TipoTokenExpr.not_, c));
      i += 1;
      continue;
    }
    if (c == '&' || c == '.') {
      tokens.add(TokenExpr(TipoTokenExpr.and_, c));
      i += 1;
      continue;
    }
    if (c == '|' || c == '+') {
      tokens.add(TokenExpr(TipoTokenExpr.or_, c));
      i += 1;
      continue;
    }
    if (c == '^') {
      tokens.add(TokenExpr(TipoTokenExpr.xor_, c));
      i += 1;
      continue;
    }
    if (c == '(') {
      tokens.add(TokenExpr(TipoTokenExpr.parIzq, c));
      i += 1;
      continue;
    }
    if (c == ')') {
      tokens.add(TokenExpr(TipoTokenExpr.parDer, c));
      i += 1;
      continue;
    }
    throw ErrorExpresion("Carácter no reconocido: '$c'");
  }
  tokens.add(const TokenExpr(TipoTokenExpr.fin, null));
  return tokens;
}
