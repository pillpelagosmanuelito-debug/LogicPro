// Puerto de las pruebas de expresiones de calib/logic_prototype.py
// (test_expresion_básica, test_expresion_precedencia,
// test_expresion_paréntesis, test_de_morgan).
import 'package:flutter_test/flutter_test.dart';
import 'package:logicpro/core/logic/expr_evaluator.dart';
import 'package:logicpro/core/logic/expr_parser.dart';

void main() {
  group('Expresiones booleanas', () {
    test('A & B evalua correctamente', () {
      final nodo = parsearExpresion('A & B');
      expect(evaluarNodo(nodo, {'A': true, 'B': true}), isTrue);
      expect(evaluarNodo(nodo, {'A': true, 'B': false}), isFalse);
    });

    test('precedencia: NOT > AND > OR/XOR', () {
      final nodo = parsearExpresion('!A & B | C');
      expect(evaluarNodo(nodo, {'A': false, 'B': false, 'C': false}), isFalse);
      expect(evaluarNodo(nodo, {'A': false, 'B': true, 'C': false}), isTrue);
      expect(evaluarNodo(nodo, {'A': true, 'B': true, 'C': true}), isTrue);
    });

    test('paréntesis fuerzan orden de evaluación', () {
      final nodo = parsearExpresion('(A | B) & !C');
      expect(evaluarNodo(nodo, {'A': true, 'B': false, 'C': false}), isTrue);
      expect(evaluarNodo(nodo, {'A': true, 'B': false, 'C': true}), isFalse);
    });

    test('leyes de De Morgan se cumplen para todas las combinaciones', () {
      final izq = parsearExpresion('!(A & B)');
      final der = parsearExpresion('!A | !B');
      for (final a in [true, false]) {
        for (final b in [true, false]) {
          final entorno = {'A': a, 'B': b};
          expect(evaluarNodo(izq, entorno), evaluarNodo(der, entorno));
        }
      }
      final izq2 = parsearExpresion('!(A | B)');
      final der2 = parsearExpresion('!A & !B');
      for (final a in [true, false]) {
        for (final b in [true, false]) {
          final entorno = {'A': a, 'B': b};
          expect(evaluarNodo(izq2, entorno), evaluarNodo(der2, entorno));
        }
      }
    });
  });
}
