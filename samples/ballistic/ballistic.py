from math import cos, pi, sin

import matplotlib
import matplotlib.pyplot as plt
import numpy as np

matplotlib.use('Agg')


def run(theta):
    x, y = 0.0, 0.0
    vx, vy = cos(theta), sin(theta)
    ax, ay = [], []
    g = 1.0
    dt = 0.01
    while y >= 0.0:
        x += vx * dt
        y += vy * dt
        vy -= g*dt
        ax.append(x)
        ay.append(y)
    nx = np.array(ax)
    ny = np.array(ay)
    return nx, ny


nx, ny = run(pi*0.25)
plt.plot(nx, ny, label=1)
nx, ny = run(pi*0.25+0.1)
plt.plot(nx, ny, label=2)
nx, ny = run(pi*0.25-0.1)
plt.plot(nx, ny, label=3)
plt.legend()
plt.savefig("test.png")
