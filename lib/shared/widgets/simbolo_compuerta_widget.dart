/// Dibuja el símbolo esquemático (norma ANSI simplificada, trazo) de una
/// compuerta lógica, reutilizado en los módulos 2 y 4.
library;

import 'package:flutter/material.dart';
import '../../core/logic/circuit.dart';
import '../../theme/app_theme.dart';

class SimboloCompuertaWidget extends StatelessWidget {
  final TipoCompuerta tipo;
  final bool? salidaActual;
  final double ancho;
  final double alto;

  const SimboloCompuertaWidget({
    super.key,
    required this.tipo,
    this.salidaActual,
    this.ancho = 96,
    this.alto = 64,
  });

  @override
  Widget build(BuildContext context) {
    final color = salidaActual == null
        ? Colors.white70
        : (salidaActual! ? ColoresLogicos.alto : ColoresLogicos.bajo);
    return SizedBox(
      width: ancho,
      height: alto,
      child: CustomPaint(
        painter: _PintorCompuerta(tipo: tipo, color: color),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 2),
            child: Text(
              nombreCompuerta(tipo),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PintorCompuerta extends CustomPainter {
  final TipoCompuerta tipo;
  final Color color;
  const _PintorCompuerta({required this.tipo, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final trazo = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.4
      ..strokeJoin = StrokeJoin.round;
    final rect = Rect.fromLTWH(8, 4, size.width - 16, size.height - 8);
    final esCurvada = tipo == TipoCompuerta.or_ ||
        tipo == TipoCompuerta.nor_ ||
        tipo == TipoCompuerta.xor_ ||
        tipo == TipoCompuerta.xnor_;
    if (esCurvada) {
      final path = Path()
        ..moveTo(rect.left, rect.top)
        ..quadraticBezierTo(rect.center.dx, rect.top, rect.right, rect.center.dy)
        ..quadraticBezierTo(rect.center.dx, rect.bottom, rect.left, rect.bottom)
        ..quadraticBezierTo(rect.left + 14, rect.center.dy, rect.left, rect.top);
      canvas.drawPath(path, trazo);
      if (tipo == TipoCompuerta.xor_ || tipo == TipoCompuerta.xnor_) {
        final path2 = Path()
          ..moveTo(rect.left - 6, rect.top)
          ..quadraticBezierTo(
              rect.left + 8, rect.center.dy, rect.left - 6, rect.bottom);
        canvas.drawPath(path2, trazo);
      }
    } else if (tipo == TipoCompuerta.not_) {
      final path = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.left, rect.bottom)
        ..lineTo(rect.right - 10, rect.center.dy)
        ..close();
      canvas.drawPath(path, trazo);
    } else {
      final path = Path()
        ..moveTo(rect.left, rect.top)
        ..lineTo(rect.center.dx, rect.top)
        ..arcToPoint(Offset(rect.center.dx, rect.bottom),
            radius: Radius.circular(rect.height / 2), clockwise: true)
        ..lineTo(rect.left, rect.bottom)
        ..close();
      canvas.drawPath(path, trazo);
    }
    final tieneBurbuja = tipo == TipoCompuerta.nand_ ||
        tipo == TipoCompuerta.nor_ ||
        tipo == TipoCompuerta.not_ ||
        tipo == TipoCompuerta.xnor_;
    if (tieneBurbuja) {
      canvas.drawCircle(Offset(rect.right + 4, rect.center.dy), 4, trazo);
    }
  }

  @override
  bool shouldRepaint(covariant _PintorCompuerta oldDelegate) =>
      oldDelegate.tipo != tipo || oldDelegate.color != color;
}
