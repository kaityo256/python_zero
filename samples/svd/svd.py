from io import BytesIO
import urllib

from PIL import Image
import numpy as np
from scipy import linalg


def download(url):
    with urllib.request.urlopen(url) as wf:
        data = wf.read()
        return Image.open(BytesIO(data))


def mono(url):
    img = download(url)
    gray_img = img.convert('L')
    return gray_img


def svd(url, ratio):
    gray_img = mono(url)
    a = np.asarray(gray_img)
    w, _ = a.shape
    rank = int(w*ratio)
    u, s, v = linalg.svd(a)
    ur = u[:, :rank]
    sr = np.matrix(linalg.diagsvd(s[:rank], rank, rank))
    vr = v[:rank, :]
    b = np.asarray(ur*sr*vr)
    return Image.fromarray(np.uint8(b))


URL = "https://kaityo256.github.io/python_zero/numpy/stop.jpg"
ratio = 0.1
img = svd(URL, ratio)
img.save("output.jpg")
