# 中置記法から逆ポーランド記法への変換
def convert(code):
    data = code.split()
    stack = []
    buffer = []
    for x in data:
        if x in ('+', '-'):
            if not stack:
                stack.append(x)
            else:
                while stack and (stack[-1] in '*', '/'):
                    buffer.append(stack.pop())
                stack.append(x)
        elif x in ('*', '/'):
            stack.append(x)
        else:
            buffer.append(x)
    while stack:
        buffer.append(stack.pop())
    return " ".join(buffer)


# 逆ポーランド記法に変換してから計算を実行
def calc(code):
    code = convert(code)
    data = code.split()
    stack = []
    for x in data:
        print(stack, x, end=" => ")
        if x == '+':
            b = stack.pop()
            a = stack.pop()
            stack.append(a+b)
        elif x == '-':
            b = stack.pop()
            a = stack.pop()
            stack.append(a-b)
        elif x == '*':
            b = stack.pop()
            a = stack.pop()
            stack.append(a*b)
        elif x == '/':
            b = stack.pop()
            a = stack.pop()
            stack.append(a//b)
        else:
            stack.append(int(x))
        print(stack)
    print(stack.pop())


calc("1 + 2")
calc("1 + 2 * 3 + 4")
