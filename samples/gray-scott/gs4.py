import matplotlib.pyplot as plt
import numpy as np

L = 32
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
            u[x+y*L] = 0.7
    for x in range(h-6, h+6):
        for y in range(h-6, h+6):
            v[x+y*L] = 0.9


def laplacian(ix, iy, s):
    ts = 0.0
    ts += s[ix-1+iy*L]
    ts += s[ix+1+iy*L]
    ts += s[ix+(iy-1)*L]
    ts += s[ix+(iy+1)*L]
    ts -= 4.0*s[ix+iy*L]
    return ts


def calcU(tu, tv):
    global F, k
    return tu * tu * tv - (F+k)*tu


def calcV(tu, tv):
    global F, k
    return -tu*tu*tv + F * (1.0 - tv)


def calc(u, v, u2, v2):
    global L, Du, Dv, dt
    for iy in range(1, L-1):
        for ix in range(1, L-1):
            du = Du * laplacian(ix, iy, u)
            dv = Dv * laplacian(ix, iy, v)
            du += calcU(u[ix+iy*L], v[ix+iy*L])
            dv += calcV(u[ix+iy*L], v[ix+iy*L])
            u2[ix+iy*L] = u[ix+iy*L] + du*dt
            v2[ix+iy*L] = v[ix+iy*L] + dv*dt


u = [0.0]*(L*L)
u2 = [0.0]*(L*L)
v = [0.0]*(L*L)
v2 = [0.0]*(L*L)
init(u, v)
for i in range(1000):
    if i % 2 == 0:
        calc(u, v, u2, v2)
    else:
        calc(u2, v2, u, v)

plt.imshow(np.array(u).reshape((L,L)), cmap="inferno")
plt.savefig("test.png")
