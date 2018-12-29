

def fib(k):
    if k in (0, 1):
        return k
    return fib(k-1) + fib(k-2)

# %time fib(34)

def fib_memo(k, h):
    if k in (0, 1):
        return k
    if k in h:
        return h[k]
    h[k] = fib_memo(k-1, h) + fib_memo(k-2, h)
    return h[k]

# h = {}
# %time fib_memo(34)
