import random

from PIL import Image, ImageDraw


def get_cluster_index(i, cluster_index):
    while cluster_index[i] != i:
        i = cluster_index[i]
    return i


def connect(i, j, lattice, cluster_index):
    size = len(lattice)
    (ix, iy) = i
    (jx, jy) = j
    if size in (ix, iy, jx, jy):
        return
    if not lattice[ix][iy]:
        return
    if not lattice[jx][jy]:
        return
    ci = ix + iy * size
    cj = jx + jy * size
    ci = get_cluster_index(ci, cluster_index)
    cj = get_cluster_index(cj, cluster_index)
    if ci > cj:
        ci, cj = cj, ci
    cluster_index[cj] = ci


def clastering(lattice, cluster_index):
    size = len(lattice)
    for x in range(size):
        for y in range(size):
            connect((x, y), (x+1, y), lattice, cluster_index)
            connect((x, y), (x, y+1), lattice, cluster_index)


def draw_sites(lattice, g, draw, cluster_index):
    size = len(lattice)
    colors = [(255, 0, 0), (0, 255, 0), (0, 0, 255),
              (255, 255, 0), (255, 0, 255), (0, 255, 255)]
    for x, row in enumerate(lattice):
        for y, site in enumerate(row):
            if not site:
                continue
            ci = x + y * size
            c = get_cluster_index(ci, cluster_index)
            c = c % 6
            ix = x * g
            iy = y * g
            pos = (ix+1, iy+1, ix+g-1, iy+g-1)
            draw.ellipse(pos, fill=colors[c])


def draw_all(lattice, cluster_index):
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
    draw_sites(lattice, g, draw, cluster_index)
    im.save("test.png")


def make_data(size, p):
    lattice = [[False] * size for _ in range(size)]
    for x in range(size):
        for y in range(size):
            lattice[x][y] = random.random() < p
    return lattice


def main():
    size = 32
    p = 0.5
    lattice = make_data(size, p)
    cluster_index = list(range(size*size))
    clastering(lattice, cluster_index)
    draw_all(lattice, cluster_index)


if __name__ == '__main__':
    main()
