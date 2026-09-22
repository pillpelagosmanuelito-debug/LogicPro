import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/flip_flop.dart';
import '../../../shared/state/progress_provider.dart';

enum TipoFlipFlop { d, jk, t }

/// El estado guarda el HISTORIAL completo de entradas aplicadas (no solo
/// la última), para que la linea de tiempo mostrada en la UI se recalcule
/// siempre reproduciendo ese historial contra el motor de
/// core/logic/flip_flop.dart -- la única fuente de verdad de Q, sin
/// duplicar la lógica de transicion aquí.
class SecuencialesState {
  final TipoFlipFlop tipo;
  final bool entradaD;
  final bool entradaJ;
  final bool entradaK;
  final bool entradaT;
  final List<bool> historialD;
  final List<ParJk> historialJk;
  final List<bool> historialT;

  const SecuencialesState({
    this.tipo = TipoFlipFlop.d,
    this.entradaD = false,
    this.entradaJ = false,
    this.entradaK = false,
    this.entradaT = false,
    this.historialD = const [],
    this.historialJk = const [],
    this.historialT = const [],
  });

  List<bool> get lineaDeTiempo {
    switch (tipo) {
      case TipoFlipFlop.d:
        return simularSecuenciaD(historialD);
      case TipoFlipFlop.jk:
        return simularSecuenciaJk(historialJk);
      case TipoFlipFlop.t:
        return simularSecuenciaT(historialT);
    }
  }

  int get flancosAplicados {
    switch (tipo) {
      case TipoFlipFlop.d:
        return historialD.length;
      case TipoFlipFlop.jk:
        return historialJk.length;
      case TipoFlipFlop.t:
        return historialT.length;
    }
  }

  bool get qActual {
    final linea = lineaDeTiempo;
    return linea.isEmpty ? false : linea.last;
  }
}

class SecuencialesViewModel extends Notifier<SecuencialesState> {
  @override
  SecuencialesState build() => const SecuencialesState();

  void seleccionarTipo(TipoFlipFlop tipo) {
    state = SecuencialesState(tipo: tipo);
  }

  void alternarD() => state = SecuencialesState(
        tipo: state.tipo,
        entradaD: !state.entradaD,
        entradaJ: state.entradaJ,
        entradaK: state.entradaK,
        entradaT: state.entradaT,
        historialD: state.historialD,
        historialJk: state.historialJk,
        historialT: state.historialT,
      );

  void alternarJ() => state = SecuencialesState(
        tipo: state.tipo,
        entradaD: state.entradaD,
        entradaJ: !state.entradaJ,
        entradaK: state.entradaK,
        entradaT: state.entradaT,
        historialD: state.historialD,
        historialJk: state.historialJk,
        historialT: state.historialT,
      );

  void alternarK() => state = SecuencialesState(
        tipo: state.tipo,
        entradaD: state.entradaD,
        entradaJ: state.entradaJ,
        entradaK: !state.entradaK,
        entradaT: state.entradaT,
        historialD: state.historialD,
        historialJk: state.historialJk,
        historialT: state.historialT,
      );

  void alternarT() => state = SecuencialesState(
        tipo: state.tipo,
        entradaD: state.entradaD,
        entradaJ: state.entradaJ,
        entradaK: state.entradaK,
        entradaT: !state.entradaT,
        historialD: state.historialD,
        historialJk: state.historialJk,
        historialT: state.historialT,
      );

  void aplicarFlanco() {
    switch (state.tipo) {
      case TipoFlipFlop.d:
        state = SecuencialesState(
          tipo: state.tipo,
          entradaD: state.entradaD,
          historialD: [...state.historialD, state.entradaD],
        );
        break;
      case TipoFlipFlop.jk:
        state = SecuencialesState(
          tipo: state.tipo,
          entradaJ: state.entradaJ,
          entradaK: state.entradaK,
          historialJk: [
            ...state.historialJk,
            ParJk(state.entradaJ, state.entradaK),
          ],
        );
        break;
      case TipoFlipFlop.t:
        state = SecuencialesState(
          tipo: state.tipo,
          entradaT: state.entradaT,
          historialT: [...state.historialT, state.entradaT],
        );
        break;
    }
    if (state.flancosAplicados >= 4) {
      ref.read(progresoProvider.notifier).marcarCompletado('m5_secuenciales');
    }
  }

  void reiniciar() {
    state = SecuencialesState(tipo: state.tipo);
  }
}

final secuencialesViewModelProvider =
    NotifierProvider<SecuencialesViewModel, SecuencialesState>(
        SecuencialesViewModel.new);

// ---- Contador binario ---------------------------------------------------

class ContadorState {
  final int numFlancos;
  const ContadorState({this.numFlancos = 0});

  List<EstadoContador> get linea => contadorBinario2Bit(numFlancos);
}

class ContadorViewModel extends Notifier<ContadorState> {
  @override
  ContadorState build() => const ContadorState();

  void avanzarFlanco() {
    state = ContadorState(numFlancos: state.numFlancos + 1);
  }

  void reiniciar() {
    state = const ContadorState();
  }
}

final contadorViewModelProvider =
    NotifierProvider<ContadorViewModel, ContadorState>(ContadorViewModel.new);
