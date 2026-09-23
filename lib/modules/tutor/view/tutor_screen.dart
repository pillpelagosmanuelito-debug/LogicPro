/// Pantalla independiente del Tutor: el estudiante elige una compuerta,
/// fija las entradas, escribe la salida que CREE correcta, y el tutor (por
/// reglas, ver core/tutor/logic_tutor.dart) diagnostica el error mas
/// probable si se equivoca. Accesible desde el botón del AppBar en
/// HomeShell, como pantalla push independiente (no una pestana mas), para
/// diferenciar la navegacion de LogicPro de MicroSim (donde el asistente
/// es un destino del Drawer).
library;

import 'package:flutter/material.dart';
import '../../../core/logic/circuit.dart';
import '../../../core/tutor/logic_tutor.dart';
import '../../../shared/widgets/estado_logico_widget.dart';
import '../../../shared/widgets/simbolo_compuerta_widget.dart';
import '../../../theme/app_theme.dart';
import '../../m2_compuertas/model/info_compuerta.dart';

class TutorScreen extends StatefulWidget {
  const TutorScreen({super.key});

  @override
  State<TutorScreen> createState() => _TutorScreenState();
}

class _TutorScreenState extends State<TutorScreen> {
  TipoCompuerta _tipo = TipoCompuerta.and_;
  List<bool> _entradas = [false, false];
  DiagnosticoTutor? _diagnostico;

  void _elegirTipo(TipoCompuerta tipo) {
    setState(() {
      _tipo = tipo;
      _entradas = List.filled(
          catalogoCompuertas.firstWhere((c) => c.tipo == tipo).numEntradas,
          false);
      _diagnostico = null;
    });
  }

  void _alternarEntrada(int i) {
    setState(() {
      _entradas[i] = !_entradas[i];
      _diagnostico = null;
    });
  }

  void _responder(bool respuesta) {
    setState(() {
      _diagnostico = diagnosticarRespuestaCompuerta(
        tipo: _tipo,
        entradas: _entradas,
        respuestaEstudiante: respuesta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tutor: explicar error lógico')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: ColoresLogicos.panel,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                'Este tutor funciona por reglas fijas sobre la tabla de '
                'verdad real de cada compuerta -- no es un modelo de '
                'lenguaje generativo. Por eso su diagnóstico siempre es '
                'exacto y nunca inventa una explicación que no corresponda '
                'a lo que elegiste (ver Memoria Descriptiva, sección 8).',
                style: TextStyle(color: Colors.white60, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            const Text('1. Elige una compuerta',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: catalogoCompuertas.map((c) {
                final seleccionado = c.tipo == _tipo;
                return ChoiceChip(
                  label: Text(nombreCompuerta(c.tipo)),
                  selected: seleccionado,
                  onSelected: (_) => _elegirTipo(c.tipo),
                  selectedColor: ColoresLogicos.acentoPrimario,
                  labelStyle: TextStyle(
                      color: seleccionado ? Colors.white : Colors.white70),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text('2. Fija las entradas',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: List.generate(_entradas.length, (i) {
                return Padding(
                  padding: const EdgeInsets.only(right: 20),
                  child: EstadoLogicoWidget(
                    etiqueta: String.fromCharCode(65 + i),
                    valor: _entradas[i],
                    onTap: () => _alternarEntrada(i),
                    tamano: 48,
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),
            const Text('3. ¿Cuál crees que es la salida?',
                style: TextStyle(color: Colors.white, fontSize: 15)),
            const SizedBox(height: 12),
            Row(
              children: [
                SimboloCompuertaWidget(tipo: _tipo),
                const SizedBox(width: 20),
                OutlinedButton(
                    onPressed: () => _responder(false),
                    child: const Text('Respondo: 0')),
                const SizedBox(width: 12),
                OutlinedButton(
                    onPressed: () => _responder(true),
                    child: const Text('Respondo: 1')),
              ],
            ),
            if (_diagnostico != null) ...[
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: (_diagnostico!.correcta
                          ? ColoresLogicos.alto
                          : ColoresLogicos.bajo)
                      .withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _diagnostico!.correcta
                        ? ColoresLogicos.alto
                        : ColoresLogicos.bajo,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      _diagnostico!.correcta
                          ? Icons.check_circle
                          : Icons.info_outline,
                      color: _diagnostico!.correcta
                          ? ColoresLogicos.alto
                          : ColoresLogicos.bajo,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_diagnostico!.mensaje,
                          style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
