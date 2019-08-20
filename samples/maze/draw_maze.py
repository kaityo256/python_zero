import sys
from PIL import Image, ImageDraw


def save_image(maze):
    g = 10
    w = len(maze)
    h = len(maze[0])
    color = {}
    color['*'] = (0, 0, 0)
    color[' '] = (255, 255, 255)
    color['+'] = (128, 128, 128)
    color['S'] = (255, 0, 0)
    color['G'] = (0, 255, 0)
    im = Image.new("RGB", (w*g, h*g), (255, 255, 255))
    draw = ImageDraw.Draw(im)
    for ix in range(w):
        for iy in range(h):
            x = ix*g
            y = iy * g
            s = maze[ix][iy]
            draw.rectangle((x, y, x+g, y+g), fill=color[s])
    im.save("test.png")


def find_start(maze):
    for r, row in enumerate(maze):
        for c, v in enumerate(row):
            if v == 'S':
                return r, c
    return None


def load_maze(filename):
    maze = []
    with open(filename) as f:
        for line in f:
            maze.append(list(line.strip()))
    return maze


def run(filename):
    maze = load_maze(filename)
    save_image(maze)


if len(sys.argv) == 1:
    print("usage: python solve_maze.py inputfile")
else:
    run(sys.argv[1])
