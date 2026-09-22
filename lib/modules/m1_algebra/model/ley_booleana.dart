/// Catálogo de leyes del álgebra de Boole, como datos declarativos (no
/// lógica embebida), siguiendo la leccion aplicada en MicroSim/OscilloLab.
library;

class LeyBooleana {
  final String nombre;
  final String formula;
  final String explicacion;
  const LeyBooleana({
    required this.nombre,
    required this.formula,
    required this.explicacion,
  });
}

const List<LeyBooleana> leyesBooleanas = [
  LeyBooleana(
    nombre: 'Identidad',
    formula: 'A + 0 = A    A . 1 = A',
    explicacion: 'Sumar 0 o multiplicar por 1 no cambia el valor de A.',
  ),
  LeyBooleana(
    nombre: 'Nulidad',
    formula: 'A + 1 = 1    A . 0 = 0',
    explicacion: 'OR con 1 siempre da 1; AND con 0 siempre da 0.',
  ),
  LeyBooleana(
    nombre: 'Idempotencia',
    formula: 'A + A = A    A . A = A',
    explicacion: 'Combinar una variable consigo misma no aporta nada nuevo.',
  ),
  LeyBooleana(
    nombre: 'Complemento',
    formula: 'A + !A = 1    A . !A = 0',
    explicacion: 'Una variable y su negación cubren o vacían todo el dominio.',
  ),
  LeyBooleana(
    nombre: 'Doble negación',
    formula: '!(!A) = A',
    explicacion: 'Negar dos veces devuelve el valor original.',
  ),
  LeyBooleana(
    nombre: 'Conmutativa',
    formula: 'A + B = B + A    A . B = B . A',
    explicacion: 'El orden de los operandos no altera el resultado.',
  ),
  LeyBooleana(
    nombre: 'Asociativa',
    formula: '(A + B) + C = A + (B + C)',
    explicacion: 'El agrupamiento de operandos no altera el resultado.',
  ),
  LeyBooleana(
    nombre: 'Distributiva',
    formula: 'A . (B + C) = A.B + A.C',
    explicacion: 'AND se distribuye sobre OR, igual que en aritmética.',
  ),
  LeyBooleana(
    nombre: 'Absorción',
    formula: 'A + (A . B) = A    A . (A + B) = A',
    explicacion: 'El término más grande "absorbe" al más pequeño.',
  ),
  LeyBooleana(
    nombre: 'De Morgan (AND)',
    formula: '!(A . B) = !A + !B',
    explicacion: 'Negar un AND equivale a un OR de las negaciones.',
  ),
  LeyBooleana(
    nombre: 'De Morgan (OR)',
    formula: '!(A + B) = !A . !B',
    explicacion: 'Negar un OR equivale a un AND de las negaciones.',
  ),
];
