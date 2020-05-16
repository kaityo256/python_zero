import random
import sys

from PIL import Image, ImageDraw, ImageFont
import numpy as np

FONT_PATH = "/mnt/c/Windows/Fonts/"
fonts = []
fonts.append("NIS_R10N.ttc")
fonts.append("NIS_R10N.ttc")
fonts.append("NIS_SAI8N.ttc")


num_images = 10000
#num_images = 100
images = np.empty((num_images, 28, 28), dtype=np.uint8)

KANAS = "あいうえおかきくけこ"
chars = [ord(c) for c in list(KANAS)]

for i in range(num_images):
    img = Image.new('L', (28, 28))
    draw = ImageDraw.Draw(img)
    f = FONT_PATH+random.choice(fonts)
    draw.font = ImageFont.truetype(f, 26)
    theta = random.randint(-5, 5)
    kana = chr(random.choice(chars))
    x = random.randint(0, 2)
    y = random.randint(0, 2)
    draw.text((x, y), kana, (255))
    img = img.rotate(theta)
    nim = np.array(img)
    nim = nim.reshape((28, 28))
    images[i:] = nim
    sys.stdout.write('\r>> Generating image %d/%d' % (i + 1, num_images))
    sys.stdout.flush()
    if i < 100:
        filename = "test%04d.png" % i
        img.save(filename)

np.save("hiragana", images)
print(images.shape)
