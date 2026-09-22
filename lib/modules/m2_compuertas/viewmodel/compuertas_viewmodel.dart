import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/circuit.dart';
import '../../../core/tutor/logic_tutor.dart';
import '../../../shared/state/progress_provider.dart';
import '../model/info_compuerta.dart';

class CompuertasState {
  final TipoCompuerta tipoSeleccionado;
  final List<bool> entradas;
  final bool? prediccionEstudiante;
  final DiagnosticoTutor? diagnostico;
  final int prediccionesCorrectas;
  final int prediccionesTotales;

  const CompuertasState({
    this.tipoSeleccionado = TipoCompuerta.and_,
    this.entradas = const [false, false],
    this.prediccionEstudiante,
    this.diagnostico,
    this.prediccionesCorrectas = 0,
    this.prediccionesTotales = 0,
  });

  bool get salidaReal => _aplicar(tipoSeleccionado, entradas);

  static bool _aplicar(TipoCompuerta t, List<bool> e) {
    switch (t) {
      case TipoCompuerta.and_:
        return e.every((x) => x);
      case TipoCompuerta.or_:
        return e.any((x) => x);
      case TipoCompuerta.not_:
        return !e[0];
      case TipoCompuerta.nand_:
        return !e.every((x) => x);
      case TipoCompuerta.nor_:
        return !e.any((x) => x);
      case TipoCompuerta.xor_:
        return e.where((x) => x).length.isOdd;
      case TipoCompuerta.xnor_:
        return e.where((x) => x).length.isEven;
    }
  }
}

class CompuertasViewModel extends Notifier<CompuertasState> {
  @override
  CompuertasState build() => const CompuertasState();

  InfoCompuerta get _infoActual =>
      catalogoCompuertas.firstWhere((c) => c.tipo == state.tipoSeleccionado);

  void seleccionarTipo(TipoCompuerta tipo) {
    final info = catalogoCompuertas.firstWhere((c) => c.tipo == tipo);
    state = CompuertasState(
      tipoSeleccionado: tipo,
      entradas: List.filled(info.numEntradas, false),
      prediccionesCorrectas: state.prediccionesCorrectas,
      prediccionesTotales: state.prediccionesTotales,
    );
  }

  void alternarEntrada(int indice) {
    if (state.prediccionEstudiante != null) return; // bloqueado hasta revelar
    final nuevas = List<bool>.from(state.entradas);
    nuevas[indice] = !nuevas[indice];
    state = CompuertasState(
      tipoSeleccionado: state.tipoSeleccionado,
      entradas: nuevas,
      prediccionesCorrectas: state.prediccionesCorrectas,
      prediccionesTotales: state.prediccionesTotales,
    );
  }

  void predecir(bool prediccion) {
    final diagnostico = diagnosticarRespuestaCompuerta(
      tipo: state.tipoSeleccionado,
      entradas: state.entradas,
      respuestaEstudiante: prediccion,
    );
    state = CompuertasState(
      tipoSeleccionado: state.tipoSeleccionado,
      entradas: state.entradas,
      prediccionEstudiante: prediccion,
      diagnostico: diagnostico,
      prediccionesCorrectas:
          state.prediccionesCorrectas + (diagnostico.correcta ? 1 : 0),
      prediccionesTotales: state.prediccionesTotales + 1,
    );
    if (state.prediccionesTotales >= 6 && diagnostico.correcta) {
      ref.read(progresoProvider.notifier).marcarCompletado('m2_compuertas');
    }
  }

  void siguienteRonda() {
    state = CompuertasState(
      tipoSeleccionado: state.tipoSeleccionado,
      entradas: List.filled(_infoActual.numEntradas, false),
      prediccionesCorrectas: state.prediccionesCorrectas,
      prediccionesTotales: state.prediccionesTotales,
    );
  }
}

final compuertasViewModelProvider =
    NotifierProvider<CompuertasViewModel, CompuertasState>(
        CompuertasViewModel.new);
