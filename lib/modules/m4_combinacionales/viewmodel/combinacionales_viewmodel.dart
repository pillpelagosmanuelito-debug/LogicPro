import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/circuit.dart';
import '../../../shared/state/progress_provider.dart';
import '../model/circuito_preset.dart';

class CombinacionalesState {
  final int indiceCircuito;
  final Map<String, bool> entradasExternas;
  final Set<int> circuitosExplorados;

  const CombinacionalesState({
    this.indiceCircuito = 0,
    this.entradasExternas = const {},
    this.circuitosExplorados = const {},
  });

  CircuitoPreset get circuito => circuitosPreset[indiceCircuito];

  Map<String, bool> get entradasResueltas {
    final resultado = <String, bool>{};
    for (final nombre in circuito.entradasExternas) {
      resultado[nombre] = entradasExternas[nombre] ?? false;
    }
    return resultado;
  }

  Map<String, bool> get valoresCompuertas =>
      evaluarCircuito(circuito.compuertas, entradasResueltas);
}

class CombinacionalesViewModel extends Notifier<CombinacionalesState> {
  @override
  CombinacionalesState build() => const CombinacionalesState();

  void seleccionarCircuito(int indice) {
    state = CombinacionalesState(
      indiceCircuito: indice,
      circuitosExplorados: {...state.circuitosExplorados, indice},
    );
    if (state.circuitosExplorados.length >= circuitosPreset.length) {
      ref.read(progresoProvider.notifier).marcarCompletado('m4_combinacionales');
    }
  }

  void alternarEntrada(String nombre) {
    final nuevas = Map<String, bool>.from(state.entradasResueltas);
    nuevas[nombre] = !(nuevas[nombre] ?? false);
    state = CombinacionalesState(
      indiceCircuito: state.indiceCircuito,
      entradasExternas: nuevas,
      circuitosExplorados: {...state.circuitosExplorados, state.indiceCircuito},
    );
    if (state.circuitosExplorados.length >= circuitosPreset.length) {
      ref.read(progresoProvider.notifier).marcarCompletado('m4_combinacionales');
    }
  }
}

final combinacionalesViewModelProvider =
    NotifierProvider<CombinacionalesViewModel, CombinacionalesState>(
        CombinacionalesViewModel.new);
