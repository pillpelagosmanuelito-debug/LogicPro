/// Indicador visual de un valor lógico (1/0, HIGH/LOW), reutilizado en los
/// 5 modulos para mostrar entradas y salidas de compuertas, circuitos y
/// flip-flops.
library;

import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class EstadoLogicoWidget extends StatelessWidget {
  final String etiqueta;
  final bool valor;
  final VoidCallback? onTap;
  final double tamano;

  const EstadoLogicoWidget({
    super.key,
    required this.etiqueta,
    required this.valor,
    this.onTap,
    this.tamano = 56,
  });

  @override
  Widget build(BuildContext context) {
    final color = valor ? ColoresLogicos.alto : ColoresLogicos.bajo;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(etiqueta, style: const TextStyle(color: Colors.white70, fontSize: 13)),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(tamano / 2),
          child: Container(
            width: tamano,
            height: tamano,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.18),
              border: Border.all(color: color, width: 2.5),
              boxShadow: [
                BoxShadow(
                  color: color.withValues(alpha: 0.45),
                  blurRadius: valor ? 12 : 0,
                  spreadRadius: valor ? 1 : 0,
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Text(
              valor ? '1' : '0',
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: tamano * 0.38,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
