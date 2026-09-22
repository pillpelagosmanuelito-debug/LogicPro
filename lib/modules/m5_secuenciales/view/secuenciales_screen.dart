import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/logic/flip_flop.dart';
import '../../../shared/widgets/estado_logico_widget.dart';
import '../../../theme/app_theme.dart';
import '../viewmodel/secuenciales_viewmodel.dart';

class SecuencialesScreen extends StatelessWidget {
  const SecuencialesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [
            Tab(text: 'Flip-flops'),
            Tab(text: 'Contador binario'),
          ]),
          const Expanded(
            child: TabBarView(
              children: [_FlipFlopView(), _ContadorView()],
            ),
          ),
        ],
      ),
    );
  }
}

class _FlipFlopView extends ConsumerWidget {
  const _FlipFlopView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(secuencialesViewModelProvider);
    final vm = ref.read(secuencialesViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SegmentedButton<TipoFlipFlop>(
            segments: const [
              ButtonSegment(value: TipoFlipFlop.d, label: Text('D')),
              ButtonSegment(value: TipoFlipFlop.jk, label: Text('JK')),
              ButtonSegment(value: TipoFlipFlop.t, label: Text('T')),
            ],
            selected: {estado.tipo},
            onSelectionChanged: (s) => vm.seleccionarTipo(s.first),
          ),
          const SizedBox(height: 20),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: _entradasParaTipo(estado, vm),
                  ),
                  const SizedBox(height: 20),
                  const Icon(Icons.arrow_downward, color: Colors.white38),
                  const SizedBox(height: 8),
                  EstadoLogicoWidget(etiqueta: 'Q', valor: estado.qActual, tamano: 60),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: vm.aplicarFlanco,
                    icon: const Icon(Icons.bolt),
                    label: const Text('Aplicar flanco de reloj'),
                  ),
                  TextButton(
                      onPressed: vm.reiniciar, child: const Text('Reiniciar')),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text('Línea de tiempo de Q (${estado.flancosAplicados} flancos):',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 6,
            children: estado.lineaDeTiempo
                .map((q) => _bit(q))
                .toList(growable: false),
          ),
        ],
      ),
    );
  }

  List<Widget> _entradasParaTipo(
      SecuencialesState estado, SecuencialesViewModel vm) {
    switch (estado.tipo) {
      case TipoFlipFlop.d:
        return [
          EstadoLogicoWidget(etiqueta: 'D', valor: estado.entradaD, onTap: vm.alternarD)
        ];
      case TipoFlipFlop.jk:
        return [
          EstadoLogicoWidget(etiqueta: 'J', valor: estado.entradaJ, onTap: vm.alternarJ),
          EstadoLogicoWidget(etiqueta: 'K', valor: estado.entradaK, onTap: vm.alternarK),
        ];
      case TipoFlipFlop.t:
        return [
          EstadoLogicoWidget(etiqueta: 'T', valor: estado.entradaT, onTap: vm.alternarT)
        ];
    }
  }

  Widget _bit(bool valor) {
    final color = valor ? ColoresLogicos.alto : ColoresLogicos.bajo;
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color.withValues(alpha: 0.2), border: Border.all(color: color)),
      child: Text(valor ? '1' : '0', style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }
}

class _ContadorView extends ConsumerWidget {
  const _ContadorView();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(contadorViewModelProvider);
    final vm = ref.read(contadorViewModelProvider.notifier);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contador binario de 2 bits armado con dos flip-flops JK en modo '
            'toggle (J=K=1): el segundo flip-flop conmuta cada vez que el '
            'primero baja de 1 a 0 (división de frecuencia).',
            style: TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 20),
          Center(
            child: Column(
              children: [
                Text(
                  estado.linea.isEmpty ? '00' : _binario(estado.linea.last),
                  style: const TextStyle(
                      color: ColoresLogicos.acentoSecundario,
                      fontSize: 48,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold),
                ),
                Text(
                  'valor decimal: ${estado.linea.isEmpty ? 0 : estado.linea.last.valor}',
                  style: const TextStyle(color: Colors.white54),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ElevatedButton.icon(
                  onPressed: vm.avanzarFlanco,
                  icon: const Icon(Icons.bolt),
                  label: const Text('Flanco de reloj'),
                ),
                const SizedBox(width: 12),
                TextButton(onPressed: vm.reiniciar, child: const Text('Reiniciar')),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const Text('Historial:', style: TextStyle(color: Colors.white70)),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: estado.linea
                .map((e) => Container(
                      padding:
                          const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: ColoresLogicos.panel,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(_binario(e),
                          style: const TextStyle(
                              color: Colors.white,
                              fontFamily: 'monospace')),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  String _binario(EstadoContador estadoContador) {
    return '${estadoContador.q1 ? 1 : 0}${estadoContador.q0 ? 1 : 0}';
  }
}
