import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/truth_table.dart';
import '../../../shared/state/progress_provider.dart';
import '../model/ejercicio_simplificacion.dart';

class AlgebraState {
  final int indiceEjercicio;
  final int? opcionSeleccionada;
  final bool? esCorrecta;
  final int aciertos;
  final bool finalizado;

  const AlgebraState({
    this.indiceEjercicio = 0,
    this.opcionSeleccionada,
    this.esCorrecta,
    this.aciertos = 0,
    this.finalizado = false,
  });

  AlgebraState copyWith({
    int? indiceEjercicio,
    int? opcionSeleccionada,
    bool? esCorrecta,
    int? aciertos,
    bool? finalizado,
    bool limpiarSeleccion = false,
  }) {
    return AlgebraState(
      indiceEjercicio: indiceEjercicio ?? this.indiceEjercicio,
      opcionSeleccionada:
          limpiarSeleccion ? null : (opcionSeleccionada ?? this.opcionSeleccionada),
      esCorrecta: limpiarSeleccion ? null : (esCorrecta ?? this.esCorrecta),
      aciertos: aciertos ?? this.aciertos,
      finalizado: finalizado ?? this.finalizado,
    );
  }
}

class AlgebraViewModel extends Notifier<AlgebraState> {
  @override
  AlgebraState build() => const AlgebraState();

  void seleccionarOpcion(int indiceOpcion) {
    final ejercicio = ejerciciosSimplificacion[state.indiceEjercicio];
    final opcionTexto = ejercicio.opciones[indiceOpcion];
    final correcta = sonEquivalentes(ejercicio.expresionOriginal, opcionTexto);
    state = state.copyWith(
      opcionSeleccionada: indiceOpcion,
      esCorrecta: correcta,
      aciertos: correcta ? state.aciertos + 1 : state.aciertos,
    );
  }

  void siguiente() {
    final esUltimo =
        state.indiceEjercicio >= ejerciciosSimplificacion.length - 1;
    if (esUltimo) {
      state = state.copyWith(finalizado: true);
      ref.read(progresoProvider.notifier).marcarCompletado('m1_algebra');
      return;
    }
    state = AlgebraState(
      indiceEjercicio: state.indiceEjercicio + 1,
      aciertos: state.aciertos,
    );
  }

  void reiniciar() {
    state = const AlgebraState();
  }
}

final algebraViewModelProvider =
    NotifierProvider<AlgebraViewModel, AlgebraState>(AlgebraViewModel.new);
