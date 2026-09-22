/// Ejercicios de "completar la tabla de verdad": una expresion fija y los
/// indices de fila que se ocultan (se piden al estudiante). La respuesta
/// correcta nunca se guarda a mano: se calcula en tiempo real con
/// core/logic/truth_table.dart y se compara contra lo que el estudiante
/// marco.
library;

class EjercicioTabla {
  final String expresion;
  final List<int> filasOcultas;
  const EjercicioTabla({required this.expresion, required this.filasOcultas});
}

const List<EjercicioTabla> ejerciciosTabla = [
  EjercicioTabla(expresion: 'A & B', filasOcultas: [1, 3]),
  EjercicioTabla(expresion: 'A | B', filasOcultas: [0, 2]),
  EjercicioTabla(expresion: 'A ^ B', filasOcultas: [1, 2]),
  EjercicioTabla(expresion: '!(A & B)', filasOcultas: [0, 3]),
  EjercicioTabla(expresion: '(A | B) & !C', filasOcultas: [2, 5, 7]),
];
