/// Progreso del estudiante por modulo, persistido en el dispositivo con
/// shared_preferences (sin cuenta ni conexion a internet), igual patron
/// que OscilloLab y MicroSim.
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> idsModulos = [
  'm1_algebra',
  'm2_compuertas',
  'm3_tablas',
  'm4_combinacionales',
  'm5_secuenciales',
];

const Map<String, String> nombresModulos = {
  'm1_algebra': 'Álgebra booleana',
  'm2_compuertas': 'Compuertas lógicas',
  'm3_tablas': 'Tablas de verdad',
  'm4_combinacionales': 'Circuitos combinacionales',
  'm5_secuenciales': 'Circuitos secuenciales',
};

class ProgresoState {
  final Map<String, bool> completado;
  const ProgresoState(this.completado);

  ProgresoState conModuloCompletado(String idModulo) {
    final nuevo = Map<String, bool>.from(completado);
    nuevo[idModulo] = true;
    return ProgresoState(nuevo);
  }

  int get totalCompletados => completado.values.where((v) => v).length;

  double get fraccionCompletada =>
      idsModulos.isEmpty ? 0 : totalCompletados / idsModulos.length;
}

class ProgresoNotifier extends Notifier<ProgresoState> {
  static const String _prefijoClave = 'logicpro_progreso_';

  @override
  ProgresoState build() {
    final inicial = {for (final id in idsModulos) id: false};
    _cargar();
    return ProgresoState(inicial);
  }

  Future<void> _cargar() async {
    final prefs = await SharedPreferences.getInstance();
    final cargado = <String, bool>{};
    for (final id in idsModulos) {
      cargado[id] = prefs.getBool('$_prefijoClave$id') ?? false;
    }
    state = ProgresoState(cargado);
  }

  Future<void> marcarCompletado(String idModulo) async {
    state = state.conModuloCompletado(idModulo);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefijoClave$idModulo', true);
  }
}

final progresoProvider =
    NotifierProvider<ProgresoNotifier, ProgresoState>(ProgresoNotifier.new);
