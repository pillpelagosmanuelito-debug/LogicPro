"""
Verifica dos cosas en todo lib/ y test/:
  1. Ningun identificador Dart (fuera de strings/comentarios) contiene
     caracteres no-ASCII (tildes, enies, etc.) -- lo tildado solo puede
     vivir dentro de literales de string o comentarios.
  2. Las llaves y parentesis estan balanceados fuera de strings y
     comentarios (una comprobacion basta como red de seguridad adicional,
     ya que el analizador real de Dart no puede correr en este entorno).

Misma tecnica que calib/check_ascii_identifiers.py de MicroSim: primero se
"vacian" los literales de string y los comentarios, y solo despues se
revisa el resto del archivo.
"""

import re
import sys
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CARPETAS = [RAIZ / 'lib', RAIZ / 'test']


def quitar_strings_y_comentarios(codigo: str) -> str:
    resultado = []
    i = 0
    n = len(codigo)
    while i < n:
        c = codigo[i]
        # Comentario de linea
        if c == '/' and i + 1 < n and codigo[i + 1] == '/':
            while i < n and codigo[i] != '\n':
                i += 1
            continue
        # Comentario de bloque
        if c == '/' and i + 1 < n and codigo[i + 1] == '*':
            i += 2
            while i + 1 < n and not (codigo[i] == '*' and codigo[i + 1] == '/'):
                i += 1
            i += 2
            continue
        # String triple con comillas simples o dobles
        for delim in ("'''", '"""'):
            if codigo[i:i + 3] == delim:
                i += 3
                while i + 3 <= n and codigo[i:i + 3] != delim:
                    i += 1
                i += 3
                break
        else:
            # String simple (comillas simples o dobles), con escape \
            if c in ("'", '"'):
                delim = c
                i += 1
                while i < n and codigo[i] != delim:
                    if codigo[i] == '\\' and i + 1 < n:
                        i += 2
                        continue
                    i += 1
                i += 1
                continue
            resultado.append(c)
            i += 1
            continue
        continue
    return ''.join(resultado)


def revisar_ascii(ruta: Path, codigo_limpio: str) -> list:
    problemas = []
    for num_linea, linea in enumerate(codigo_limpio.splitlines(), start=1):
        for ch in linea:
            if ord(ch) > 127:
                problemas.append(f"{ruta}:{num_linea}: caracter no-ASCII '{ch}' fuera de string/comentario")
    return problemas


def revisar_balance(ruta: Path, codigo_limpio: str) -> list:
    problemas = []
    pares = {'(': ')', '{': '}', '[': ']'}
    cierres = {v: k for k, v in pares.items()}
    pila = []
    for num_linea, linea in enumerate(codigo_limpio.splitlines(), start=1):
        for ch in linea:
            if ch in pares:
                pila.append((ch, num_linea))
            elif ch in cierres:
                if not pila or pila[-1][0] != cierres[ch]:
                    problemas.append(f"{ruta}:{num_linea}: cierre '{ch}' sin apertura correspondiente")
                    continue
                pila.pop()
    if pila:
        for ch, num_linea in pila:
            problemas.append(f"{ruta}:{num_linea}: apertura '{ch}' sin cerrar")
    return problemas


def main():
    todos_los_problemas = []
    total_archivos = 0
    for carpeta in CARPETAS:
        if not carpeta.exists():
            continue
        for ruta in sorted(carpeta.rglob('*.dart')):
            total_archivos += 1
            codigo = ruta.read_text(encoding='utf-8')
            limpio = quitar_strings_y_comentarios(codigo)
            todos_los_problemas.extend(revisar_ascii(ruta, limpio))
            todos_los_problemas.extend(revisar_balance(ruta, limpio))

    print(f"Archivos .dart revisados: {total_archivos}")
    if todos_los_problemas:
        print(f"\n{len(todos_los_problemas)} problema(s) encontrado(s):")
        for p in todos_los_problemas:
            print(f"  - {p}")
        sys.exit(1)
    print("OK: ningun identificador con caracteres no-ASCII, llaves y parentesis balanceados fuera de strings/comentarios")


if __name__ == '__main__':
    main()
