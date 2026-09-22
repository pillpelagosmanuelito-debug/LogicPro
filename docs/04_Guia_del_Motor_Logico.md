# Guía del motor de lógica digital de LogicPro

## Expresiones booleanas: sintaxis aceptada

| Elemento | Sintaxis | Ejemplo |
|---|---|---|
| Variable | una letra A-Z (mayúscula o minúscula) | `A`, `b` |
| NOT | `!` o `~` (prefijo) | `!A` |
| AND | `&` o `.` | `A & B`, `A.B` |
| OR | `\|` o `+` | `A \| B`, `A+B` |
| XOR | `^` | `A ^ B` |
| Agrupación | `(` `)` | `(A \| B) & !C` |

Precedencia de mayor a menor: `NOT` > `AND` > `OR`/`XOR` (izquierda a derecha entre ellos). Ejemplo: `!A & B | C` se interpreta como `((!A) & B) | C`.

## Qué NO soporta (y por qué)

| Construcción | Por qué se excluyó del MVP |
|---|---|
| Literales `0`/`1` como constantes | El MVP cubre expresiones sobre variables; añadir constantes requeriría extender el lexer, el parser y el evaluador sin aportar un módulo nuevo — se dejó para una extensión futura |
| Variables de más de un carácter (`A1`, `entrada`) | Una letra por variable simplifica la UI (los círculos de entrada se etiquetan A, B, C...) sin perder generalidad pedagógica |
| Compuertas de más de 2 entradas en el editor interactivo del Módulo 2 | El motor de compuertas (`core/logic/circuit.dart`) sí soporta N entradas para AND/OR/NAND/NOR/XOR/XNOR; la UI del Módulo 2 se limita a 2 (o 1 para NOT) por claridad pedagógica |
| Minimización automática (mapas de Karnaugh, Quine-McCluskey) | Fuera del alcance de un MVP centrado en comprensión, no en optimización de circuitos |

## El evaluador de equivalencia (`sonEquivalentes`)

Usado en el Módulo 1 (práctica de simplificación) para validar la opción elegida por el estudiante sin una clave de respuesta fija: compara dos expresiones evaluándolas sobre **todas** las combinaciones de la unión de sus variables (no solo las de una de ellas), así que detecta correctamente que, por ejemplo, `A & (B | !B)` equivale a `A` aunque la segunda expresión no mencione a `B`.

## El motor de circuitos (`core/logic/circuit.dart`)

Un circuito es una lista de `NodoCompuerta`, cada una con un id, un tipo (AND/OR/NOT/NAND/NOR/XOR/XNOR) y una lista de entradas — cada entrada es el id de otra compuerta o una entrada externa (prefijo `ENT:`, por ejemplo `ENT:A`). `evaluarCircuito` resuelve el grafo por orden topológico, con memorización y detección de ciclos (lanza `ErrorCircuito` si encuentra uno). Es completamente general: puede describir cualquier circuito combinacional, no solo los 3 presets incluidos en el Módulo 4.

## El motor de flip-flops (`core/logic/flip_flop.dart`)

Cada flip-flop se modela por **flancos discretos**: una función pura `flancoX(estadoAnterior, entradas) -> estadoNuevo` que implementa la tabla de excitación correspondiente (D: Q sigue a D; T: Q conmuta si T=1; JK: mantiene/fija en 1/fija en 0/conmuta según la tabla clásica). Simular una secuencia completa es aplicar esa función repetidamente sobre una lista de entradas — el mismo patrón que usa un libro de texto para dibujar un diagrama de tiempo a mano.

## Extender el motor (para quien continúe el proyecto)

Para agregar una construcción nueva (por ejemplo, constantes `0`/`1`, o una compuerta de N entradas en la UI del Módulo 2): 1) agregar el caso al prototipo Python (`calib/logic_prototype.py`) y probarlo con una aserción nueva, 2) portar el cambio a Dart en el archivo correspondiente de `lib/core/logic/`, 3) actualizar el viewmodel y la vista del módulo afectado, 4) si aplica, actualizar las reglas del tutor (`lib/core/tutor/logic_tutor.dart`). Ese orden — prototipo validado en Python → port a Dart → UI → tutor — es el mismo que se siguió para todo el motor actual.
