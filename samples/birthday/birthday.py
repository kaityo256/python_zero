def p(n):
    r = 1.0
    for i in range(n):
        r *= (365-i)/365
    return 1.0 - r

print(p(30))
