// Puerto de test_flipflop_d / test_flipflop_jk_toggle /
// test_flipflop_jk_set_reset / test_flipflop_t / test_contador_binario.
import 'package:flutter_test/flutter_test.dart';
import 'package:logicpro/core/logic/flip_flop.dart';

void main() {
  group('Flip-flops y contador', () {
    test('flip-flop D sigue la entrada en cada flanco', () {
      final linea = simularSecuenciaD([true, false, true, true]);
      expect(linea, [true, false, true, true]);
    });

    test('flip-flop JK con J=K=1 conmuta cada flanco', () {
      final linea = simularSecuenciaJk(List.filled(4, const ParJk(true, true)));
      expect(linea, [true, false, true, false]);
    });

    test('flip-flop JK set/hold/reset', () {
      final linea = simularSecuenciaJk([
        const ParJk(true, false),
        const ParJk(false, false),
        const ParJk(false, true),
      ]);
      expect(linea, [true, true, false]);
    });

    test('flip-flop T conmuta solo cuando T=1', () {
      final linea = simularSecuenciaT([true, true, false, true]);
      expect(linea, [true, false, false, true]);
    });

    test('contador binario de 2 bits sigue la secuencia esperada', () {
      final linea = contadorBinario2Bit(6);
      final valores = linea.map((e) => (e.q1, e.q0)).toList();
      expect(valores, [
        (false, true),
        (true, false),
        (true, true),
        (false, false),
        (false, true),
        (true, false),
      ]);
    });
  });
}
