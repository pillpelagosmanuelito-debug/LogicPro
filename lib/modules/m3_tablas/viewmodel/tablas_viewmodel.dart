import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/logic_exceptions.dart';
import '../../../core/logic/truth_table.dart';
import '../../../shared/state/progress_provider.dart';
import '../model/ejercicio_tabla.dart';

// ---- Generador libre --------------------------------------------------

class GeneradorState {
  final String texto;
  final TablaVerdad? tabla;
  final String? error;
  const GeneradorState({this.texto = 'A & B', this.tabla, this.error});
}

class GeneradorViewModel extends Notifier<GeneradorState> {
  @override
  GeneradorState build() {
    return _generar('A & B');
  }

  GeneradorState _generar(String texto) {
    try {
      final tabla = generarTablaVerdad(texto);
      return GeneradorState(texto: texto, tabla: tabla);
    } on ErrorExpresion catch (e) {
      return GeneradorState(texto: texto, error: e.mensaje);
    }
  }

  void actualizarExpresion(String texto) {
    state = _generar(texto);
  }
}

final generadorViewModelProvider =
    NotifierProvider<GeneradorViewModel, GeneradorState>(
        GeneradorViewModel.new);

// ---- Ejercicio de completar tabla --------------------------------------

class EjercicioTablaState {
  final int indiceEjercicio;
  final Map<int, bool> respuestas; // fila -> valor marcado por el estudiante
  final bool revelado;
  final int aciertos;
  final int totalPreguntado;

  const EjercicioTablaState({
    this.indiceEjercicio = 0,
    this.respuestas = const {},
    this.revelado = false,
    this.aciertos = 0,
    this.totalPreguntado = 0,
  });
}

class EjercicioTablaViewModel extends Notifier<EjercicioTablaState> {
  @override
  EjercicioTablaState build() => const EjercicioTablaState();

  void marcar(int fila, bool valor) {
    if (state.revelado) return;
    final nuevas = Map<int, bool>.from(state.respuestas);
    nuevas[fila] = valor;
    state = EjercicioTablaState(
      indiceEjercicio: state.indiceEjercicio,
      respuestas: nuevas,
      aciertos: state.aciertos,
      totalPreguntado: state.totalPreguntado,
    );
  }

  void revelar() {
    final ejercicio = ejerciciosTabla[state.indiceEjercicio];
    final tabla = generarTablaVerdad(ejercicio.expresion);
    var aciertosRonda = 0;
    for (final fila in ejercicio.filasOcultas) {
      if (state.respuestas[fila] == tabla.filas[fila].resultado) {
        aciertosRonda++;
      }
    }
    state = EjercicioTablaState(
      indiceEjercicio: state.indiceEjercicio,
      respuestas: state.respuestas,
      revelado: true,
      aciertos: state.aciertos + aciertosRonda,
      totalPreguntado:
          state.totalPreguntado + ejercicio.filasOcultas.length,
    );
    if (state.indiceEjercicio >= ejerciciosTabla.length - 1) {
      ref.read(progresoProvider.notifier).marcarCompletado('m3_tablas');
    }
  }

  void siguiente() {
    final esUltimo = state.indiceEjercicio >= ejerciciosTabla.length - 1;
    state = EjercicioTablaState(
      indiceEjercicio: esUltimo ? 0 : state.indiceEjercicio + 1,
      aciertos: state.aciertos,
      totalPreguntado: state.totalPreguntado,
    );
  }
}

final ejercicioTablaViewModelProvider =
    NotifierProvider<EjercicioTablaViewModel, EjercicioTablaState>(
        EjercicioTablaViewModel.new);
