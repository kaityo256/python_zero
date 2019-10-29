import matplotlib.cm as cm
import matplotlib.pyplot as plt

d_pop = {}

with open("population.csv") as f:
    for line in f:
        code, _, pop = line.split(",")
        d_pop[int(code)] = int(pop)

data = []
with open("position.csv") as f:
    for line in f:
        a = line.strip().split(",")
        if len(a) < 4:
            continue
        code, _, y, x = a
        code = int(code)
        x, y = float(x), float(y)
        if code in d_pop:
            data.append((x, y, d_pop[code]))

data = sorted(data, key=lambda x: x[2])

nx, ny, nn = [], [], []
for x, y, n in data:
    nx.append(x)
    ny.append(y)
    nn.append(n ** 0.5 * 0.3)
plt.figure(figsize=(15, 15), dpi=50)
plt.scatter(nx, ny, c=nn, s=nn, cmap=cm.seismic)
plt.savefig("test.png")
