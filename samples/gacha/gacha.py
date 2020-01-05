import random

N = 44
R = 100
prob = [0.0]*R
trial = 10000

for _ in range(trial):
    a = []
    n = 0
    for i in range(R):
        a.append(random.randint(1, N))
        if len(set(a)) > n:
            prob[i] = prob[i] + 1
            n = len(set(a))

for i in range(R):
    s = "{} {}".format(i, prob[i]/trial)
    print(s)
