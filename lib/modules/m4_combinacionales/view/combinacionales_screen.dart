import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/circuit.dart';
import '../../../shared/widgets/estado_logico_widget.dart';
import '../../../theme/app_theme.dart';
import '../model/circuito_preset.dart';
import '../viewmodel/combinacionales_viewmodel.dart';

class CombinacionalesScreen extends ConsumerWidget {
  const CombinacionalesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(combinacionalesViewModelProvider);
    final vm = ref.read(combinacionalesViewModelProvider.notifier);
    final circuito = estado.circuito;
    final valores = estado.valoresCompuertas;
    final entradas = estado.entradasResueltas;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(circuitosPreset.length, (i) {
              final seleccionado = i == estado.indiceCircuito;
              return ChoiceChip(
                label: Text(circuitosPreset[i].nombre.split(' (').first),
                selected: seleccionado,
                onSelected: (_) => vm.seleccionarCircuito(i),
                selectedColor: ColoresLogicos.acentoPrimario,
                labelStyle:
                    TextStyle(color: seleccionado ? Colors.white : Colors.white70),
              );
            }),
          ),
          const SizedBox(height: 12),
          Text(circuito.descripcion,
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 20),
          const Text('Entradas externas (toca para alternar):',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 20,
            runSpacing: 12,
            children: circuito.entradasExternas.map((nombre) {
              return EstadoLogicoWidget(
                etiqueta: nombre,
                valor: entradas[nombre] ?? false,
                onTap: () => vm.alternarEntrada(nombre),
              );
            }).toList(),
          ),
          const SizedBox(height: 28),
          const Text('Estado interno del circuito:',
              style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(height: 10),
          ...circuito.compuertas.map((c) {
            final esSalida = circuito.salidasFinales.contains(c.id);
            final valor = valores[c.id] ?? false;
            return Card(
              color: esSalida
                  ? ColoresLogicos.panelClaro
                  : ColoresLogicos.panel,
              child: ListTile(
                dense: true,
                leading: Icon(
                  esSalida ? Icons.output : Icons.memory_outlined,
                  color: esSalida
                      ? ColoresLogicos.acentoSecundario
                      : Colors.white38,
                ),
                title: Text(
                  '${c.id}  (${nombreCompuerta(c.tipo)})',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: esSalida ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                subtitle: Text(
                  'entradas: ${c.entradas.map(_etiquetaEntrada).join(', ')}',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
                trailing: Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: (valor ? ColoresLogicos.alto : ColoresLogicos.bajo)
                        .withValues(alpha: 0.2),
                    border: Border.all(
                      color: valor ? ColoresLogicos.alto : ColoresLogicos.bajo,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    valor ? '1' : '0',
                    style: TextStyle(
                      color: valor ? ColoresLogicos.alto : ColoresLogicos.bajo,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  String _etiquetaEntrada(String id) {
    if (id.startsWith('ENT:')) return id.substring(4);
    return id;
  }
}
