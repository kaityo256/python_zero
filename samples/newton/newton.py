from PIL import Image, ImageDraw


def newton(x):
    for _ in range(10):
        x = x - (x**3 - 1.0)/(3*x**2)
    return x


def plot(draw, s):
    hs = s/2
    red = (255, 0, 0)
    green = (0, 255, 0)
    blue = (0, 0, 255)
    for x in range(s):
        for y in range(s):
            z = complex(x-hs, y-hs)/s*4 + 0.01
            z = newton(z)
            c = red
            if z.real < 0.0:
                if z.imag < 0.0:
                    c = green
                else:
                    c = blue
            draw.rectangle([x, y, x+1, y+1], fill=c)


size = 512
im = Image.new("RGB", (size, size))
draw = ImageDraw.Draw(im)
plot(draw, size)
im.save("test.png")
