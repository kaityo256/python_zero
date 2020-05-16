import os
import random
import sys

from PIL import Image, ImageDraw, ImageFont
import numpy as np

FONT = "./ipag.ttf"

if not os.path.exists(FONT):
    print("Could not find a font file %s." % FONT)
    print("Please down load from")
    print("https://ipafont.ipa.go.jp/old/ipafont/download.html")
    sys.exit()

num_images = 10000
#num_images = 100
images = np.empty((num_images, 28, 28), dtype=np.uint8)

kanas = "あいうえおかきくけこ"
chars = [ord(c) for c in list(kanas)]

for i in range(num_images):
    img = Image.new('L', (28, 28))
    draw = ImageDraw.Draw(img)
    draw.font = ImageFont.truetype(FONT, 28)
    x = random.randint(-2, 2)
    y = random.randint(-2, 2)
    theta = random.randint(-5, 5)
    kana = chr(random.choice(chars))
    draw.text((x, y), kana, (255))
    draw.text((x+1, y), kana, (255))
    draw.text((x, y+1), kana, (255))
    draw.text((x+1, y+1), kana, (255))
    img = img.rotate(theta)
    nim = np.array(img)
    nim = nim.reshape((28, 28))
    images[i:] = nim
    sys.stdout.write('\r>> Generating image %d/%d' % (i + 1, num_images))
    sys.stdout.flush()
    #filename = "test%04d.png" % i
    #img.save(filename)

np.save("hiragana", images)
print(images.shape)
