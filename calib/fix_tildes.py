"""
Corrige tildes faltantes DENTRO de strings y comentarios de todos los
archivos .dart (lib/ y test/), sin tocar nunca el codigo fuera de ellos
(identificadores permanecen ASCII puro, como exige
calib/check_ascii_identifiers.py).

Tecnica: recorre cada archivo caracter por caracter localizando los mismos
tramos de string/comentario que usa check_ascii_identifiers.py; dentro de
esos tramos aplica un diccionario de correcciones de tildes por palabra
completa (case-sensitive, con variantes en mayuscula inicial); fuera de
esos tramos copia el texto tal cual.
"""

import re
from pathlib import Path

RAIZ = Path(__file__).resolve().parent.parent
CARPETAS = [RAIZ / 'lib', RAIZ / 'test']

# palabra sin tilde -> palabra con tilde correcta (minusculas)
CORRECCIONES = {
    'logica': 'logica'.replace('logica', 'lógica'),
}

# Diccionario explicito (mas legible que generarlo con replace encadenados)
CORRECCIONES = {
    'algebra': 'álgebra',
    'analisis': 'análisis',
    'aplicacion': 'aplicación',
    'aqui': 'aquí',
    'asi': 'así',
    'automatica': 'automática',
    'automaticamente': 'automáticamente',
    'automatico': 'automático',
    'basica': 'básica',
    'basico': 'básico',
    'boton': 'botón',
    'caracter': 'carácter',
    'catalogo': 'catálogo',
    'codigo': 'código',
    'condicion': 'condición',
    'construccion': 'construcción',
    'deteccion': 'detección',
    'diagnostico': 'diagnóstico',
    'dificil': 'difícil',
    'distribucion': 'distribución',
    'educacion': 'educación',
    'ejecucion': 'ejecución',
    'evaluacion': 'evaluación',
    'explicacion': 'explicación',
    'explicita': 'explícita',
    'explicitamente': 'explícitamente',
    'explicito': 'explícito',
    'exito': 'éxito',
    'facil': 'fácil',
    'funcion': 'función',
    'generacion': 'generación',
    'interaccion': 'interacción',
    'limite': 'límite',
    'limites': 'límites',
    'logica': 'lógica',
    'logicas': 'lógicas',
    'logico': 'lógico',
    'logicos': 'lógicos',
    'metodo': 'método',
    'metodos': 'métodos',
    'numero': 'número',
    'numeros': 'números',
    'parentesis': 'paréntesis',
    'pedagogica': 'pedagógica',
    'pedagogico': 'pedagógico',
    'posicion': 'posición',
    'practica': 'práctica',
    'practicas': 'prácticas',
    'practico': 'práctico',
    'prediccion': 'predicción',
    'publico': 'público',
    'rapido': 'rápido',
    'segun': 'según',
    'seleccion': 'selección',
    'simulacion': 'simulación',
    'tambien': 'también',
    'tecnica': 'técnica',
    'tecnico': 'técnico',
    'teorico': 'teórico',
    'topologico': 'topológico',
    'traves': 'través',
    'ultima': 'última',
    'ultimo': 'último',
    'unica': 'única',
    'unico': 'único',
    'verificacion': 'verificación',
    'version': 'versión',
    'ademas': 'además',
    'electronica': 'electrónica',
    'electronico': 'electrónico',
}


def _capitalizar(original: str, corregida: str) -> str:
    if original[:1].isupper():
        return corregida[:1].upper() + corregida[1:]
    return corregida


def corregir_texto(texto: str) -> str:
    def reemplazar(m: re.Match) -> str:
        palabra = m.group(0)
        clave = palabra.lower()
        if clave in CORRECCIONES:
            return _capitalizar(palabra, CORRECCIONES[clave])
        return palabra

    return re.sub(r"[A-Za-z]+", reemplazar, texto)


def procesar_archivo(ruta: Path) -> bool:
    codigo = ruta.read_text(encoding='utf-8')
    resultado = []
    i = 0
    n = len(codigo)
    cambiado = False
    while i < n:
        c = codigo[i]
        if c == '/' and i + 1 < n and codigo[i + 1] == '/':
            inicio = i
            while i < n and codigo[i] != '\n':
                i += 1
            fragmento = codigo[inicio:i]
            nuevo = corregir_texto(fragmento)
            cambiado = cambiado or (nuevo != fragmento)
            resultado.append(nuevo)
            continue
        if c == '/' and i + 1 < n and codigo[i + 1] == '*':
            inicio = i
            i += 2
            while i + 1 < n and not (codigo[i] == '*' and codigo[i + 1] == '/'):
                i += 1
            i += 2
            fragmento = codigo[inicio:i]
            nuevo = corregir_texto(fragmento)
            cambiado = cambiado or (nuevo != fragmento)
            resultado.append(nuevo)
            continue
        if c in ("'", '"'):
            delim = c
            inicio = i
            i += 1
            while i < n and codigo[i] != delim:
                if codigo[i] == '\\' and i + 1 < n:
                    i += 2
                    continue
                i += 1
            i += 1
            fragmento = codigo[inicio:i]
            nuevo = corregir_texto(fragmento)
            cambiado = cambiado or (nuevo != fragmento)
            resultado.append(nuevo)
            continue
        resultado.append(c)
        i += 1
    if cambiado:
        ruta.write_text(''.join(resultado), encoding='utf-8')
    return cambiado


def main():
    total_modificados = 0
    for carpeta in CARPETAS:
        if not carpeta.exists():
            continue
        for ruta in sorted(carpeta.rglob('*.dart')):
            if ruta.name == 'fix_tildes.py':
                continue
            if procesar_archivo(ruta):
                total_modificados += 1
                print(f"corregido: {ruta.relative_to(RAIZ)}")
    print(f"\nTotal de archivos con tildes corregidas: {total_modificados}")


if __name__ == '__main__':
    main()
