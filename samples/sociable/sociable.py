import sympy


# fastest
def f(n):
    return sum(sympy.divisors(n)) - n


# O(sqrt(N))
def f1(n):
    s = 0
    for i in range(1, int(n**0.5)+1):
        if n % i == 0:
            s += i
            if i != n // i:
                s += n//i
    return s - n


# O(N)
def f2(n):
    s = 0
    for i in range(1, n//2+1):
        if n % i == 0:
            s += i
    return s


# List up perfect numbers up to n
def perfect(n):
    print("Perfect Numbers")
    for i in range(1, n+1):
        if i == f(i):
            print(i)


# List up amicable numbers up to n
def amicable(n):
    print("Amicable Numbers")
    for i in range(1, n + 1):
        if i == f(i):
            continue
        if i == f(f(i)):
            print(i, f(i))


# check wether n is a sociable number
def is_sociable(n):
    s = n
    a = []
    while n not in a and n != 1:
        a.append(n)
        if len(a) > 30:
            return
        n = f(n)
    if s == n and len(a) > 2:
        print(a)


# List up sociable numbers up to n
def sociable(n):
    print("Sociable Numbers")
    for i in range(1, n):
        is_sociable(i)


perfect(10000)
amicable(10000)
sociable(100000)
