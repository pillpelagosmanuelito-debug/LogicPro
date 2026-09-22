"""
Genera el icono tematico de LogicPro: una compuerta AND estilizada (arco +
linea recta) con dos entradas y una salida trazadas como pines de circuito,
sobre un fondo casi negro con acentos indigo/violeta -- la misma paleta de
lib/theme/app_theme.dart (ColoresLogicos), y deliberadamente distinta de
los iconos de OscilloLab (osciloscopio/multimetro, verde/ambar) y MicroSim
(chip con pines, cian/ambar).

Salida: assets/icon/icon.png, 1024x1024 RGBA.
"""

from PIL import Image, ImageDraw

TAM = 1024
FONDO = (13, 15, 26, 255)          # #0D0F1A
INDIGO = (108, 99, 255, 255)       # #6C63FF
VIOLETA = (179, 136, 255, 255)     # #B388FF
VERDE_ALTO = (51, 224, 138, 255)   # #33E08A


def dibujar_icono() -> Image.Image:
    img = Image.new('RGBA', (TAM, TAM), FONDO)
    draw = ImageDraw.Draw(img)

    cx, cy = TAM // 2, TAM // 2

    # Cuerpo de la compuerta AND: un rectangulo con el lado derecho
    # semicircular, trazado grueso en indigo.
    ancho_cuerpo = 360
    alto_cuerpo = 420
    izq = cx - ancho_cuerpo // 2 - 40
    top = cy - alto_cuerpo // 2
    der = izq + ancho_cuerpo
    bot = top + alto_cuerpo
    grosor = 26

    # Rectangulo (lado izquierdo recto, arriba y abajo rectos)
    draw.rounded_rectangle(
        [izq, top, cx + 40, bot], radius=18, outline=INDIGO, width=grosor
    )
    # Semicirculo derecho que sobrepone el borde recto para formar la "D"
    # caracteristica de una compuerta AND
    bbox_arco = [cx + 40 - alto_cuerpo // 2, top, cx + 40 + alto_cuerpo // 2, bot]
    draw.arc(bbox_arco, start=-90, end=90, fill=INDIGO, width=grosor)
    # Tapar el borde recto sobrante dentro del rectangulo con el color de
    # fondo para que el arco se vea limpio
    draw.rectangle([cx + 40 - grosor, top + grosor, cx + 40 + 4, bot - grosor],
                    fill=FONDO)
    draw.arc(bbox_arco, start=-90, end=90, fill=INDIGO, width=grosor)

    # Pines de entrada (dos lineas horizontales a la izquierda) en violeta
    y_in1 = cy - 90
    y_in2 = cy + 90
    x_pin_izq = izq - 140
    draw.line([(x_pin_izq, y_in1), (izq, y_in1)], fill=VIOLETA, width=grosor)
    draw.line([(x_pin_izq, y_in2), (izq, y_in2)], fill=VIOLETA, width=grosor)
    draw.ellipse([x_pin_izq - 22, y_in1 - 22, x_pin_izq + 22, y_in1 + 22],
                 fill=VIOLETA)
    draw.ellipse([x_pin_izq - 22, y_in2 - 22, x_pin_izq + 22, y_in2 + 22],
                 fill=VIOLETA)

    # Pin de salida (linea horizontal a la derecha) en verde alto (1/HIGH)
    x_pin_der = cx + 40 + alto_cuerpo // 2 + 140
    draw.line([(cx + 40 + alto_cuerpo // 2, cy), (x_pin_der, cy)],
              fill=VERDE_ALTO, width=grosor)
    draw.ellipse([x_pin_der - 26, cy - 26, x_pin_der + 26, cy + 26],
                 fill=VERDE_ALTO)

    return img


def main():
    img = dibujar_icono()
    ruta = 'assets/icon/icon.png'
    img.save(ruta)
    print(f"Icono guardado en {ruta} ({img.size[0]}x{img.size[1]})")


if __name__ == '__main__':
    main()
