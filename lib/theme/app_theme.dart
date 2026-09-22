/// Tema visual "circuito digital": fondo casi negro con acentos indigo y
/// violeta, y dos colores semánticos fijos para el estado lógico (verde
/// para 1/HIGH, rojo/coral para 0/LOW) usados en toda la app para pines,
/// LEDs y salidas de compuertas.
///
/// Paleta deliberadamente distinta a OscilloLab (verde fósforo/graphite/
/// ámbar de "panel de instrumento") y a MicroSim (cian cobre/graphite/
/// ámbar PWM de "placa de desarrollo"), ver docs/03_Arquitectura_Técnica.md.
library;

import 'package:flutter/material.dart';

class ColoresLogicos {
  static const Color alto = Color(0xFF33E08A); // 1 / HIGH / true
  static const Color bajo = Color(0xFFE0526B); // 0 / LOW / false
  static const Color fondoTablero = Color(0xFF0D0F1A);
  static const Color panel = Color(0xFF171B2E);
  static const Color panelClaro = Color(0xFF232948);
  static const Color acentoPrimario = Color(0xFF6C63FF); // indigo
  static const Color acentoSecundario = Color(0xFFB388FF); // violeta claro
}

class AppTheme {
  static ThemeData tema() {
    final base = ThemeData(
      brightness: Brightness.dark,
      useMaterial3: true,
      colorScheme: const ColorScheme.dark(
        primary: ColoresLogicos.acentoPrimario,
        secondary: ColoresLogicos.acentoSecundario,
        surface: ColoresLogicos.panel,
        error: ColoresLogicos.bajo,
      ),
      scaffoldBackgroundColor: ColoresLogicos.fondoTablero,
      fontFamily: 'Roboto',
    );
    return base.copyWith(
      appBarTheme: const AppBarTheme(
        backgroundColor: ColoresLogicos.fondoTablero,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
      ),
      cardTheme: const CardThemeData(
        color: ColoresLogicos.panel,
        elevation: 0,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      tabBarTheme: const TabBarThemeData(
        labelColor: ColoresLogicos.acentoSecundario,
        unselectedLabelColor: Colors.white60,
        indicatorColor: ColoresLogicos.acentoSecundario,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ColoresLogicos.acentoPrimario,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      textTheme: base.textTheme.apply(
        bodyColor: Colors.white.withValues(alpha: 0.92),
        displayColor: Colors.white,
      ),
    );
  }
}
