# Arquitectura Técnica — LogicPro

## Patrón: MVVM + Riverpod

- **Model:** catálogos de datos (`lib/modules/*/model/`) y el núcleo de dominio compartido: el motor de lógica digital (`lib/core/logic/`) y el tutor (`lib/core/tutor/`).
- **ViewModel:** un `Notifier<State>` por pantalla interactiva, expuesto vía `NotifierProvider`.
- **View:** widgets `Consumer(State)Widget` sin lógica de negocio.

## Por qué la estructura de navegación es distinta a las apps anteriores de la fábrica

CircuitLab Academy y CircuitAR usan un Drawer lateral; OscilloLab usa una `NavigationBar` inferior de 3 destinos con los módulos en una lista vertical; MicroSim usa un Drawer con portada en grilla de 2 columnas. LogicPro usa una **TabBar superior** de 6 pestañas (Inicio + los 5 módulos), fija bajo el AppBar, y el Tutor se alcanza con un botón de icono en el AppBar que hace *push* de una pantalla independiente — no es una pestaña ni un destino del Drawer. La portada de Inicio tampoco repite ni la lista vertical de OscilloLab ni la grilla de MicroSim: usa un **carrusel horizontal** (`PageView`) de tarjetas de módulo.

## El motor de lógica (`lib/core/logic/`)

| Archivo | Responsabilidad |
|---|---|
| `expr_lexer.dart` | Tokeniza una expresión booleana de texto |
| `expr_ast.dart` | Nodos del árbol de sintaxis (variable, NOT, operador binario AND/OR/XOR) |
| `expr_parser.dart` | Analizador descendente recursivo (gramática documentada en el archivo) |
| `expr_evaluator.dart` | Evalúa el AST contra un entorno de variables |
| `truth_table.dart` | Genera la tabla de verdad completa de una expresión; también expone `sonEquivalentes`, que compara dos expresiones sobre la unión de sus variables |
| `circuit.dart` | Evalúa un grafo de compuertas (`NodoCompuerta`) por orden topológico, con detección de ciclos — el motor de los circuitos combinacionales del Módulo 4 |
| `flip_flop.dart` | Flip-flops D, JK y T por flancos discretos, más un contador binario de 2 bits armado con dos JK en modo toggle |

### Gramática de expresiones soportada

```
expr          := or
or            := and ((OR | XOR) and)*
and           := unario (AND unario)*
unario        := NOT unario | primario
primario      := VAR | '(' expr ')'
```

Operadores aceptados: `!` o `~` (NOT), `&` o `.` (AND), `|` o `+` (OR), `^` (XOR). Variables: una sola letra A-Z (no distingue mayúsculas/minúsculas). No se soportan literales `0`/`1` como constantes en el MVP — ver `docs/04_Guia_del_Motor_Logico.md`.

### Validación antes del port a Dart

El mismo diseño (lexer, parser, evaluador, tabla de verdad, circuitos, flip-flops) se implementó primero en Python (`calib/logic_prototype.py`) y se probó con 29 aserciones (expresiones básicas, precedencia de operadores, paréntesis, las dos leyes de De Morgan, equivalencia de expresiones, medio sumador, sumador completo, detección de ciclos en un circuito, los tres tipos de flip-flop, y el contador binario) — todas pasando. El port a Dart es línea por línea, misma estructura de control, precisamente para poder verificar cada pieza contra su contraparte ya probada.

## El tutor (`lib/core/tutor/logic_tutor.dart`)

Compara la respuesta del estudiante contra el resultado real de la compuerta (calculado con la misma tabla de verdad que usa el motor) y aplica, en orden, un árbol de reglas: ¿es la salida exactamente invertida (confundió la compuerta con su versión negada)? ¿coincide con el resultado de la compuerta "opuesta" (AND↔OR)? ¿coincide exactamente con una sola de las dos entradas (ignoró la otra)? Si ninguna regla específica coincide, cae en un mensaje genérico que sigue siendo exacto (nunca inventado) porque se basa en el resultado real.

## Lecciones aplicadas del post-mortem de CircuitLab Academy

1. **Identificadores Dart en ASCII puro.** Verificado con `calib/check_ascii_identifiers.py`, que separa strings/comentarios del resto del código antes de buscar caracteres no-ASCII fuera de ellos — la misma herramienta detecta además llaves/paréntesis desbalanceados fuera de strings y comentarios.
2. **Evitar romper CI por desajuste de versión de Flutter.** El workflow de CI (`.github/workflows/ci.yml`) usa el canal `stable` de Flutter **sin fijar una versión concreta**, para que siempre compile contra las mismas APIs (`Color.withValues`, `CardThemeData`) con las que se escribió el código.
3. **No versionar `android/`/`ios/`.** Se generan en CI con `flutter create --platforms=android,ios --org com.logicpro.app --project-name logicpro .`.
4. **Contenido como dato declarativo**, no código: catálogos de leyes, ejercicios y circuitos preconstruidos son listas de constantes (`const`), no lógica embebida.
5. **Tildación revisada de forma sistemática.** Además de la revisión manual, se usó un script dedicado (`calib/fix_tildes.py`) que corrige tildes faltantes **solo** dentro de strings y comentarios (nunca en identificadores), reconstruyendo cada archivo caracter por caracter para no tocar el código fuera de esos tramos. Tras la corrección automática se hizo una revisión manual adicional para detectar y corregir los casos donde la corrección automática había alcanzado accidentalmente rutas de `import` o claves de mapa (ver advertencia más abajo).

### Advertencia sobre la corrección automática de tildes

La primera pasada de `calib/fix_tildes.py` corrigió, correctamente, la prosa dentro de comentarios y strings — pero como no distingue una ruta de `import` (que debe permanecer ASCII, porque nombra un archivo real en disco) de una oración en español dentro del mismo tipo de literal, corrigió por error palabras dentro de algunas rutas de `import` y de un identificador usado como clave de progreso (`'m1_algebra'` → `'m1_álgebra'`). Se detectó con una búsqueda dirigida (`grep` de imports y claves con tildes) inmediatamente después de correr el script, y se revirtió cada caso a mano antes de continuar. Quien extienda este script para otro proyecto debe excluir explícitamente el contenido de las rutas de `import` y de cualquier string usado como clave/id, no solo strings y comentarios en general.

## Limitación de este entorno de construcción

Igual que en OscilloLab y MicroSim, este contenedor no pudo descargar el SDK de Dart/Flutter (bloqueado por política de red), así que:

- El motor de lógica se validó de forma independiente en Python antes del port.
- El resto del código (UI, viewmodels, navegación) se escribió y se revisó manualmente: balance de llaves/paréntesis e identificadores ASCII confirmados con `calib/check_ascii_identifiers.py`, y resolución de todos los imports relativos verificada con un script que recorre el árbol de archivos.
- **No se ejecutó `flutter analyze` ni `flutter test` de verdad en este entorno.** El primer `flutter pub get && flutter analyze && flutter test`, local o en el primer run de CI, es la validación real pendiente.
