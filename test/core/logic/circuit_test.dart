// Puerto de test_circuito_medio_sumador / test_circuito_sumador_completo /
// test_circuito_ciclo_detectado.
import 'package:flutter_test/flutter_test.dart';
import 'package:logicpro/core/logic/circuit.dart';
import 'package:logicpro/core/logic/logic_exceptions.dart';

void main() {
  group('Circuitos combinacionales', () {
    test('medio sumador: SUMA = A xor B, ACARREO = A and B', () {
      final compuertas = [
        const NodoCompuerta(
            id: 'SUMA', tipo: TipoCompuerta.xor_, entradas: ['ENT:A', 'ENT:B']),
        const NodoCompuerta(
            id: 'ACARREO', tipo: TipoCompuerta.and_, entradas: ['ENT:A', 'ENT:B']),
      ];
      final r = evaluarCircuito(compuertas, {'A': true, 'B': true});
      expect(r['SUMA'], isFalse);
      expect(r['ACARREO'], isTrue);
      final r2 = evaluarCircuito(compuertas, {'A': true, 'B': false});
      expect(r2['SUMA'], isTrue);
      expect(r2['ACARREO'], isFalse);
    });

    test('sumador completo armado con dos medios sumadores + OR', () {
      final compuertas = [
        const NodoCompuerta(
            id: 'XOR1', tipo: TipoCompuerta.xor_, entradas: ['ENT:A', 'ENT:B']),
        const NodoCompuerta(
            id: 'AND1', tipo: TipoCompuerta.and_, entradas: ['ENT:A', 'ENT:B']),
        const NodoCompuerta(
            id: 'SUMA', tipo: TipoCompuerta.xor_, entradas: ['XOR1', 'ENT:CIN']),
        const NodoCompuerta(
            id: 'AND2', tipo: TipoCompuerta.and_, entradas: ['XOR1', 'ENT:CIN']),
        const NodoCompuerta(
            id: 'COUT', tipo: TipoCompuerta.or_, entradas: ['AND1', 'AND2']),
      ];
      final casos = [
        [false, false, false, false, false],
        [true, true, true, true, true],
        [true, false, true, false, true],
      ];
      for (final caso in casos) {
        final r = evaluarCircuito(compuertas,
            {'A': caso[0], 'B': caso[1], 'CIN': caso[2]});
        expect(r['SUMA'], caso[3]);
        expect(r['COUT'], caso[4]);
      }
    });

    test('un ciclo en el grafo lanza ErrorCircuito', () {
      final compuertas = [
        const NodoCompuerta(
            id: 'X', tipo: TipoCompuerta.and_, entradas: ['Y', 'ENT:A']),
        const NodoCompuerta(
            id: 'Y', tipo: TipoCompuerta.or_, entradas: ['X', 'ENT:B']),
      ];
      expect(
        () => evaluarCircuito(compuertas, {'A': true, 'B': true}),
        throwsA(isA<ErrorCircuito>()),
      );
    });
  });
}
