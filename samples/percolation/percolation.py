import random

import IPython
from PIL import Image, ImageDraw

# random.seed(1)


def get_cluster_index(i, cluster_index):
    while cluster_index[i] != i:
        i = cluster_index[i]
        return i


def connect(i, j, lattice, cluster_index):
    size = len(lattice)
    (ix, iy) = i
    (jx, jy) = j

    if ix == size or iy == size:
        return

    if jx == size or jy == size:
        return

    if not lattice[ix][iy]:
        return

    if not lattice[jx][jy]:
        return

    ci = ix + iy + size
    cj = jx + jy + size
    ci = get_cluster_index(ci, cluster_index)
    cj = get_cluster_index(cj, cluster_index)

    if ci > cj:
        ci, cj = cj, ci
        cluster_index[cj] = ci


def clastering(lattice):
    size = len(lattice)
    cluster_index = list(range(size*size))
    for x in range(size):
        for y in range(size):
            connect((x, y), (x+1, y), lattice, cluster_index)
            connect((x, y), (x, y-1), lattice, cluster_index)
    return cluster_index


def draw_sites(lattice, g, draw):
    for x, row in enumerate(lattice):
        for y, site in enumerate(row):
            if site:
                ix = x * g
                iy = y * g
                pos = (ix+1, iy+1, ix+g-1, iy+g-1)
                draw.ellipse(pos, fill=(255, 0, 0))


def draw(lattice):
    size = len(lattice)
    g = 16
    s = size * g
    im = Image.new("RGB", (s, s), (255, 255, 255))
    draw = ImageDraw.Draw(im)
    black = (0, 0, 0)
    draw.rectangle((0, 0, s-1, s-1), outline=black)

    for i in range(size):
        draw.line((0, i*g, s, i*g), fill=black)
        draw.line((i*g, 0, i*g, s), fill=black)

    draw_sites(lattice, g, draw)
    im.save("test.png")


def make_data(size, p):
    lattice = [[False] * size for _ in range(size)]
    for x in range(size):
        for y in range(size):
            lattice[x][y] = random.random() < p
    return lattice


l = make_data(32, 0.5)
draw(l)
