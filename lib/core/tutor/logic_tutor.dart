/// Tutor de lógica digital: motor por reglas (NO inteligencia artificial
/// generativa) que revisa una respuesta del estudiante contra el resultado
/// correcto calculado por el motor de lib/core/logic/ y explica el error
/// más probable con un mensaje pedagógico específico.
///
/// Justificación (igual patrón que MicroSim/CodeExplainer y OscilloLab/
/// AssistantEngine, ver docs/01_Memoria_Descriptiva.md): el dominio es
/// pequeño y cerrado (7 tipos de compuerta, 3 operadores booleanos), así
/// que un árbol de reglas deterministas es exacto, instantáneo, gratuito y
/// nunca inventa una explicación que no corresponda al circuito real -
/// algo que un LLM generativo sí podría hacer ocasionalmente.
library;

import '../logic/circuit.dart';

enum TipoErrorLogico {
  ninguno,
  confundioAndOr,
  confundioAndNand,
  confundioOrNor,
  invirtioSalida,
  ignoroUnaEntrada,
  respuestaGenerica,
}

class DiagnosticoTutor {
  final bool correcta;
  final TipoErrorLogico tipoError;
  final String mensaje;
  const DiagnosticoTutor({
    required this.correcta,
    required this.tipoError,
    required this.mensaje,
  });
}

/// Compara la respuesta del estudiante para una compuerta con dos entradas
/// contra el resultado correcto, e intenta diagnosticar POR QUÉ se
/// equivocó probando las confusiones más comunes entre estudiantes
/// principiantes.
DiagnosticoTutor diagnosticarRespuestaCompuerta({
  required TipoCompuerta tipo,
  required List<bool> entradas,
  required bool respuestaEstudiante,
}) {
  bool aplicar(TipoCompuerta t) {
    switch (t) {
      case TipoCompuerta.and_:
        return entradas.every((x) => x);
      case TipoCompuerta.or_:
        return entradas.any((x) => x);
      case TipoCompuerta.not_:
        return !entradas[0];
      case TipoCompuerta.nand_:
        return !entradas.every((x) => x);
      case TipoCompuerta.nor_:
        return !entradas.any((x) => x);
      case TipoCompuerta.xor_:
        return entradas.where((x) => x).length.isOdd;
      case TipoCompuerta.xnor_:
        return entradas.where((x) => x).length.isEven;
    }
  }

  final correcto = aplicar(tipo);
  if (respuestaEstudiante == correcto) {
    return const DiagnosticoTutor(
      correcta: true,
      tipoError: TipoErrorLogico.ninguno,
      mensaje: 'Correcto: aplicaste bien la tabla de la compuerta.',
    );
  }

  // Regla 1: invirtió la salida completa (confundió la compuerta con su
  // versión negada: AND<->NAND, OR<->NOR, XOR<->XNOR).
  if (respuestaEstudiante == !correcto) {
    switch (tipo) {
      case TipoCompuerta.and_:
        return const DiagnosticoTutor(
          correcta: false,
          tipoError: TipoErrorLogico.confundioAndNand,
          mensaje: 'Tu respuesta es la salida invertida: pareces haber '
              'calculado NAND en vez de AND. Recuerda: AND da 1 solo si '
              'TODAS las entradas son 1; NAND es exactamente lo opuesto.',
        );
      case TipoCompuerta.nand_:
        return const DiagnosticoTutor(
          correcta: false,
          tipoError: TipoErrorLogico.confundioAndNand,
          mensaje: 'Tu respuesta es la salida invertida: pareces haber '
              'calculado AND en vez de NAND. NAND es AND seguido de un '
              'NOT: primero calcula AND y después invierte el resultado.',
        );
      case TipoCompuerta.or_:
        return const DiagnosticoTutor(
          correcta: false,
          tipoError: TipoErrorLogico.confundioOrNor,
          mensaje: 'Tu respuesta es la salida invertida: pareces haber '
              'calculado NOR en vez de OR. Recuerda: OR da 1 si AL MENOS '
              'una entrada es 1; NOR es exactamente lo opuesto.',
        );
      case TipoCompuerta.nor_:
        return const DiagnosticoTutor(
          correcta: false,
          tipoError: TipoErrorLogico.confundioOrNor,
          mensaje: 'Tu respuesta es la salida invertida: pareces haber '
              'calculado OR en vez de NOR. NOR es OR seguido de un NOT.',
        );
      default:
        return const DiagnosticoTutor(
          correcta: false,
          tipoError: TipoErrorLogico.invirtioSalida,
          mensaje: 'Tu respuesta es exactamente la salida invertida. '
              'Revisa si aplicaste un NOT de más (o de menos).',
        );
    }
  }

  // Regla 2: aplicó AND cuando correspondía OR (o viceversa), sin ser una
  // simple inversión (se detecta re-evaluando con el operador contrario).
  if (tipo == TipoCompuerta.and_ &&
      respuestaEstudiante == entradas.any((x) => x)) {
    return const DiagnosticoTutor(
      correcta: false,
      tipoError: TipoErrorLogico.confundioAndOr,
      mensaje: 'Calculaste el resultado de OR en vez de AND. AND exige '
          'que TODAS las entradas sean 1; basta con que UNA sea 1 para '
          'que OR de 1.',
    );
  }
  if (tipo == TipoCompuerta.or_ &&
      respuestaEstudiante == entradas.every((x) => x)) {
    return const DiagnosticoTutor(
      correcta: false,
      tipoError: TipoErrorLogico.confundioAndOr,
      mensaje: 'Calculaste el resultado de AND en vez de OR. OR ya da 1 '
          'con que UNA entrada sea 1; no hace falta que todas lo sean.',
    );
  }

  // Regla 3 (solo para 2 entradas): ignoró una de las entradas y copió la
  // otra tal cual.
  if (entradas.length == 2) {
    if (respuestaEstudiante == entradas[0]) {
      return const DiagnosticoTutor(
        correcta: false,
        tipoError: TipoErrorLogico.ignoroUnaEntrada,
        mensaje: 'Tu respuesta coincide exactamente con la primera '
            'entrada: parece que no consideraste la segunda entrada al '
            'calcular la salida.',
      );
    }
    if (respuestaEstudiante == entradas[1]) {
      return const DiagnosticoTutor(
        correcta: false,
        tipoError: TipoErrorLogico.ignoroUnaEntrada,
        mensaje: 'Tu respuesta coincide exactamente con la segunda '
            'entrada: parece que no consideraste la primera entrada al '
            'calcular la salida.',
      );
    }
  }

  return DiagnosticoTutor(
    correcta: false,
    tipoError: TipoErrorLogico.respuestaGenerica,
    mensaje: 'La respuesta correcta para ${nombreCompuerta(tipo)} con '
        'entradas ${entradas.map((e) => e ? '1' : '0').join(', ')} es '
        '${correcto ? '1' : '0'}. Repasa la tabla de verdad de '
        '${nombreCompuerta(tipo)} en el Módulo 3.',
  );
}
