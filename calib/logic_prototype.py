"""
Prototipo en Python del motor de logica digital de LogicPro.

Se disena y prueba aqui ANTES de portarse a Dart (lib/core/logic/), siguiendo
el mismo patron usado en OscilloLab (measurement_model.py) y MicroSim
(interpreter_prototype.py): un oraculo de verificacion independiente del
lenguaje final.

Cuatro piezas:
  1. Evaluador de expresiones booleanas (lexer + parser + evaluador recursivo
     descendente) sobre variables de una letra, operadores !, &, |, ^ y
     parentesis.
  2. Generador de tablas de verdad a partir de una expresion.
  3. Evaluador de circuitos combinacionales: un grafo de compuertas
     (AND/OR/NOT/NAND/NOR/XOR/XNOR) con entradas externas, resuelto por
     orden topologico.
  4. Simulador de circuitos secuenciales: flip-flops D, JK y T sobre una
     secuencia de flancos de reloj, produciendo una linea de tiempo de
     estados.
"""

from dataclasses import dataclass, field
from typing import Callable


# ---------------------------------------------------------------------------
# 1. Evaluador de expresiones booleanas
# ---------------------------------------------------------------------------

class ErrorExpresion(Exception):
    pass


class TokenExpr:
    def __init__(self, tipo, valor):
        self.tipo = tipo  # 'VAR' | 'NOT' | 'AND' | 'OR' | 'XOR' | 'LPAREN' | 'RPAREN' | 'EOF'
        self.valor = valor


def tokenizar_expresion(fuente: str) -> list:
    tokens = []
    i = 0
    n = len(fuente)
    while i < n:
        c = fuente[i]
        if c.isspace():
            i += 1
            continue
        if c.isalpha():
            tokens.append(TokenExpr('VAR', c.upper()))
            i += 1
            continue
        if c == '!' or c == '~':
            tokens.append(TokenExpr('NOT', c))
            i += 1
            continue
        if c == '&' or c == '.':
            tokens.append(TokenExpr('AND', c))
            i += 1
            continue
        if c == '|' or c == '+':
            tokens.append(TokenExpr('OR', c))
            i += 1
            continue
        if c == '^':
            tokens.append(TokenExpr('XOR', c))
            i += 1
            continue
        if c == '(':
            tokens.append(TokenExpr('LPAREN', c))
            i += 1
            continue
        if c == ')':
            tokens.append(TokenExpr('RPAREN', c))
            i += 1
            continue
        raise ErrorExpresion(f"Caracter no reconocido: '{c}'")
    tokens.append(TokenExpr('EOF', None))
    return tokens


class ParserExpresion:
    """Gramatica (precedencia ascendente): expr := or ; or := and (OR and)* ;
    and := unario (AND unario)* ; unario := NOT unario | primario ;
    primario := VAR | LPAREN expr RPAREN . XOR se trata al mismo nivel que OR
    pero como operador propio evaluado de izquierda a derecha junto con OR."""

    def __init__(self, tokens: list):
        self.tokens = tokens
        self.pos = 0

    def actual(self) -> TokenExpr:
        return self.tokens[self.pos]

    def avanzar(self) -> TokenExpr:
        t = self.tokens[self.pos]
        self.pos += 1
        return t

    def parsear(self):
        nodo = self.parsear_or()
        if self.actual().tipo != 'EOF':
            raise ErrorExpresion(f"Token inesperado: {self.actual().tipo}")
        return nodo

    def parsear_or(self):
        izq = self.parsear_and()
        while self.actual().tipo in ('OR', 'XOR'):
            op = self.avanzar().tipo
            der = self.parsear_and()
            izq = ('BIN', op, izq, der)
        return izq

    def parsear_and(self):
        izq = self.parsear_unario()
        while self.actual().tipo == 'AND':
            self.avanzar()
            der = self.parsear_unario()
            izq = ('BIN', 'AND', izq, der)
        return izq

    def parsear_unario(self):
        if self.actual().tipo == 'NOT':
            self.avanzar()
            return ('NOT', self.parsear_unario())
        return self.parsear_primario()

    def parsear_primario(self):
        t = self.actual()
        if t.tipo == 'VAR':
            self.avanzar()
            return ('VAR', t.valor)
        if t.tipo == 'LPAREN':
            self.avanzar()
            nodo = self.parsear_or()
            if self.actual().tipo != 'RPAREN':
                raise ErrorExpresion("Se esperaba ')'")
            self.avanzar()
            return nodo
        raise ErrorExpresion(f"Token inesperado: {t.tipo}")


def variables_de(nodo) -> set:
    if nodo[0] == 'VAR':
        return {nodo[1]}
    if nodo[0] == 'NOT':
        return variables_de(nodo[1])
    if nodo[0] == 'BIN':
        return variables_de(nodo[2]) | variables_de(nodo[3])
    raise ErrorExpresion("Nodo AST desconocido")


def evaluar_nodo(nodo, entorno: dict) -> bool:
    if nodo[0] == 'VAR':
        if nodo[1] not in entorno:
            raise ErrorExpresion(f"Variable sin valor: {nodo[1]}")
        return entorno[nodo[1]]
    if nodo[0] == 'NOT':
        return not evaluar_nodo(nodo[1], entorno)
    if nodo[0] == 'BIN':
        a = evaluar_nodo(nodo[2], entorno)
        b = evaluar_nodo(nodo[3], entorno)
        if nodo[1] == 'AND':
            return a and b
        if nodo[1] == 'OR':
            return a or b
        if nodo[1] == 'XOR':
            return a != b
    raise ErrorExpresion("Nodo AST desconocido")


def parsear_expresion(fuente: str):
    tokens = tokenizar_expresion(fuente)
    return ParserExpresion(tokens).parsear()


# ---------------------------------------------------------------------------
# 2. Generador de tablas de verdad
# ---------------------------------------------------------------------------

def son_equivalentes(expresion1: str, expresion2: str) -> bool:
    """Compara dos expresiones sobre la union de sus variables (no solo las
    de una de ellas), para que la comparacion sea valida aunque tengan
    distinta cantidad de variables."""
    nodo1 = parsear_expresion(expresion1)
    nodo2 = parsear_expresion(expresion2)
    variables = sorted(variables_de(nodo1) | variables_de(nodo2))
    n = len(variables)
    for combinacion in range(2 ** n):
        entorno = {}
        for idx, var in enumerate(variables):
            bit = (combinacion >> (n - idx - 1)) & 1
            entorno[var] = bool(bit)
        if evaluar_nodo(nodo1, entorno) != evaluar_nodo(nodo2, entorno):
            return False
    return True


def generar_tabla_verdad(fuente: str):
    nodo = parsear_expresion(fuente)
    variables = sorted(variables_de(nodo))
    filas = []
    n = len(variables)
    for combinacion in range(2 ** n):
        entorno = {}
        for idx, var in enumerate(variables):
            bit = (combinacion >> (n - idx - 1)) & 1
            entorno[var] = bool(bit)
        resultado = evaluar_nodo(nodo, entorno)
        filas.append((dict(entorno), resultado))
    return variables, filas


# ---------------------------------------------------------------------------
# 3. Evaluador de circuitos combinacionales (grafo de compuertas)
# ---------------------------------------------------------------------------

TIPOS_COMPUERTA = {
    'AND': lambda xs: all(xs),
    'OR': lambda xs: any(xs),
    'NOT': lambda xs: not xs[0],
    'NAND': lambda xs: not all(xs),
    'NOR': lambda xs: not any(xs),
    'XOR': lambda xs: (sum(1 for x in xs if x) % 2) == 1,
    'XNOR': lambda xs: (sum(1 for x in xs if x) % 2) == 0,
}


@dataclass
class NodoCompuerta:
    id: str
    tipo: str  # una clave de TIPOS_COMPUERTA
    entradas: list = field(default_factory=list)  # lista de ids: 'ENT:A' o el id de otra compuerta


class ErrorCircuito(Exception):
    pass


def evaluar_circuito(compuertas: list, entradas_externas: dict) -> dict:
    """compuertas: lista de NodoCompuerta. entradas_externas: {'A': True, ...}.
    Devuelve {id_compuerta: valor_booleano} resolviendo por orden topologico
    (deteccion de ciclos incluida)."""
    por_id = {c.id: c for c in compuertas}
    resueltos: dict = {}

    def resolver(id_nodo: str, pila: set):
        if id_nodo.startswith('ENT:'):
            nombre = id_nodo[4:]
            if nombre not in entradas_externas:
                raise ErrorCircuito(f"Entrada externa sin valor: {nombre}")
            return entradas_externas[nombre]
        if id_nodo in resueltos:
            return resueltos[id_nodo]
        if id_nodo in pila:
            raise ErrorCircuito(f"Ciclo detectado en el circuito en '{id_nodo}'")
        if id_nodo not in por_id:
            raise ErrorCircuito(f"Compuerta no encontrada: {id_nodo}")
        pila = pila | {id_nodo}
        nodo = por_id[id_nodo]
        valores_entrada = [resolver(e, pila) for e in nodo.entradas]
        if nodo.tipo not in TIPOS_COMPUERTA:
            raise ErrorCircuito(f"Tipo de compuerta desconocido: {nodo.tipo}")
        if nodo.tipo == 'NOT' and len(valores_entrada) != 1:
            raise ErrorCircuito("NOT requiere exactamente 1 entrada")
        if nodo.tipo != 'NOT' and len(valores_entrada) < 2:
            raise ErrorCircuito(f"{nodo.tipo} requiere al menos 2 entradas")
        resultado = TIPOS_COMPUERTA[nodo.tipo](valores_entrada)
        resueltos[id_nodo] = resultado
        return resultado

    for c in compuertas:
        resolver(c.id, set())
    return resueltos


# ---------------------------------------------------------------------------
# 4. Simulador de circuitos secuenciales (flip-flops con reloj)
# ---------------------------------------------------------------------------

@dataclass
class EstadoFlipFlop:
    q: bool = False

    def q_neg(self) -> bool:
        return not self.q


def flanco_d(estado: EstadoFlipFlop, d: bool) -> EstadoFlipFlop:
    return EstadoFlipFlop(q=d)


def flanco_t(estado: EstadoFlipFlop, t: bool) -> EstadoFlipFlop:
    return EstadoFlipFlop(q=(estado.q != t) if t else estado.q)


def flanco_jk(estado: EstadoFlipFlop, j: bool, k: bool) -> EstadoFlipFlop:
    if not j and not k:
        return EstadoFlipFlop(q=estado.q)
    if j and not k:
        return EstadoFlipFlop(q=True)
    if not j and k:
        return EstadoFlipFlop(q=False)
    return EstadoFlipFlop(q=not estado.q)  # J=K=1 -> conmuta (toggle)


def simular_secuencia_d(entradas_d: list) -> list:
    """Devuelve la linea de tiempo de Q tras cada flanco de subida de reloj,
    para un flip-flop tipo D."""
    estado = EstadoFlipFlop()
    linea_de_tiempo = []
    for d in entradas_d:
        estado = flanco_d(estado, d)
        linea_de_tiempo.append(estado.q)
    return linea_de_tiempo


def simular_secuencia_jk(pares_jk: list) -> list:
    estado = EstadoFlipFlop()
    linea_de_tiempo = []
    for j, k in pares_jk:
        estado = flanco_jk(estado, j, k)
        linea_de_tiempo.append(estado.q)
    return linea_de_tiempo


def simular_secuencia_t(entradas_t: list) -> list:
    estado = EstadoFlipFlop()
    linea_de_tiempo = []
    for t in entradas_t:
        estado = flanco_t(estado, t)
        linea_de_tiempo.append(estado.q)
    return linea_de_tiempo


def contador_binario_2bit(num_flancos: int) -> list:
    """Contador de 2 bits construido con dos flip-flops JK en modo toggle
    (J=K=1 siempre), el segundo alimentado por Q del primero (division de
    frecuencia clasica). Devuelve [(q1, q0), ...] tras cada flanco."""
    q0 = EstadoFlipFlop()
    q1 = EstadoFlipFlop()
    linea_de_tiempo = []
    q0_anterior = q0.q
    for _ in range(num_flancos):
        q0 = flanco_jk(q0, True, True)
        # q1 solo conmuta cuando q0 baja de 1 a 0 (flanco de bajada de q0,
        # division de frecuencia entre etapas)
        if q0_anterior and not q0.q:
            q1 = flanco_jk(q1, True, True)
        q0_anterior = q0.q
        linea_de_tiempo.append((q1.q, q0.q))
    return linea_de_tiempo


# ---------------------------------------------------------------------------
# Pruebas
# ---------------------------------------------------------------------------

def _assert(cond, mensaje):
    if not cond:
        raise AssertionError(mensaje)
    print(f"OK: {mensaje}")


def test_expresion_basica():
    nodo = parsear_expresion("A & B")
    _assert(evaluar_nodo(nodo, {'A': True, 'B': True}) is True, "A&B con A=1,B=1 -> 1")
    _assert(evaluar_nodo(nodo, {'A': True, 'B': False}) is False, "A&B con A=1,B=0 -> 0")


def test_expresion_precedencia():
    # NOT tiene mayor precedencia que AND, que tiene mayor precedencia que OR/XOR
    nodo = parsear_expresion("!A & B | C")
    # !A & B | C  ==  ((!A) & B) | C
    r1 = evaluar_nodo(nodo, {'A': False, 'B': False, 'C': False})
    _assert(r1 is False, "!A&B|C con A=0,B=0,C=0 -> (1&0)|0 = 0")
    r2 = evaluar_nodo(nodo, {'A': False, 'B': True, 'C': False})
    _assert(r2 is True, "!A&B|C con A=0,B=1,C=0 -> (1&1)|0 = 1")
    r3 = evaluar_nodo(nodo, {'A': True, 'B': True, 'C': True})
    _assert(r3 is True, "!A&B|C con A=1,B=1,C=1 -> (0&1)|1 = 1")


def test_expresion_parentesis():
    nodo = parsear_expresion("(A | B) & !C")
    r1 = evaluar_nodo(nodo, {'A': True, 'B': False, 'C': False})
    _assert(r1 is True, "(A|B)&!C con A=1,B=0,C=0 -> 1")
    r2 = evaluar_nodo(nodo, {'A': True, 'B': False, 'C': True})
    _assert(r2 is False, "(A|B)&!C con A=1,B=0,C=1 -> 0")


def test_tabla_verdad_and():
    variables, filas = generar_tabla_verdad("A & B")
    _assert(variables == ['A', 'B'], "variables ordenadas de A&B son [A,B]")
    _assert(len(filas) == 4, "tabla de A&B tiene 4 filas")
    esperado = [False, False, False, True]
    obtenido = [r for (_, r) in filas]
    _assert(obtenido == esperado, f"tabla A&B == {esperado}")


def test_tabla_verdad_xor():
    variables, filas = generar_tabla_verdad("A ^ B")
    obtenido = [r for (_, r) in filas]
    _assert(obtenido == [False, True, True, False], "tabla A^B == [0,1,1,0]")


def test_de_morgan():
    # !(A & B) == (!A | !B)
    izq = parsear_expresion("!(A & B)")
    der = parsear_expresion("!A | !B")
    for a in (True, False):
        for b in (True, False):
            entorno = {'A': a, 'B': b}
            va = evaluar_nodo(izq, entorno)
            vb = evaluar_nodo(der, entorno)
            _assert(va == vb, f"De Morgan AND: A={a},B={b} -> {va}=={vb}")
    # !(A | B) == (!A & !B)
    izq2 = parsear_expresion("!(A | B)")
    der2 = parsear_expresion("!A & !B")
    for a in (True, False):
        for b in (True, False):
            entorno = {'A': a, 'B': b}
            va = evaluar_nodo(izq2, entorno)
            vb = evaluar_nodo(der2, entorno)
            _assert(va == vb, f"De Morgan OR: A={a},B={b} -> {va}=={vb}")


def test_circuito_medio_sumador():
    # Medio sumador: SUMA = A xor B, ACARREO = A and B
    compuertas = [
        NodoCompuerta('SUMA', 'XOR', ['ENT:A', 'ENT:B']),
        NodoCompuerta('ACARREO', 'AND', ['ENT:A', 'ENT:B']),
    ]
    r = evaluar_circuito(compuertas, {'A': True, 'B': True})
    _assert(r['SUMA'] is False and r['ACARREO'] is True, "medio sumador 1+1 -> suma=0,acarreo=1")
    r2 = evaluar_circuito(compuertas, {'A': True, 'B': False})
    _assert(r2['SUMA'] is True and r2['ACARREO'] is False, "medio sumador 1+0 -> suma=1,acarreo=0")


def test_circuito_sumador_completo():
    # Sumador completo a partir de dos medios sumadores + OR, todo como grafo
    compuertas = [
        NodoCompuerta('XOR1', 'XOR', ['ENT:A', 'ENT:B']),
        NodoCompuerta('AND1', 'AND', ['ENT:A', 'ENT:B']),
        NodoCompuerta('SUMA', 'XOR', ['XOR1', 'ENT:CIN']),
        NodoCompuerta('AND2', 'AND', ['XOR1', 'ENT:CIN']),
        NodoCompuerta('COUT', 'OR', ['AND1', 'AND2']),
    ]
    casos = [
        (False, False, False, False, False),
        (True, True, True, True, True),
        (True, False, True, False, True),
    ]
    for a, b, cin, suma_esp, cout_esp in casos:
        r = evaluar_circuito(compuertas, {'A': a, 'B': b, 'CIN': cin})
        _assert(r['SUMA'] == suma_esp and r['COUT'] == cout_esp,
                f"sumador completo A={a},B={b},CIN={cin} -> SUMA={r['SUMA']},COUT={r['COUT']}")


def test_circuito_ciclo_detectado():
    compuertas = [
        NodoCompuerta('X', 'AND', ['Y', 'ENT:A']),
        NodoCompuerta('Y', 'OR', ['X', 'ENT:B']),
    ]
    try:
        evaluar_circuito(compuertas, {'A': True, 'B': True})
        _assert(False, "deberia haber lanzado ErrorCircuito por ciclo")
    except ErrorCircuito:
        _assert(True, "ciclo detectado correctamente en circuito X<->Y")


def test_flipflop_d():
    linea = simular_secuencia_d([True, False, True, True])
    _assert(linea == [True, False, True, True], "flip-flop D sigue la entrada en cada flanco")


def test_flipflop_jk_toggle():
    # J=K=1 en cada flanco -> Q alterna 1,0,1,0 desde estado inicial 0
    linea = simular_secuencia_jk([(True, True)] * 4)
    _assert(linea == [True, False, True, False], "flip-flop JK con J=K=1 conmuta cada flanco")


def test_flipflop_jk_set_reset():
    linea = simular_secuencia_jk([(True, False), (False, False), (False, True)])
    _assert(linea == [True, True, False], "flip-flop JK set/hold/reset")


def test_flipflop_t():
    linea = simular_secuencia_t([True, True, False, True])
    _assert(linea == [True, False, False, True], "flip-flop T conmuta solo cuando T=1")


def test_contador_binario():
    linea = contador_binario_2bit(6)
    # secuencia esperada de (q1,q0): 01,10,11,00,01,10
    esperado = [(False, True), (True, False), (True, True), (False, False), (False, True), (True, False)]
    _assert(linea == esperado, f"contador binario 2 bits == {esperado}")


def test_son_equivalentes():
    _assert(son_equivalentes("A + (A & B)", "A"), "A+(A&B) equivale a A (absorcion)")
    _assert(not son_equivalentes("A + (A & B)", "B"), "A+(A&B) NO equivale a B")
    _assert(son_equivalentes("!(A & B)", "!A | !B"), "De Morgan: !(A&B) equivale a !A|!B")
    _assert(son_equivalentes("A & (B | !B)", "A"), "A&(B|!B) equivale a A (complemento+identidad)")
    _assert(not son_equivalentes("A & (B | !B)", "B"), "A&(B|!B) NO equivale a B")
    _assert(son_equivalentes("(A & B) | (A & C)", "A & (B | C)"), "distributiva inversa")


def ejecutar_todas():
    test_expresion_basica()
    test_expresion_precedencia()
    test_expresion_parentesis()
    test_tabla_verdad_and()
    test_tabla_verdad_xor()
    test_de_morgan()
    test_son_equivalentes()
    test_circuito_medio_sumador()
    test_circuito_sumador_completo()
    test_circuito_ciclo_detectado()
    test_flipflop_d()
    test_flipflop_jk_toggle()
    test_flipflop_jk_set_reset()
    test_flipflop_t()
    test_contador_binario()
    print("\nTODAS LAS PRUEBAS PASARON")


if __name__ == '__main__':
    ejecutar_todas()
