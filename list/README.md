# リストとタプル

本講の目的。

* リストやタプルの扱いに慣れる
* リスト内包表記を使ってPythonらしく書く

## コッホ曲線の描画

### タプルのリスト

まずは変換ベクトルのリストの、始点と終点を結ぶベクトルの長さを求めよう。

```py
from math import sqrt
from PIL import Image, ImageDraw
import IPython
```

```py
def length(a):
    x, y = 0, 0
    for (dx, dy) in a:
        x += dx
        y += dy
    return sqrt(x**2 + y**2)
```

```py
a = [(1,1)]
print(length(a)) # => 1.4142135623730951
```

```py
a = [(1,0),(0,1)]
print(length(a)) # => 1.4142135623730951
```

```py
a = [(1,0),(0,1),(-1,-1)]
print(length(a))  #=> 0.0
```

確認が終わったら、テスト用のセル(`print`を含むもの)は削除して良い。

### タプルからリストを作成

```py
def convert(a, b):
    ax, ay = a
    alen = sqrt(ax**2+ay**2)
    c = ax/alen
    s = ay/alen
    scale = alen/length(b)
    r = []
    for (bx, by) in b:
        bx *= scale
        by *= scale
        nx = c * bx - s * by
        ny = s * bx + c*by
        r.append((nx, ny))
    return r
```

```py
a = (1,0)
b = [(1,1),(-1,1)]
convert(a,b) #=> [(0.5, 0.5), (-0.5, 0.5)]
```

```py
a = (0,1)
b = [(1,1),(-1,1)]
convert(a,b) #=> [(-0.5, 0.5), (-0.5, -0.5)]
```

```py
a = (1,1)
b = [(1,1),(-1,1)]
convert(a,b) #=> [(0.0, 1.0), (-1.0, 0.0)]
```

TODO: それぞれの図解

### タプルのリストそれぞれに適用

```py
def apply(a, b):
    r = []
    for i in a:
        r += convert(i, b)
    return r
```

```py
a = [(1,0)]
b = [(1,1),(-1,1)]
apply(a,b) # => [(0.5, 0.5), (-0.5, 0.5)]
```

```py
a = [(1,0),(0,1)]
b = [(1,1),(-1,1)]
apply(a,b) # => [(0.5, 0.5), (-0.5, 0.5), (-0.5, 0.5), (-0.5, -0.5)]
```

TODO: 図解

```py
a = [(1,0)]
b = [(1,1),(-1,1)]
for _ in range(2):
    a = apply(a,b)
print(a)
```

`range`の中の数字を増やしてみよ。

### 描画

```py
def draw_line(draw, a, s = (0,0)):
    x1, y1 = s
    for (dx, dy) in a:
        x2 = x1 + dx
        y2 = y1 + dy
        draw.line((x1, y1, x2, y2), fill=(255, 255, 255))
        x1, y1 = x2, y2
```

```py
size = 512
im = Image.new("RGB", (size, size))
draw = ImageDraw.Draw(im)
a = [(size, 0)]
b = [(1, 0), (0.5, sqrt(3.0)/2), (0.5, -sqrt(3.0)/2), (1, 0)]
for _ in range(1):
  a = apply(a, b)
draw_line(draw, a)
im.save("test.png")
IPython.display.Image("test.png")
```

`range`の数字を増やしてみよ。

入力として正三角形を与える。

```py
size = 512
im = Image.new("RGB", (size, size))
draw = ImageDraw.Draw(im)
sx = size/3 # 追加
sy = sx * sqrt(3) # 追加
a = [(sx,sy),(sx,-sy),(-2*sx,0)] # 修正
b = [(1, 0), (0.5, sqrt(3.0)/2), (0.5, -sqrt(3.0)/2), (1, 0)]
for _ in range(5):
  a = apply(a, b)
draw_line(draw, a, (size/6,size/4)) # 修正
im.save("test.png")
IPython.display.Image("test.png")
```

### 課題1

`b`のリストに好きなベクトル列を入れて、オリジナルのフラクタル曲線を作成せよ。

例えば、繰り返し数を`range(1)`としてから、

```py
b = [(1,0),(0,1),(1,0),(0,-1),(1,0)]
```

として描画し、繰り返し数を増やした場合にどんな図形になるか想像してみよ。想像した後に`range(5)`に変えて描画し、想像と合致していたか確認せよ。

## enumerateについて



### 課題2

```py
def draw_line_color(draw, a, c, s = (0,0)):
    x1, y1 = s
    clen = len(c)
    for i, (dx, dy) in enumerate(a):
        x2 = x1 + dx
        y2 = y1 + dy
        draw.line((x1, y1, x2, y2), fill=c[i%clen])
        x1, y1 = x2, y2
```

```py
size = 512
im = Image.new("RGB", (size, size))
draw = ImageDraw.Draw(im)
a = [(size, 0)]
b = [(1,0),(0,1),(1,0),(0,-1),(1,0)]
c = [(255,0,0)]
for _ in range(5):
    a = apply(a, b)
draw_line_color(draw, a, c)
im.save("test.png")
IPython.display.Image("test.png")
```

```py
c = [(255,0,0),(0,0,255)]
```

## Pythonらしく書く

TODO: リストの内包表記を使って描く

### 内包表記

リストの内包表記は「後ろから」読む。

```py
a = [1,2,3]
[2*x for x in a]
```

`[2*x for x in a]`は「aに含まれるxそれぞれを2*xにしたような新しいリストを作成してください」という意味になる。

```py
def convert(a, b):
    ax, ay = a
    alen = sqrt(ax**2+ay**2)
    c = ax/alen
    s = ay/alen
    scale = alen/length(b)
    r = []
    b = [(scale*x, scale*y) for (x,y)) in b]
    for (bx, by) in b:
        nx = c * bx - s * by
        ny = s * bx + c*by
        r.append((nx, ny))
    return r
```

```py
def convert(a, b):
    ax, ay = a
    alen = sqrt(ax**2+ay**2)
    c = ax/alen
    s = ay/alen
    scale = alen/length(b)
    b = [(scale*x, scale*y) for (x, y) in b]
    b = [(c * x - s* y, s *x + c * y) for (x, y) in b]
    return b
```

`bx, by`や`r`が消えた。

### reduce

reduceの説明と`lambda`の説明。

```py
def length(a):
  (x, y) = reduce(lambda x, y: (x[0]+y[0], x[1]+y[1]),a)
  return sqrt(x**2 + y**2)
```

```py
def apply(a, b):
  c = [convert(i, b) for i in a]
  return reduce(lambda x, y: x + y, c)
```