import matplotlib.pyplot as plt
import numpy as np
from scipy.signal import convolve2d

L = 64
F = 0.04
k = 0.06075
Du = 0.05
Dv = 0.1
dt = 0.2


def init(u, v):
    global L
    h = L//2
    for x in range(h-3, h+3):
        for y in range(h-3, h+3):
            u[x, y] = 0.7
    for x in range(h-6, h+6):
        for y in range(h-6, h+6):
            v[x, y] = 0.9

def calc(u, v, u2, v2):
    global L, Du, Dv, dt
    global F, k
    one = np.ones((L, L))
    laplacian = np.array([[0, 1, 0], [1, -4, 1], [0, 1, 0]])
    lu = Du*convolve2d(u, laplacian, mode="same")
    lv = Dv*convolve2d(v, laplacian, mode="same")
    cu = u[:]*u[:]*v[:] - (F+k)*u[:]
    cv = -u[:]*u[:]*v[:] + F*(one - v[:])
    u2[:] = u[:] + (lu[:]+cu[:]) * dt
    v2[:] = v[:] + (lv[:]+cv[:]) * dt


u = np.zeros((L, L))
u2 = np.zeros((L, L))
v = np.zeros((L, L))
v2 = np.zeros((L, L))
init(u, v)
for i in range(10000):
    if i % 2 == 0:
        calc(u, v, u2, v2)
    else:
        calc(u2, v2, u, v)
plt.imshow(u2, cmap="inferno")
plt.savefig("test.png")
