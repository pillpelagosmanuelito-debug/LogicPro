# Memoria Descriptiva — LogicPro

## 1. Objetivo

Enseñar sistemas digitales mediante simulación interactiva de circuitos lógicos: el estudiante construye y prueba compuertas, genera tablas de verdad reales, arma circuitos combinacionales y experimenta con circuitos secuenciales (flip-flops y un contador), todo evaluado por un motor de lógica booleana real, no por animaciones con valores fijos.

## 2. Problema educativo

Los estudiantes de Ingeniería Electrónica suelen memorizar tablas de verdad y leyes booleanas sin conectar esa teoría con el comportamiento real de un circuito: saben que "AND da 1 si ambas entradas son 1", pero les cuesta relacionar eso con una compuerta física, con una expresión booleana completa, o con un circuito de varias compuertas conectadas entre sí.

## 3. Usuario objetivo

Estudiantes de Ingeniería Electrónica en las líneas de Electrónica digital, Sistemas digitales y Arquitectura computacional.

## 4. Competencias que desarrolla

| Competencia | Cómo se practica |
|---|---|
| Diseñar circuitos digitales | Circuitos combinacionales preconstruidos (medio sumador, sumador completo, multiplexor) evaluados en tiempo real sobre las entradas que el estudiante manipula |
| Interpretar lógica booleana | Evaluador real de expresiones (paréntesis, NOT/AND/OR/XOR) y generador de tablas de verdad |
| Resolver problemas digitales | Ejercicios de simplificación algebraica y de completar tablas de verdad, verificados matemáticamente contra el motor, no contra una clave fija |

## 5. Experiencia de aprendizaje

Cinco módulos progresivos — Álgebra booleana, Compuertas lógicas, Tablas de verdad, Circuitos combinacionales, Circuitos secuenciales — más un Tutor accesible en cualquier momento desde el AppBar, que diagnostica por qué una respuesta es incorrecta (no solo si lo es) usando reglas deterministas sobre la tabla de verdad real de cada compuerta.

## 6. MVP

**Incluye:** las 7 compuertas básicas (AND, OR, NOT, NAND, NOR, XOR, XNOR), evaluador de expresiones booleanas con paréntesis, generador de tablas de verdad, 3 circuitos combinacionales preconstruidos, 3 tipos de flip-flop (D, JK, T) y un contador binario de 2 bits, tutor de errores lógicos por reglas.

**No incluye (fuera de alcance deliberado):** un editor de circuitos completamente libre tipo "arrastrar y soltar" (los circuitos combinacionales son preconstruidos, con entradas manipulables — ver sección 10), más de 2 bits en el contador, minimización automática de expresiones (mapas de Karnaugh), simulación de retardos de propagación reales (los flip-flops se modelan por flancos discretos, no por tiempo continuo).

## 7. Por qué circuitos preconstruidos y no un editor libre en el MVP

Un editor de circuitos completamente libre (arrastrar compuertas, conectarlas a mano, validar el grafo resultante) es una pieza de ingeniería de UI considerable que no aporta valor pedagógico adicional frente a tener 3 circuitos clásicos y bien elegidos (medio sumador, sumador completo, multiplexor) con sus entradas manipulables y cada compuerta interna visible con su valor en tiempo real. El motor que los evalúa (`core/logic/circuit.dart`) sí es completamente general — acepta cualquier grafo de compuertas — así que un editor libre puede añadirse después sin tocar el motor, solo la UI que lo alimenta.

## 8. IA: tutor de errores lógicos, por reglas

Se evaluó un tutor basado en un modelo de lenguaje generativo y se descartó para el MVP por la misma razón aplicada en MicroSim (CodeExplainer) y OscilloLab (AssistantEngine): el dominio es pequeño y cerrado (7 tipos de compuerta, 3 operadores booleanos, un puñado de confusiones típicas de un estudiante principiante), así que un árbol de reglas deterministas sobre la tabla de verdad real de la compuerta es exacto, instantáneo, gratuito, funciona sin conexión, y **nunca inventa** un diagnóstico que no corresponda a lo que el estudiante realmente marcó — algo que un LLM generativo sí podría hacer ocasionalmente. El tutor (`core/tutor/logic_tutor.dart`) no solo dice "incorrecto": reconoce los patrones de error más comunes (confundir una compuerta con su versión negada, calcular AND en vez de OR, ignorar una de las dos entradas) y explica cuál de ellos cometió el estudiante.

## 9. Diferenciación frente al catálogo existente

LogicPro corresponde al slot 20 del catálogo maestro ("Digital Logic Trainer" — sistemas binarios, compuertas lógicas, flip-flops y circuitos digitales), un área no cubierta por ninguna de las apps ya entregadas: CircuitAR enseña a seleccionar componentes discretos, CircuitLab Academy resuelve circuitos analógicos con un motor MNA, OscilloLab enseña a interpretar instrumentos de medición externos, MicroSim enseña a programar y ejecutar código en un microcontrolador simulado. Ninguna de las cuatro trabaja con álgebra booleana, compuertas lógicas ni circuitos secuenciales — LogicPro es la primera app de la fábrica dedicada a electrónica **digital** pura, distinta de la electrónica analógica (CircuitLab Academy) y de la programación de microcontroladores (MicroSim).

## 10. Riesgos y debilidades identificadas (análisis crítico)

| Riesgo | Mitigación aplicada | Limitación conocida |
|---|---|---|
| Que los "circuitos combinacionales" sean solo diagramas estáticos sin comportamiento real | Cada circuito es un grafo de compuertas real (`core/logic/circuit.dart`) resuelto por orden topológico con detección de ciclos, evaluado en vivo cuando el estudiante toca una entrada | Los circuitos disponibles en el MVP son 3 presets fijos, no un editor libre (ver sección 7) |
| Que la "simplificación algebraica" tenga una clave de respuesta fija y frágil | La opción correcta de cada ejercicio se determina en tiempo real comparando la tabla de verdad de la expresión original contra la de cada opción (`sonEquivalentes`, sobre la unión de variables de ambas), no con un índice marcado a mano | El generador de expresiones no soporta literales `0`/`1` como constantes (solo variables A-Z), así que los ejercicios se diseñaron para no necesitarlos |
| Que el tutor "invente" una explicación que no corresponda al error real | Motor de reglas deterministas que compara la respuesta del estudiante contra la salida real de la compuerta y contra las confusiones típicas conocidas, sin generación de texto libre | Cuando ninguna regla especifica coincide, el tutor cae en un mensaje genérico correcto pero menos específico |
| Que el modelo de flip-flops sea una simplificación excesiva | Se modelan por flancos discretos (una lista de transiciones), el mismo enfoque usado en libros de texto introductorios para tablas de excitación | No hay simulación de tiempo continuo, retardos de propagación, ni condiciones de carrera (race conditions) entre flip-flops |
| No se pudo compilar `flutter test`/`flutter build` en este entorno de desarrollo | El motor de lógica (expresiones, tablas de verdad, circuitos, flip-flops) se validó primero en Python (`calib/logic_prototype.py`, 29 aserciones, todas pasando) antes del port a Dart; revisión manual de balance de llaves/paréntesis e identificadores ASCII con `calib/check_ascii_identifiers.py` | El primer `flutter pub get && flutter analyze && flutter test` real queda pendiente (ver `docs/03_Arquitectura_Tecnica.md`) |

## 11. Potencial de uso real

Aplicable como práctica previa o complementaria en los cursos de Electrónica digital y Sistemas digitales, antes de o junto con el laboratorio físico con compuertas TTL/CMOS reales, o como herramienta de repaso para el examen de diseño de circuitos combinacionales y secuenciales.
