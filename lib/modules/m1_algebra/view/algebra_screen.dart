import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../theme/app_theme.dart';
import '../model/ejercicio_simplificacion.dart';
import '../model/ley_booleana.dart';
import '../viewmodel/algebra_viewmodel.dart';

class AlgebraScreen extends ConsumerWidget {
  const AlgebraScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: 'Leyes booleanas'),
              Tab(text: 'Práctica: simplificar'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _ListaLeyes(),
                _PracticaSimplificacion(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaLeyes extends StatelessWidget {
  const _ListaLeyes();

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: leyesBooleanas.length,
      itemBuilder: (context, i) {
        final ley = leyesBooleanas[i];
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(ley.nombre,
                    style: const TextStyle(
                        color: ColoresLogicos.acentoSecundario,
                        fontWeight: FontWeight.bold,
                        fontSize: 16)),
                const SizedBox(height: 6),
                Text(ley.formula,
                    style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontSize: 15)),
                const SizedBox(height: 6),
                Text(ley.explicacion,
                    style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _PracticaSimplificacion extends ConsumerWidget {
  const _PracticaSimplificacion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(algebraViewModelProvider);
    final vm = ref.read(algebraViewModelProvider.notifier);

    if (estado.finalizado) {
      final total = ejerciciosSimplificacion.length;
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.emoji_events_outlined,
                  color: ColoresLogicos.alto, size: 56),
              const SizedBox(height: 16),
              Text('Completaste la práctica: ${estado.aciertos} de $total correctas',
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: vm.reiniciar,
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final ejercicio = ejerciciosSimplificacion[estado.indiceEjercicio];
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Ejercicio ${estado.indiceEjercicio + 1} de ${ejerciciosSimplificacion.length}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
          const SizedBox(height: 8),
          Text(ejercicio.enunciado,
              style: const TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: ColoresLogicos.panel,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(ejercicio.expresionOriginal,
                style: const TextStyle(
                    color: ColoresLogicos.acentoSecundario,
                    fontFamily: 'monospace',
                    fontSize: 17)),
          ),
          const SizedBox(height: 20),
          ...List.generate(ejercicio.opciones.length, (i) {
            final seleccionado = estado.opcionSeleccionada == i;
            Color? colorBorde;
            if (seleccionado) {
              colorBorde = estado.esCorrecta == true
                  ? ColoresLogicos.alto
                  : ColoresLogicos.bajo;
            }
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: estado.opcionSeleccionada == null
                      ? () => vm.seleccionarOpcion(i)
                      : null,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        vertical: 14, horizontal: 20),
                    side: BorderSide(
                        color: colorBorde ?? Colors.white24, width: 2),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    alignment: Alignment.centerLeft,
                  ),
                  child: Text(ejercicio.opciones[i],
                      style: const TextStyle(
                          color: Colors.white, fontFamily: 'monospace')),
                ),
              ),
            );
          }),
          if (estado.opcionSeleccionada != null) ...[
            const SizedBox(height: 8),
            Text(
              estado.esCorrecta == true
                  ? 'Correcto: ambas expresiones producen la misma tabla de verdad.'
                  : 'No es equivalente para todas las combinaciones. Intenta ver la tabla de verdad en el Modulo 3.',
              style: TextStyle(
                color: estado.esCorrecta == true
                    ? ColoresLogicos.alto
                    : ColoresLogicos.bajo,
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: vm.siguiente,
                child: Text(
                  estado.indiceEjercicio < ejerciciosSimplificacion.length - 1
                      ? 'Siguiente'
                      : 'Terminar',
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
