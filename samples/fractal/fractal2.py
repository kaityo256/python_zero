from functools import reduce
from math import sqrt

from PIL import Image, ImageDraw


def length(a):
    (x, y) = reduce(lambda x, y: (x[0]+y[0], x[1]+y[1]), a)
    return sqrt(x**2 + y**2)


def convert(a, b):
    ax, ay = a
    alen = sqrt(ax**2+ay**2)
    c = ax/alen
    s = ay/alen
    scale = alen/length(b)
    b = [(scale*x, scale*y) for (x, y) in b]
    b = [(c * x - s * y, s * x + c * y) for (x, y) in b]
    return b


def draw_line(draw, a, s=(0, 0)):
    x1, y1 = s
    for (dx, dy) in a:
        x2 = x1 + dx
        y2 = y1 + dy
        draw.line((x1, y1, x2, y2), fill=(255, 255, 255))
        x1, y1 = x2, y2


def main():
    size = 512
    im = Image.new("RGB", (size, size))
    draw = ImageDraw.Draw(im)
    a = [(size, 0)]
    b = [(1, 0), (0.5, sqrt(3.0)/2), (0.5, -sqrt(3.0)/2), (1, 0)]
    for _ in range(2):
        a = [convert(i, b) for i in a]
        a = reduce(lambda x, y: x + y, a)
    draw_line(draw, a)
    im.save("test.png")


main()
