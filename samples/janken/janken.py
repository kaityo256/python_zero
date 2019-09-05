import random

trial = 100000
N = 6
aiko = 0
for _ in range(trial):
    a = [random.choice(['G', 'C', 'P']) for _ in range(N)]
    if len(set(a)) in (1, 3):
        aiko += 1
print(aiko/trial)
