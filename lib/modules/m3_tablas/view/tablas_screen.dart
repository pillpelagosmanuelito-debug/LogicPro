import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/truth_table.dart';
import '../../../theme/app_theme.dart';
import '../model/ejercicio_tabla.dart';
import '../viewmodel/tablas_viewmodel.dart';

class TablasScreen extends StatelessWidget {
  const TablasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(tabs: [
            Tab(text: 'Generador'),
            Tab(text: 'Completa la tabla'),
          ]),
          Expanded(
            child: TabBarView(
              children: [_GeneradorView(), _EjercicioTablaView()],
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneradorView extends ConsumerWidget {
  const _GeneradorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(generadorViewModelProvider);
    final vm = ref.read(generadorViewModelProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Escribe una expresión (variables A-Z, ! & | ^ y paréntesis):',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 8),
          TextField(
            style: const TextStyle(color: Colors.white, fontFamily: 'monospace'),
            decoration: InputDecoration(
              filled: true,
              fillColor: ColoresLogicos.panel,
              hintText: 'Ej: (A | B) & !C',
              hintStyle: const TextStyle(color: Colors.white38),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            controller: TextEditingController(text: estado.texto)
              ..selection =
                  TextSelection.collapsed(offset: estado.texto.length),
            onSubmitted: vm.actualizarExpresion,
            onChanged: vm.actualizarExpresion,
          ),
          const SizedBox(height: 20),
          if (estado.error != null)
            Text('Error: ${estado.error}',
                style: const TextStyle(color: ColoresLogicos.bajo))
          else if (estado.tabla != null)
            Expanded(child: _TablaWidget(tabla: estado.tabla!)),
        ],
      ),
    );
  }
}

class _TablaWidget extends StatelessWidget {
  final TablaVerdad tabla;
  const _TablaWidget({required this.tabla});

  @override
  Widget build(BuildContext context) {
    final variables = tabla.variables;
    final filas = tabla.filas;
    return SingleChildScrollView(
      child: Table(
        border: TableBorder.all(color: Colors.white12),
        children: [
          TableRow(
            decoration: const BoxDecoration(color: ColoresLogicos.panelClaro),
            children: [
              ...variables.map((v) => _celda(v, esEncabezado: true)),
              _celda('Salida', esEncabezado: true),
            ],
          ),
          ...filas.map((fila) {
            return TableRow(children: [
              ...variables.map(
                  (v) => _celda(fila.entorno[v] == true ? '1' : '0')),
              _celda(fila.resultado == true ? '1' : '0',
                  resaltado: true, alto: fila.resultado == true),
            ]);
          }),
        ],
      ),
    );
  }

  Widget _celda(String texto,
      {bool esEncabezado = false, bool resaltado = false, bool alto = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      child: Center(
        child: Text(
          texto,
          style: TextStyle(
            color: resaltado
                ? (alto ? ColoresLogicos.alto : ColoresLogicos.bajo)
                : Colors.white.withValues(alpha: esEncabezado ? 0.9 : 0.75),
            fontWeight: esEncabezado || resaltado ? FontWeight.bold : FontWeight.normal,
            fontFamily: 'monospace',
          ),
        ),
      ),
    );
  }
}

class _EjercicioTablaView extends ConsumerWidget {
  const _EjercicioTablaView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(ejercicioTablaViewModelProvider);
    final vm = ref.read(ejercicioTablaViewModelProvider.notifier);
    final ejercicio = ejerciciosTabla[estado.indiceEjercicio];
    final tabla = generarTablaVerdad(ejercicio.expresion);

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Completa la salida para: ${ejercicio.expresion}',
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 6),
          const Text(
            'Toca las celdas marcadas con "?" y elige 0 o 1.',
            style: TextStyle(color: Colors.white54, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: SingleChildScrollView(
              child: Table(
                border: TableBorder.all(color: Colors.white12),
                children: [
                  TableRow(
                    decoration:
                        const BoxDecoration(color: ColoresLogicos.panelClaro),
                    children: [
                      ...tabla.variables.map((v) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                                child: Text(v,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold))),
                          )),
                      const Padding(
                        padding: EdgeInsets.all(8),
                        child: Center(
                            child: Text('Salida',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold))),
                      ),
                    ],
                  ),
                  ...List.generate(tabla.filas.length, (fila) {
                    final f = tabla.filas[fila];
                    final oculta = ejercicio.filasOcultas.contains(fila);
                    return TableRow(children: [
                      ...tabla.variables.map((v) => Padding(
                            padding: const EdgeInsets.all(8),
                            child: Center(
                                child: Text(f.entorno[v] == true ? '1' : '0',
                                    style: const TextStyle(
                                        color: Colors.white70,
                                        fontFamily: 'monospace'))),
                          )),
                      Padding(
                        padding: const EdgeInsets.all(4),
                        child: !oculta
                            ? Center(
                                child: Text(f.resultado == true ? '1' : '0',
                                    style: const TextStyle(
                                        color: Colors.white38,
                                        fontFamily: 'monospace')))
                            : _CeldaEditable(
                                fila: fila,
                                revelado: estado.revelado,
                                valorCorrecto: f.resultado,
                                valorMarcado: estado.respuestas[fila],
                                onMarcar: (v) => vm.marcar(fila, v),
                              ),
                      ),
                    ]);
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Aciertos: ${estado.aciertos}/${estado.totalPreguntado}',
                  style: const TextStyle(color: Colors.white54)),
              if (!estado.revelado)
                ElevatedButton(
                    onPressed: vm.revelar, child: const Text('Revisar'))
              else
                ElevatedButton(
                    onPressed: vm.siguiente,
                    child: const Text('Siguiente ejercicio')),
            ],
          ),
        ],
      ),
    );
  }
}

class _CeldaEditable extends StatelessWidget {
  final int fila;
  final bool revelado;
  final bool valorCorrecto;
  final bool? valorMarcado;
  final void Function(bool) onMarcar;

  const _CeldaEditable({
    required this.fila,
    required this.revelado,
    required this.valorCorrecto,
    required this.valorMarcado,
    required this.onMarcar,
  });

  @override
  Widget build(BuildContext context) {
    if (revelado) {
      final correcto = valorMarcado == valorCorrecto;
      return Center(
        child: Icon(
          correcto ? Icons.check_circle : Icons.cancel,
          color: correcto ? ColoresLogicos.alto : ColoresLogicos.bajo,
          size: 20,
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _boton('0', false),
        const SizedBox(width: 4),
        _boton('1', true),
      ],
    );
  }

  Widget _boton(String texto, bool valor) {
    final activo = valorMarcado == valor;
    return InkWell(
      onTap: () => onMarcar(valor),
      child: Container(
        width: 26,
        height: 26,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: activo
              ? ColoresLogicos.acentoPrimario
              : ColoresLogicos.panelClaro,
        ),
        child: Text(texto, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ),
    );
  }
}
