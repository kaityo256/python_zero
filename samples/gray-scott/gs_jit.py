import matplotlib.pyplot as plt
from numba import jit
import numpy as np

# python gs_jit.py  1.91s user 0.16s system 119% cpu 1.736 total


@jit
def laplacian(ix, iy, s):
    ts = 0.0
    ts += s[ix-1, iy]
    ts += s[ix+1, iy]
    ts += s[ix, iy-1]
    ts += s[ix, iy+1]
    ts -= 4.0*s[ix, iy]
    return ts


@jit
def calc(u, v, u2, v2):
    (L, _) = u.shape
    dt = 0.2
    F = 0.04
    k = 0.06075
    lu = np.zeros((L, L))
    lv = np.zeros((L, L))
    for ix in range(1, L-1):
        for iy in range(1, L-1):
            lu[ix, iy] = 0.05 * laplacian(ix, iy, u)
            lv[ix, iy] = 0.1 * laplacian(ix, iy, v)
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
