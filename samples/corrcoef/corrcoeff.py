try:
    import matplotlib
    matplotlib.use('Agg')
finally:
    from matplotlib import pyplot as plt

import numpy as np

with open("colortv.csv") as f:
    tv_year = []
    tv_data = []
    for line in f:
        y, d = line.split(",")
        tv_year.append(int(y))
        tv_data.append(float(d))
    plt.scatter(tv_year, tv_data)
    plt.savefig("colortv.png")

plt.clf()

with open("lifespan.csv") as f:
    life_year = []
    life_data = []
    for line in f:
        y, d = line.split(",")
        life_year.append(int(y))
        life_data.append(float(d))
    plt.scatter(life_year, life_data)
    plt.savefig("life.png")

plt.clf()

plt.scatter(tv_data, life_data)
plt.xlabel("TV")
plt.ylabel("Lifespan")
plt.savefig("life_tv.png")

ntv = np.array(tv_data)
nlife = np.array(life_data)
coef = np.corrcoef(ntv, nlife)[0][1]
print(coef)
