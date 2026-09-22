import '../../../core/logic/circuit.dart';

class InfoCompuerta {
  final TipoCompuerta tipo;
  final String descripcion;
  final int numEntradas;
  const InfoCompuerta({
    required this.tipo,
    required this.descripcion,
    this.numEntradas = 2,
  });
}

const List<InfoCompuerta> catalogoCompuertas = [
  InfoCompuerta(
    tipo: TipoCompuerta.and_,
    descripcion: 'Salida 1 solo si TODAS las entradas son 1.',
  ),
  InfoCompuerta(
    tipo: TipoCompuerta.or_,
    descripcion: 'Salida 1 si AL MENOS una entrada es 1.',
  ),
  InfoCompuerta(
    tipo: TipoCompuerta.not_,
    descripcion: 'Invierte la única entrada.',
    numEntradas: 1,
  ),
  InfoCompuerta(
    tipo: TipoCompuerta.nand_,
    descripcion: 'AND seguido de un NOT: lo opuesto de AND.',
  ),
  InfoCompuerta(
    tipo: TipoCompuerta.nor_,
    descripcion: 'OR seguido de un NOT: lo opuesto de OR.',
  ),
  InfoCompuerta(
    tipo: TipoCompuerta.xor_,
    descripcion: 'Salida 1 si el número de entradas en 1 es impar.',
  ),
  InfoCompuerta(
    tipo: TipoCompuerta.xnor_,
    descripcion: 'Salida 1 si el número de entradas en 1 es par.',
  ),
];
