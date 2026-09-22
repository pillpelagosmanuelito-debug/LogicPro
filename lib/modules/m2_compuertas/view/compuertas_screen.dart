import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/circuit.dart';
import '../../../shared/widgets/estado_logico_widget.dart';
import '../../../shared/widgets/simbolo_compuerta_widget.dart';
import '../../../theme/app_theme.dart';
import '../model/info_compuerta.dart';
import '../viewmodel/compuertas_viewmodel.dart';

class CompuertasScreen extends ConsumerWidget {
  const CompuertasScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(compuertasViewModelProvider);
    final vm = ref.read(compuertasViewModelProvider.notifier);
    final info =
        catalogoCompuertas.firstWhere((c) => c.tipo == estado.tipoSeleccionado);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Elige una compuerta',
              style: TextStyle(color: Colors.white, fontSize: 16)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: catalogoCompuertas.map((c) {
              final seleccionado = c.tipo == estado.tipoSeleccionado;
              return ChoiceChip(
                label: Text(nombreCompuerta(c.tipo)),
                selected: seleccionado,
                onSelected: (_) => vm.seleccionarTipo(c.tipo),
                selectedColor: ColoresLogicos.acentoPrimario,
                labelStyle: TextStyle(
                    color: seleccionado ? Colors.white : Colors.white70),
              );
            }).toList(),
          ),
          const SizedBox(height: 6),
          Text(info.descripcion,
              style: const TextStyle(color: Colors.white54, fontSize: 13)),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: List.generate(estado.entradas.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: EstadoLogicoWidget(
                              etiqueta: 'Entrada ${String.fromCharCode(65 + i)}',
                              valor: estado.entradas[i],
                              onTap: () => vm.alternarEntrada(i),
                              tamano: 48,
                            ),
                          );
                        }),
                      ),
                      Column(
                        children: [
                          SimboloCompuertaWidget(
                            tipo: estado.tipoSeleccionado,
                            salidaActual: estado.prediccionEstudiante != null
                                ? estado.salidaReal
                                : null,
                          ),
                          const SizedBox(height: 12),
                          if (estado.prediccionEstudiante != null)
                            EstadoLogicoWidget(
                              etiqueta: 'Salida real',
                              valor: estado.salidaReal,
                              tamano: 52,
                            )
                          else
                            const Text('Predice la salida',
                                style: TextStyle(color: Colors.white38)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (estado.prediccionEstudiante == null)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                          onPressed: () => vm.predecir(false),
                          child: const Text('Predigo: 0'),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: () => vm.predecir(true),
                          child: const Text('Predigo: 1'),
                        ),
                      ],
                    )
                  else ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: (estado.diagnostico!.correcta
                                ? ColoresLogicos.alto
                                : ColoresLogicos.bajo)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        estado.diagnostico!.mensaje,
                        style: TextStyle(
                          color: estado.diagnostico!.correcta
                              ? ColoresLogicos.alto
                              : ColoresLogicos.bajo,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    ElevatedButton(
                      onPressed: vm.siguienteRonda,
                      child: const Text('Otra ronda'),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Aciertos: ${estado.prediccionesCorrectas} / ${estado.prediccionesTotales}',
            style: const TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
