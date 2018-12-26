from math import cos, pi, sin

from PIL import Image, ImageDraw

im = Image.new("RGB", (256, 256))
draw = ImageDraw.Draw(im)
cx = 128
cy = 128
r = 64
draw.ellipse((cx - r, cy - r, cx + r, cy + r), outline=(255, 255, 255))
n = 5
t = 2.0 * pi / n * (n // 2)
for i in range(n):
    s1 = t * i
    s2 = s1 + t
    x1 = r * cos(s1) + cx
    y1 = r * sin(s1) + cy
    x2 = r * cos(s2) + cx
    y2 = r * sin(s2) + cy
    draw.line((x1, y1, x2, y2), fill=(255, 255, 255))

im.save("test.png")
