def p(n):
    r = 0.0
    for i in range(n):
        r += n/(i+1)
    return r

print(p(10))

