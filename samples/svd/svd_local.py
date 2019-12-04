from io import BytesIO
import pathlib

from PIL import Image
import numpy as np
from scipy import linalg


def mono(filename):
    img = Image.open(filename)
    gray_img = img.convert('L')
    return gray_img


def svd(filename, ratio):
    gray_img = mono(filename)
    a = np.asarray(gray_img)
    w, _ = a.shape
    rank = int(w*ratio)
    u, s, v = linalg.svd(a)
    ur = u[:, :rank]
    sr = np.matrix(linalg.diagsvd(s[:rank], rank, rank))
    vr = v[:rank, :]
    b = np.asarray(ur*sr*vr)
    sr = np.vectorize(lambda x: x**0.5)(sr)
    ur = ur * sr
    vr = sr * vr 
    Image.fromarray(np.uint8(ur)).save("ur.jpg")
    Image.fromarray(np.uint8(vr)).save("vr.jpg")
    return Image.fromarray(np.uint8(b))


def main():
    path = "stop.jpg"
    img = mono(path)
    img.save("stop_mono.jpg")
    ratio = 0.1
    img = svd(path, ratio)
    img.save("stop_svd.jpg")


if __name__ == '__main__':
    main()
