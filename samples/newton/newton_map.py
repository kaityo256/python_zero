# ニュートン法の収束地図の原点拡大アニメーションを作成するコード

from PIL import Image, ImageDraw
from numba import jit


@jit
def newton(x):
    for _ in range(50):
        x = x - (x**3-1)/(3*x**2)
    return x


@jit
def plot(draw, s, mag):
    hs = s/2
    red = (255, 0, 0)
    green = (0, 255, 0)
    blue = (0, 0, 255)
    for x in range(s):
        for y in range(s):
            z = complex(x-hs+0.5, y-hs+0.5)/128*mag
            z = newton(z)
            if z.real > 0:
                c = red
            else:
                if z.imag > 0:
                    c = green
                else:
                    c = blue
            draw.rectangle([x, y, x+1, y+1], fill=c)


@jit
def save_files(index):
    mag = (100.0 - index) / 100
    filename = "map{:02d}.png".format(index)
    print(filename, mag)
    size = 512
    im = Image.new("RGB", (size, size))
    draw = ImageDraw.Draw(im)
    plot(draw, size, mag)
    im.save(filename)


for i in range(100):
    save_files(i)
