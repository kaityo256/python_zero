import random

trial = 100000
n = 0
for _ in range(trial):
    x = random.random()
    y = random.random()
    if x**2 + y**2 < 1.0:
        n += 1
print(n/trial*4.0)
