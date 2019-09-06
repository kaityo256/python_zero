import random
from PIL import Image, ImageDraw


def find(i, parent):
    while i != parent[i]:
        i = parent[i]
    return i


def union(i, j, p, parent, L):
    if random.random() > p:
        return
    i = find(i, parent)
    j = find(j, parent)
    if j < i:
        i, j = j, i
    parent[j] = i


def make_conf(L, p):
    parent = [i for i in range(L * L)]
    for iy in range(L-1):
        for ix in range(L-1):
            i = ix + iy * L
            j = ix+1 + iy * L
            union(i, j, p, parent, L)
            j = ix + (iy+1) * L
            union(i, j, p, parent, L)
    return parent


def show_image(parent, L):
    size = 512
    s = size // L
    im = Image.new("RGB", (size, size), (255, 255, 255))
    colors = []
    for _ in range(L*L):
        r = random.randint(0, 255)
        g = random.randint(0, 255)
        b = random.randint(0, 255)
        colors.append((r, g, b))
    draw = ImageDraw.Draw(im)
    for iy in range(L):
        for ix in range(L):
            i = ix + iy * L
            i = find(i, parent)
            c = colors[i]
            draw.rectangle((ix*s, iy*s, ix*s+s, iy*s+s), fill=c)
    im.save("test.png")


L = 256
sites = make_conf(L, 0.48)
show_image(sites, L)
