// Puerto de test_tabla_verdad_and / test_tabla_verdad_xor.
import 'package:flutter_test/flutter_test.dart';
import 'package:logicpro/core/logic/truth_table.dart';

void main() {
  group('Tablas de verdad', () {
    test('A & B produce 4 filas con el patron 0,0,0,1', () {
      final tabla = generarTablaVerdad('A & B');
      expect(tabla.variables, ['A', 'B']);
      expect(tabla.filas.length, 4);
      expect(tabla.filas.map((f) => f.resultado).toList(),
          [false, false, false, true]);
    });

    test('A ^ B produce el patron 0,1,1,0', () {
      final tabla = generarTablaVerdad('A ^ B');
      expect(tabla.filas.map((f) => f.resultado).toList(),
          [false, true, true, false]);
    });
  });

  group('Equivalencia de expresiones (sonEquivalentes)', () {
    test('absorcion: A + (A & B) equivale a A', () {
      expect(sonEquivalentes('A + (A & B)', 'A'), isTrue);
      expect(sonEquivalentes('A + (A & B)', 'B'), isFalse);
    });

    test('De Morgan: !(A & B) equivale a !A | !B', () {
      expect(sonEquivalentes('!(A & B)', '!A | !B'), isTrue);
    });

    test('complemento+identidad: A & (B | !B) equivale a A', () {
      expect(sonEquivalentes('A & (B | !B)', 'A'), isTrue);
      expect(sonEquivalentes('A & (B | !B)', 'B'), isFalse);
    });

    test('distributiva inversa', () {
      expect(sonEquivalentes('(A & B) | (A & C)', 'A & (B | C)'), isTrue);
    });
  });
}
