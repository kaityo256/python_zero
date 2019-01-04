import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import convolve2d


def calc(u, v, u2, v2):
    dt = 0.2
    F = 0.04
    k = 0.06075
    laplacian = np.array([[0, 1, 0], [1, -4, 1], [0, 1, 0]])
    lu = 0.05*convolve2d(u, laplacian, mode="same")
    lv = 0.1*convolve2d(v, laplacian, mode="same")
    cu = u*u*v - (F+k)*u
    cv = -u*u*v + F*(1.0 - v)
    u2[:] = u + (lu+cu) * dt
    v2[:] = v + (lv+cv) * dt


def main():
    L = 64
    u = np.zeros((L, L))
    u2 = np.zeros((L, L))
    v = np.zeros((L, L))
    v2 = np.zeros((L, L))
    h = L//2
    u[h-3:h+3, h-3:h+3] = 0.7
    v[h-6:h+6, h-6:h+6] = 0.9
    for i in range(10000):
        if i % 2 == 0:
            calc(u, v, u2, v2)
        else:
            calc(u2, v2, u, v)
    return u


plt.imshow(main())
plt.savefig("test.png")
