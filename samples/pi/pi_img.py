import random

from PIL import Image, ImageDraw

size = 256
trial = 100
im = Image.new("RGB", (size, size), 'white')
draw = ImageDraw.Draw(im)
draw.ellipse((-size, -size, size, size),
             fill='white', outline='black')

for _ in range(trial):
    x = random.random()
    y = random.random()
    s = 4
    color = 'red'
    if x**2 + y**2 > 1.0:
        color = 'blue'
    x *= size
    y *= size
    draw.ellipse((x-s, y-s, x+s, y+s), outline='black', fill=color)

im.save("test.png")
