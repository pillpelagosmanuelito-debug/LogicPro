/// Estructura de navegacion de LogicPro: una TabBar superior con 6
/// pestanas (Inicio + los 5 modulos), fija bajo el AppBar, y un botón en
/// el AppBar que abre el Tutor como pantalla independiente (push, no
/// pestana). Deliberadamente distinta de OscilloLab (NavigationBar
/// inferior de 3 destinos) y de MicroSim (Drawer lateral + portada en
/// grilla) -- ver docs/03_Arquitectura_Técnica.md.
library;

import 'package:flutter/material.dart';
import 'inicio_screen.dart';
import '../m1_algebra/view/algebra_screen.dart';
import '../m2_compuertas/view/compuertas_screen.dart';
import '../m3_tablas/view/tablas_screen.dart';
import '../m4_combinacionales/view/combinacionales_screen.dart';
import '../m5_secuenciales/view/secuenciales_screen.dart';
import '../tutor/view/tutor_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell>
    with SingleTickerProviderStateMixin {
  late final TabController _controlador;

  static const _pestanas = [
    Tab(text: 'Inicio', icon: Icon(Icons.home_outlined)),
    Tab(text: 'M1', icon: Icon(Icons.functions)),
    Tab(text: 'M2', icon: Icon(Icons.memory_outlined)),
    Tab(text: 'M3', icon: Icon(Icons.table_chart_outlined)),
    Tab(text: 'M4', icon: Icon(Icons.account_tree_outlined)),
    Tab(text: 'M5', icon: Icon(Icons.timeline_outlined)),
  ];

  void _irAModulo(int indice) {
    _controlador.animateTo(indice);
  }

  @override
  void initState() {
    super.initState();
    _controlador = TabController(length: _pestanas.length, vsync: this);
  }

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('LogicPro'),
        bottom: TabBar(controller: _controlador, tabs: _pestanas, isScrollable: true),
        actions: [
          IconButton(
            tooltip: 'Tutor: explicar error lógico',
            icon: const Icon(Icons.psychology_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TutorScreen()),
              );
            },
          ),
        ],
      ),
      // SafeArea evita que el contenido (p. ej. botones al pie) quede
      // debajo de la barra de navegación del sistema en Android.
      body: SafeArea(
        top: false,
        child: TabBarView(
          controller: _controlador,
          children: [
            InicioScreen(onAbrirModulo: _irAModulo),
            const AlgebraScreen(),
            const CompuertasScreen(),
            const TablasScreen(),
            const CombinacionalesScreen(),
            const SecuencialesScreen(),
          ],
        ),
      ),
    );
  }
}
