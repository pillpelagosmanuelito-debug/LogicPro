/// Portada de Inicio: un carrusel horizontal (PageView) de tarjetas, una
/// por modulo, con el progreso general arriba. Distinto de la lista
/// vertical de OscilloLab y de la grilla de 2 columnas de MicroSim.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../shared/state/progress_provider.dart';
import '../../theme/app_theme.dart';

class InicioScreen extends ConsumerWidget {
  final void Function(int indicePestana) onAbrirModulo;
  const InicioScreen({super.key, required this.onAbrirModulo});

  static const List<_InfoModulo> _modulos = [
    _InfoModulo(
      indicePestana: 1,
      titulo: 'Álgebra booleana',
      descripcion: 'Leyes booleanas, evaluador de expresiones y '
          'simplificación.',
      icono: Icons.functions,
    ),
    _InfoModulo(
      indicePestana: 2,
      titulo: 'Compuertas lógicas',
      descripcion: 'AND, OR, NOT, NAND, NOR, XOR, XNOR: construye y prueba.',
      icono: Icons.memory_outlined,
    ),
    _InfoModulo(
      indicePestana: 3,
      titulo: 'Tablas de verdad',
      descripcion: 'Genera la tabla de verdad de cualquier expresión.',
      icono: Icons.table_chart_outlined,
    ),
    _InfoModulo(
      indicePestana: 4,
      titulo: 'Circuitos combinacionales',
      descripcion: 'Medio sumador, sumador completo y multiplexor.',
      icono: Icons.account_tree_outlined,
    ),
    _InfoModulo(
      indicePestana: 5,
      titulo: 'Circuitos secuenciales',
      descripcion: 'Flip-flops D, JK, T y un contador binario con reloj.',
      icono: Icons.timeline_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progreso = ref.watch(progresoProvider);
    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Simulador de sistemas digitales',
                  style: TextStyle(color: Colors.white70, fontSize: 15),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progreso.fraccionCompletada,
                    minHeight: 10,
                    backgroundColor: ColoresLogicos.panel,
                    color: ColoresLogicos.acentoSecundario,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${progreso.totalCompletados} de ${idsModulos.length} módulos completados',
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.82),
              itemCount: _modulos.length,
              itemBuilder: (context, i) {
                final m = _modulos[i];
                final idModulo = idsModulos[i];
                final completado = progreso.completado[idModulo] ?? false;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  child: _TarjetaModulo(
                    numero: i + 1,
                    info: m,
                    completado: completado,
                    onAbrir: () => onAbrirModulo(m.indicePestana),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _InfoModulo {
  final int indicePestana;
  final String titulo;
  final String descripcion;
  final IconData icono;
  const _InfoModulo({
    required this.indicePestana,
    required this.titulo,
    required this.descripcion,
    required this.icono,
  });
}

class _TarjetaModulo extends StatelessWidget {
  final int numero;
  final _InfoModulo info;
  final bool completado;
  final VoidCallback onAbrir;

  const _TarjetaModulo({
    required this.numero,
    required this.info,
    required this.completado,
    required this.onAbrir,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onAbrir,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: ColoresLogicos.acentoPrimario.withValues(alpha: 0.2),
                    child: Text('$numero',
                        style: const TextStyle(
                            color: ColoresLogicos.acentoSecundario,
                            fontWeight: FontWeight.bold)),
                  ),
                  const Spacer(),
                  if (completado)
                    const Icon(Icons.check_circle, color: ColoresLogicos.alto)
                  else
                    Icon(info.icono, color: Colors.white38),
                ],
              ),
              const SizedBox(height: 16),
              Text(info.titulo,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(info.descripcion,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              const Spacer(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onAbrir,
                  icon: const Icon(Icons.arrow_forward, size: 18),
                  label: const Text('Abrir'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
