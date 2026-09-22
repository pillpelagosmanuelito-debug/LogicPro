/// Simulador de circuitos secuenciales: flip-flops D, JK y T sobre una
/// secuencia de flancos de reloj, más un contador binario de 2 bits armado
/// con dos flip-flops JK en modo toggle.
///
/// Puerto directo de EstadoFlipFlop / flanco_d / flanco_jk / flanco_t /
/// simular_secuencia_* / contador_binario_2bit en calib/logic_prototype.py.
library;

class EstadoFlipFlop {
  final bool q;
  const EstadoFlipFlop({this.q = false});

  bool get qNegado => !q;
}

EstadoFlipFlop flancoD(EstadoFlipFlop estado, bool d) {
  return EstadoFlipFlop(q: d);
}

EstadoFlipFlop flancoT(EstadoFlipFlop estado, bool t) {
  if (!t) return EstadoFlipFlop(q: estado.q);
  return EstadoFlipFlop(q: !estado.q);
}

/// Tabla de excitación JK: (0,0) mantiene, (1,0) fija en 1, (0,1) fija en 0,
/// (1,1) conmuta (toggle).
EstadoFlipFlop flancoJk(EstadoFlipFlop estado, bool j, bool k) {
  if (!j && !k) return EstadoFlipFlop(q: estado.q);
  if (j && !k) return const EstadoFlipFlop(q: true);
  if (!j && k) return const EstadoFlipFlop(q: false);
  return EstadoFlipFlop(q: !estado.q);
}

List<bool> simularSecuenciaD(List<bool> entradasD) {
  var estado = const EstadoFlipFlop();
  final lineaDeTiempo = <bool>[];
  for (final d in entradasD) {
    estado = flancoD(estado, d);
    lineaDeTiempo.add(estado.q);
  }
  return lineaDeTiempo;
}

class ParJk {
  final bool j;
  final bool k;
  const ParJk(this.j, this.k);
}

List<bool> simularSecuenciaJk(List<ParJk> paresJk) {
  var estado = const EstadoFlipFlop();
  final lineaDeTiempo = <bool>[];
  for (final par in paresJk) {
    estado = flancoJk(estado, par.j, par.k);
    lineaDeTiempo.add(estado.q);
  }
  return lineaDeTiempo;
}

List<bool> simularSecuenciaT(List<bool> entradasT) {
  var estado = const EstadoFlipFlop();
  final lineaDeTiempo = <bool>[];
  for (final t in entradasT) {
    estado = flancoT(estado, t);
    lineaDeTiempo.add(estado.q);
  }
  return lineaDeTiempo;
}

class EstadoContador {
  final bool q1;
  final bool q0;
  const EstadoContador(this.q1, this.q0);

  int get valor => (q1 ? 2 : 0) + (q0 ? 1 : 0);
}

/// Contador binario de 2 bits: dos flip-flops JK en modo toggle (J=K=1
/// siempre), el segundo alimentado por el flanco de bajada de Q del
/// primero (división de frecuencia clásica de un contador asíncrono).
List<EstadoContador> contadorBinario2Bit(int numFlancos) {
  var q0 = const EstadoFlipFlop();
  var q1 = const EstadoFlipFlop();
  final lineaDeTiempo = <EstadoContador>[];
  var q0Anterior = q0.q;
  for (var i = 0; i < numFlancos; i++) {
    q0 = flancoJk(q0, true, true);
    if (q0Anterior && !q0.q) {
      q1 = flancoJk(q1, true, true);
    }
    q0Anterior = q0.q;
    lineaDeTiempo.add(EstadoContador(q1.q, q0.q));
  }
  return lineaDeTiempo;
}
