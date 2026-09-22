import '../../../core/logic/circuit.dart';

/// Circuitos combinacionales preconstruidos como grafos de compuertas
/// (dato declarativo, no lógica embebida). Se evaluan con
/// core/logic/circuit.dart::evaluarCircuito, el mismo motor probado en
/// calib/logic_prototype.py.
class CircuitoPreset {
  final String nombre;
  final String descripcion;
  final List<String> entradasExternas;
  final List<NodoCompuerta> compuertas;
  final List<String> salidasFinales; // ids a resaltar como "salida" del circuito

  const CircuitoPreset({
    required this.nombre,
    required this.descripcion,
    required this.entradasExternas,
    required this.compuertas,
    required this.salidasFinales,
  });
}

const List<CircuitoPreset> circuitosPreset = [
  CircuitoPreset(
    nombre: 'Medio sumador (Half Adder)',
    descripcion: 'Suma dos bits: SUMA = A xor B, ACARREO = A and B.',
    entradasExternas: ['A', 'B'],
    compuertas: [
      NodoCompuerta(id: 'SUMA', tipo: TipoCompuerta.xor_, entradas: ['ENT:A', 'ENT:B']),
      NodoCompuerta(id: 'ACARREO', tipo: TipoCompuerta.and_, entradas: ['ENT:A', 'ENT:B']),
    ],
    salidasFinales: ['SUMA', 'ACARREO'],
  ),
  CircuitoPreset(
    nombre: 'Sumador completo (Full Adder)',
    descripcion: 'Suma A, B y un acarreo de entrada (Cin) usando dos medios '
        'sumadores y una compuerta OR.',
    entradasExternas: ['A', 'B', 'CIN'],
    compuertas: [
      NodoCompuerta(id: 'XOR1', tipo: TipoCompuerta.xor_, entradas: ['ENT:A', 'ENT:B']),
      NodoCompuerta(id: 'AND1', tipo: TipoCompuerta.and_, entradas: ['ENT:A', 'ENT:B']),
      NodoCompuerta(id: 'SUMA', tipo: TipoCompuerta.xor_, entradas: ['XOR1', 'ENT:CIN']),
      NodoCompuerta(id: 'AND2', tipo: TipoCompuerta.and_, entradas: ['XOR1', 'ENT:CIN']),
      NodoCompuerta(id: 'COUT', tipo: TipoCompuerta.or_, entradas: ['AND1', 'AND2']),
    ],
    salidasFinales: ['SUMA', 'COUT'],
  ),
  CircuitoPreset(
    nombre: 'Multiplexor 2:1',
    descripcion: 'Selecciona I0 o I1 según la línea de selección S: '
        'Y = (!S . I0) + (S . I1).',
    entradasExternas: ['I0', 'I1', 'S'],
    compuertas: [
      NodoCompuerta(id: 'NS', tipo: TipoCompuerta.not_, entradas: ['ENT:S']),
      NodoCompuerta(id: 'AND1', tipo: TipoCompuerta.and_, entradas: ['ENT:I0', 'NS']),
      NodoCompuerta(id: 'AND2', tipo: TipoCompuerta.and_, entradas: ['ENT:I1', 'ENT:S']),
      NodoCompuerta(id: 'Y', tipo: TipoCompuerta.or_, entradas: ['AND1', 'AND2']),
    ],
    salidasFinales: ['Y'],
  ),
];
