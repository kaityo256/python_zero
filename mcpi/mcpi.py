from random import random

def calc_pi(n):
    r = 0
    for _ in range(n):
        x = random()
        y = random()
        if x**2 + y**2 < 1.0:
            r += 1
    return 4 * r / n

print(calc_pi(10000))



