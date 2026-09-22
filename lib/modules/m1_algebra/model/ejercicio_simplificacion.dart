/// Ejercicios de simplificacion: una expresion original y varias opciones
/// de expresion "simplificada". La opcion correcta NO esta marcada a mano
/// -- se determina en tiempo de ejecución comparando la tabla de verdad de
/// cada opcion contra la de la expresion original (core/logic/truth_table),
/// para que la verificación sea siempre matematicamente real.
library;

class EjercicioSimplificacion {
  final String enunciado;
  final String expresionOriginal;
  final List<String> opciones;
  const EjercicioSimplificacion({
    required this.enunciado,
    required this.expresionOriginal,
    required this.opciones,
  });
}

const List<EjercicioSimplificacion> ejerciciosSimplificacion = [
  EjercicioSimplificacion(
    enunciado: 'Simplifica usando la ley de absorción:',
    expresionOriginal: 'A + (A & B)',
    opciones: ['A', 'B', 'A & B', 'A | B'],
  ),
  EjercicioSimplificacion(
    enunciado: 'Aplica la ley de De Morgan a esta expresión negada:',
    expresionOriginal: '!(A & B)',
    opciones: ['!A & !B', '!A | !B', 'A | B', 'A & B'],
  ),
  EjercicioSimplificacion(
    enunciado: 'Simplifica usando la ley del complemento (A + !A = 1):',
    expresionOriginal: 'A & (B | !B)',
    opciones: ['A', 'B', 'A & B', '!A'],
  ),
  EjercicioSimplificacion(
    enunciado: 'Simplifica esta expresión redundante:',
    expresionOriginal: '(A | B) & (A | B)',
    opciones: ['A & B', 'A | B', 'A', 'B'],
  ),
  EjercicioSimplificacion(
    enunciado: 'Aplica la propiedad distributiva en sentido inverso:',
    expresionOriginal: '(A & B) | (A & C)',
    opciones: ['A & (B | C)', 'A | (B & C)', '(A | B) & C', 'A & B & C'],
  ),
];
