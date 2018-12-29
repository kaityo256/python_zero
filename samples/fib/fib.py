def fib(k):
    if k in (0, 1):
        return k
    return fib(k-1) + fib(k-2)


def fib_memo(k, h):
    if k in (0, 1):
        return k
    if k in h:
        return h[k]
    h[k] = fib_memo(k-1, h) + fib_memo(k-2, h)
    return h[k]


def fib_linear(n):
    if n in (0, 1):
        return n
    f1 = 0
    f2 = 1
    fn = 0
    for _ in range(n-1):
        fn = f1+f2
        f1 = f2
        f2 = fn
    return fn


def test():
    n = 25
    print(fib(n))
    h = {}
    print(fib_memo(n, h))
    print(fib_linear(n))


test()
