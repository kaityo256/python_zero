import matplotlib.pyplot as plt
import numpy as np

loop = 1000
loop2 = 900
rs, re = 1.0, 3.0
n = 1000
x = []
y = []
for i in range(n):
    r = (re-rs)*i/n + rs
    v = 0.1
    for j in range(loop):
        v = r*v*(1.0-v)
        if j > loop2:
            x.append(r)
            y.append(v)

nx = np.array(x)
ny = np.array(y)
plt.scatter(nx, ny, s=0.1)
plt.savefig("test.png")
