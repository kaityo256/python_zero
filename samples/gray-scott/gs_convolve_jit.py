import matplotlib.pyplot as plt
from numba import jit
import numpy as np
from scipy.signal import convolve2d

# python gs_convolve_jit.py  4.55s user 0.18s system 108% cpu 4.357 total


@jit
def calc(u, v, u2, v2):
    dt = 0.2
    F = 0.04
    k = 0.06075
    laplacian = np.array([[0, 1, 0], [1, -4, 1], [0, 1, 0]])
    lu = 0.1*convolve2d(u, laplacian, mode="same")
    lv = 0.05*convolve2d(v, laplacian, mode="same")
    cu = -v*v*u + F*(1.0 - u)
    cv = v*v*u - (F+k)*v
    u2[:] = u + (lu+cu) * dt
    v2[:] = v + (lv+cv) * dt


@jit
def main():
    L = 64
    u = np.zeros((L, L))
    u2 = np.zeros((L, L))
    v = np.zeros((L, L))
    v2 = np.zeros((L, L))
    h = L//2
    u[h-6:h+6, h-6:h+6] = 0.9
    v[h-3:h+3, h-3:h+3] = 0.7
    for i in range(10000):
        if i % 2 == 0:
            calc(u, v, u2, v2)
        else:
            calc(u2, v2, u, v)
    return v


plt.imshow(main())
plt.savefig("gs.png")
