import sympy


def f(n):
    return sum(sympy.divisors(n)) - n


def sociable(n):
    s = n
    a = []
    while n not in a and n != 1:
        a.append(n)
        if len(a) > 30:
            return
        n = f(n)
    if s == n and len(a) > 2:
        print(a)


for i in range(1, 100000):
    sociable(i)
