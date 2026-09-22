# LogicPro

Simulador educativo de lógica digital para estudiantes de Ingeniería Electrónica (Electrónica digital, Sistemas digitales, Arquitectura computacional). El estudiante construye y prueba compuertas lógicas, genera tablas de verdad reales, arma circuitos combinacionales y experimenta con circuitos secuenciales — todo evaluado por un motor de lógica booleana real, con un tutor por reglas que explica el error cuando algo sale mal.

## Problema educativo

Los estudiantes suelen memorizar tablas de verdad y leyes booleanas sin conectar esa teoría con el comportamiento real de un circuito. LogicPro cierra esa brecha con un motor real (no una animación pre-grabada): cada compuerta, tabla de verdad y circuito que ves se calcula en el momento a partir de lo que tú manipulas.

## Los 5 módulos

| # | Módulo | Qué practica el estudiante |
|---|--------|------------------------------|
| 1 | Álgebra booleana | Leyes booleanas + práctica de simplificación validada contra el motor real |
| 2 | Compuertas lógicas | AND, OR, NOT, NAND, NOR, XOR, XNOR — predice la salida y recibe diagnóstico del tutor si te equivocas |
| 3 | Tablas de verdad | Generador libre de tablas + ejercicio de completar filas ocultas |
| 4 | Circuitos combinacionales | Medio sumador, sumador completo y multiplexor 2:1, con cada compuerta interna visible en tiempo real |
| 5 | Circuitos secuenciales | Flip-flops D, JK, T por flancos discretos + contador binario de 2 bits |

Más un **Tutor de errores lógicos** (por reglas, no IA generativa), accesible desde el AppBar en cualquier pantalla.

## El motor de lógica

El núcleo de la app (`lib/core/logic/`) es un evaluador real de expresiones booleanas, un generador de tablas de verdad, un evaluador de circuitos (grafo de compuertas) y un simulador de flip-flops — no valores fijos ni animaciones. Se diseñó y probó primero en Python (`calib/logic_prototype.py`, 29 aserciones) antes de portarse a Dart. Ver `docs/03_Arquitectura_Tecnica.md` y `docs/04_Guia_del_Motor_Logico.md`.

## Stack técnico

- Flutter (canal `stable`), arquitectura MVVM
- Riverpod (`Notifier`/`NotifierProvider`) para estado
- `shared_preferences` para progreso persistente
- CI/CD con GitHub Actions → APK de release (ver `.github/workflows/ci.yml`)

## Estructura del proyecto

```
lib/
  core/logic/             Lexer, parser, AST, evaluador, tablas de verdad, circuitos, flip-flops
  core/tutor/             Tutor de errores lógicos (por reglas)
  modules/m1..m5/         Un módulo por carpeta: model / viewmodel / view
  modules/home/           TabBar superior + portada en carrusel horizontal
  modules/tutor/          Pantalla independiente del tutor (push desde el AppBar)
  shared/                 Estado compartido (progreso) y widgets reutilizables
  theme/                  Tema visual "circuito digital"
calib/                    Prototipo Python del motor + scripts de verificación (ASCII, tildes) -- no forman parte de la app
test/                     Pruebas del motor, del tutor y smoke test de la app
docs/                     Memoria descriptiva, manual de usuario, arquitectura, guía del motor
```

## Cómo compilar

```bash
flutter create --platforms=android,ios --org com.logicpro.app --project-name logicpro .
flutter pub get
dart run flutter_launcher_icons
flutter test
flutter build apk --release
```

> Nota de entrega: este proyecto se construyó en un entorno sin el SDK de Flutter instalable (la descarga del motor de Dart está bloqueada por política de red del contenedor). El motor de lógica se validó de forma independiente en Python; el resto del código se revisó manualmente con scripts de balance de llaves/paréntesis, resolución de imports e identificadores ASCII (`calib/check_ascii_identifiers.py`), más una revisión dedicada de tildación en todo el texto en español visible en la app — pero **no se ejecutó `flutter test` ni `flutter build` en este entorno**. El primer `flutter pub get && flutter analyze && flutter test`, local o el primer run del CI incluido, es la verificación real pendiente.
