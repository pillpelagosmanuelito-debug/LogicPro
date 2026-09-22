# Manual de Usuario — LogicPro

## Navegación general

LogicPro usa una barra de pestañas (TabBar) fija bajo el título, con 6 destinos: **Inicio** y los 5 módulos (M1 a M5). Desde cualquier pestaña puedes abrir el **Tutor** tocando el icono de cerebro en la esquina superior derecha del AppBar; se abre como una pantalla independiente sobre la que estés viendo.

La portada de **Inicio** muestra tu progreso general y un carrusel horizontal (desliza con el dedo) con una tarjeta por módulo; toca "Abrir" en cualquier tarjeta para saltar directamente a ese módulo.

## Módulo 1 · Álgebra booleana

Dos pestañas internas:

- **Leyes booleanas:** una tarjeta por cada ley (identidad, nulidad, idempotencia, complemento, doble negación, conmutativa, asociativa, distributiva, absorción y las dos leyes de De Morgan), con su fórmula y una explicación breve.
- **Práctica: simplificar:** se te muestra una expresión y 4 opciones; elige la que sea la simplificación correcta. La respuesta se valida comparando la tabla de verdad completa de tu opción contra la de la expresión original — si no coinciden en **todas** las combinaciones, se marca incorrecta.

## Módulo 2 · Compuertas lógicas

Elige una compuerta (AND, OR, NOT, NAND, NOR, XOR, XNOR), toca los círculos de entrada para alternarlos entre 0 y 1, y antes de ver la salida real, **predice** si será 0 o 1. Si te equivocas, el Tutor te explica el tipo de error más probable (por ejemplo, "confundiste AND con NAND").

## Módulo 3 · Tablas de verdad

Dos pestañas internas:

- **Generador:** escribe cualquier expresión booleana (variables de A a Z, operadores `!`, `&`, `|`, `^`, y paréntesis) y LogicPro genera su tabla de verdad completa al instante.
- **Completa la tabla:** se te da una expresión con algunas filas de la tabla ocultas (marcadas "?"); toca 0 o 1 para cada una y presiona "Revisar" para ver cuántas acertaste.

## Módulo 4 · Circuitos combinacionales

Elige entre tres circuitos preconstruidos: **medio sumador**, **sumador completo** y **multiplexor 2:1**. Toca las entradas externas para alternarlas y observa, compuerta por compuerta, cómo se propaga cada valor hasta la salida final (resaltada).

## Módulo 5 · Circuitos secuenciales

Dos pestañas internas:

- **Flip-flops:** elige el tipo (D, JK o T), fija sus entradas y presiona "Aplicar flanco de reloj" para avanzar un paso; la línea de tiempo de abajo muestra el historial completo de Q.
- **Contador binario:** un contador de 2 bits armado con dos flip-flops JK en modo toggle. Cada flanco de reloj avanza el contador (00 → 01 → 10 → 11 → 00...).

## Tutor: explicar error lógico

Accesible desde el AppBar en cualquier módulo. Elige una compuerta, fija sus entradas, y responde qué salida crees que produce. El tutor funciona por reglas fijas sobre la tabla de verdad real — nunca por generación de texto libre — así que su diagnóstico siempre corresponde exactamente a lo que elegiste.

## Progreso

Se guarda automáticamente en el dispositivo, sin necesidad de cuenta ni conexión a internet. La barra de progreso en Inicio se llena a medida que completas cada módulo.
