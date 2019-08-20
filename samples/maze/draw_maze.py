import sys
from PIL import Image, ImageDraw


def save_image(maze):
    g = 10
    w = len(maze)
    h = len(maze[0])
    white = (255, 255, 255)
    im = Image.new("RGB", (w*g, h*g), white)
    draw = ImageDraw.Draw(im)
    for ix in range(w):
        for iy in range(h):
            x = ix*g
            y = iy * g
            s = maze[ix][iy]
            color = white
            if s == '*':
                color = (0, 0, 0)
            elif s == 'S':
                color = (255, 0, 0)
            elif s == 'G':
                color = (0, 255, 0)
            elif s == '+':
                color = (0, 0, 255)
            draw.rectangle((x, y, x+g, y+g), fill=color)
    im.save("test.png")


def solve(x, y, step, maze):
    if maze[x][y] == '*':
        return
    if isinstance(maze[x][y], int):
        return

    maze[x][y] = step
    solve(x+1, y, step+1, maze)
    solve(x-1, y, step+1, maze)
    solve(x, y+1, step+1, maze)
    solve(x, y-1, step+1, maze)


def draw_path(x, y, count, maze):
    if not isinstance(maze[x][y], int):
        return
    if maze[x][y] != count:
        return
    maze[x][y] = '+'
    count -= 1
    draw_path(x+1, y, count, maze)
    draw_path(x-1, y, count, maze)
    draw_path(x, y+1, count, maze)
    draw_path(x, y-1, count, maze)


def load_maze(filename):
    maze = []
    with open(filename) as f:
        for line in f:
            maze.append(list(line.strip()))
    return maze


def run(filename):
    maze = load_maze(filename)
    solve(1, 1, 0, maze)
    gx = len(maze) - 2
    gy = len(maze[0]) - 2
    count = maze[gx][gy]
    draw_path(gx, gy, count, maze)
    maze[gx][gy] = 'G'
    save_image(maze)


if len(sys.argv) == 1:
    print("usage: python solve_maze.py inputfile")
else:
    run(sys.argv[1])
