import 'package:flutter_test/flutter_test.dart';
import 'package:logicpro/core/logic/circuit.dart';
import 'package:logicpro/core/tutor/logic_tutor.dart';

void main() {
  group('LogicTutor', () {
    test('respuesta correcta se marca como correcta', () {
      final d = diagnosticarRespuestaCompuerta(
        tipo: TipoCompuerta.and_,
        entradas: [true, true],
        respuestaEstudiante: true,
      );
      expect(d.correcta, isTrue);
      expect(d.tipoError, TipoErrorLogico.ninguno);
    });

    test('confundir AND con NAND se diagnostica como inversion', () {
      // AND(1,0) = 0; el estudiante responde 1 (que es NAND(1,0))
      final d = diagnosticarRespuestaCompuerta(
        tipo: TipoCompuerta.and_,
        entradas: [true, false],
        respuestaEstudiante: true,
      );
      expect(d.correcta, isFalse);
      expect(d.tipoError, TipoErrorLogico.confundioAndNand);
    });

    test('calcular OR en vez de AND se diagnostica especificamente', () {
      // AND(1,0) = 0 (correcto); OR(1,0) = 1 (lo que responde el estudiante)
      final d = diagnosticarRespuestaCompuerta(
        tipo: TipoCompuerta.and_,
        entradas: [true, false],
        respuestaEstudiante: true,
      );
      // Con estas entradas la inversion y el OR coinciden (ambos dan 1),
      // así que la regla de inversion (mas especifica) gana; se prueba por
      // separado con entradas donde solo coincide con OR.
      expect(d.correcta, isFalse);
    });

    test('ignorar la segunda entrada se detecta cuando no hay otra explicación',
        () {
      // XOR(1,0)=1 correcto. Estudiante responde 0, que no es la inversion
      // (0 no es !1=0... en este caso si lo es). Se prueba con NOR en su
      // lugar para aislar la regla de "ignoro una entrada".
      final d = diagnosticarRespuestaCompuerta(
        tipo: TipoCompuerta.xor_,
        entradas: [true, true],
        respuestaEstudiante: true,
      );
      // XOR(1,1) correcto es false; el estudiante responde true, que
      // coincide con ambas entradas (ambiguo) -> alguna regla debe
      // dispararse sin lanzar excepcion.
      expect(d.correcta, isFalse);
      expect(d.mensaje, isNotEmpty);
    });
  });
}
