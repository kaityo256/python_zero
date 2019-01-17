# [乱数を使ったプログラム](https://kaityo256.github.io/python_zero/random/)

* 疑似乱数とモンテカルロ法
* 余談：疑似乱数とゲーム
* モンティ・ホール問題
* パーコレーション
* 余談：確率の難しさ

## 疑似乱数とモンテカルロ法

### 疑似乱数とは

乱数とは、ランダムな数のことである。例えばサイコロをふると、1から6までの数字がほぼ等確率で出ると期待される(実際には少しずれるらしい)。
さて、計算機でもランダムな数字が必要になることがある。例えばゲームで低確率で出る「会心の一撃」や「痛恨の一撃」を表現するのに乱数が必要だ。レアなモンスターを出現させるのも乱数が必要である。しかし、計算機において「真の乱数列」を表現するのは難しい。
「真の乱数列」とは、これまでの数列から、次の数字が予想できないような数列のことである。
現在の計算機は決定論的に動作するため、同じ入力を与えると同じ結果を出力する。
このような計算機で用いられる乱数は「疑似乱数」と呼ばれる。疑似乱数とは、一見乱数列のように見えるが実は規則性があり、
これまでの乱数列から次の乱数が予想できてしまうものだ。

以下のコードを書いて実行してみよう。

```py
import random

for i in range(10):
    print(random.randint(0,10))
```

実行するたびに結果が異なるだろう。しかし、以下のようにしてみよう。

```py
import random

random.seed(1)
for i in range(10):
    print(random.randint(0,10))
```

何度実行しても、同じ乱数列が得られることがわかるであろう。これは乱数の「種」を固定したためだ。
計算機は、漸化式により乱数列を作ることが多い。漸化式は、生成した乱数を入力として次の乱数を作る方法だが、
その一番最初に与える値を乱数の「種(seed)」と呼ぶ。同じ種からは同じ乱数列が生まれる。
これでは乱数としては不都合であるので、「現在時刻」を乱数の種とすることが多い。こうすると実行するたびに
異なる乱数列が得られる。しかし、主にデバッグ目的などで、毎回同じ乱数の種を与えたいときもある。
`random.seed`は、そのような場合に用いる。乱数列を作る方法には、線形合同法やM系列など様々な方法があるが、
現在広く使われているのはメルセンヌ・ツイスター法という手法である。多くのプログラム言語が乱数生成のデフォルトアルゴリズムとして
メルセンヌ・ツイスター法を採用している。ここでは触れないが興味がある人は調べてみよ。

### 余談：疑似乱数とゲーム

ゲームには乱数がつきものである。先に述べたように、どの敵が現れるか、攻撃が成功するか、失敗するかなど、全てランダムに決めたい。「はぐれメタル」などのレアなモンスターに、「会心の一撃」などのレアな攻撃が当たって興奮した、などの経験があるだろう。しかし、ゲームは計算機であり、計算機における乱数は疑似乱数である以上、理論上乱数は予想可能である。例えばあるゲームでは「ゲーム機が稼働開始してからの時間」を乱数の種に使っていたため、レアな敵が出たときにセーブしてリセットすると、全く同じ敵が現れてしまう、という仕様(バグ？)があった。これを利用してレアな敵を狩りまくり、貴重なアイテムを多数手に入れるという「技」があった。また、動画などを見ていて「TAS」という言葉を見かけたことはないだろうか。これは「Tool Assisted Speedrun」の略で、もともとゲームをエミュレータ上で実行し、理論上可能だが人間には不可能な速度でクリアすることを指したが、そのうちタイムアタック以外についてもTASと呼ばれるようになった。例えばTASによるRPGのタイムアタック動画では、「はぐれメタル」ばかり出て、それに「会心の一撃」ばかりあたるようなことが起きる。次にこういう動画を見るとき、一見無駄な動作が混ざっていないか注意してみてみよう。これは「乱数調整」といわれる手法である。例えばサイコロで「6」が出たら「会心の一撃」が出ることがわかっており、かつこれからのサイコロの目が「2,4,1,3,6」という順番であることもわかっている場合、戦闘の自分の番で「6」が出るように、事前にサイコロを振るのである。

疑似乱数とゲームといえば、面白いのが「質の悪い乱数」によるバグだろう。「カルドセプトサーガ」というXbox360のゲームがある。カルドセプトは、モノポリーのようなボードゲームに、マジック・ザ・ギャザリングのようなカードによるクリーチャー同士の戦いを組み合わせたようなゲームで、その戦略性から人気のあるシリーズであった。しかし「カルドセプトサーガ」は、サイコロの出目が非常に偏っており、例えば偶数と奇数が交互に出る問題があった。このようなサイコロゲームで、次の目が予想できるというのは致命的である。この問題が発覚したのち、ネットで「サイコロくらい簡単だろ」と「正しい」サンプルプログラムを書いた人がいたが、それもことごとくカルドセプトサーガと同じ過ちを犯していたそうである。「ネットに書き込む前に一呼吸」を意識しよう。

## モンテカルロ法

乱数を利用してシミュレーションをしたり、何かを計算したりする方法を「モンテカルロ法」と呼ぶ。
例えば金融市場をシミュレーションしたいとする。あるプレイヤーについて、ある状況である株を「買う」か「売る」かは判断できない。
しかし、「これまでの履歴」を調べることで、似たような状況で「買った」か「売った」かは知っているとする。
すると、ある状況で株を「買う確率」と「売る確率」を推定できる。同様に、別のプレイヤーについても「買う確率」と「売る確率」を
推定し、その確率に従って仮想的に株を売り買いさせることで、その株が今後どのような値動きをするかシミュレーションすることができる。
アメリカは軍の作戦を立案する際、相手と自分の様々な「手」をシミュレーションしていたそうである(今もシミュレーションしているかもしれない)。

モンテカルロ法は、数値積分にも用いられる。モンテカルロ法のによる数値積分で有名なのは、円周率の計算であろう。ダーツの要領でランダムに「矢」を投げ、当たった数で円周率を推定する方法である。n回ダーツを投げて円周率を推定するプログラムはこんな感じに書ける。

```py
from random import random

def calc_pi(n):
    r = 0
    for _ in range(n):
        x = random()
        y = random()
        if x**2 + y**2 < 1.0:
            r += 1
    return 4 * r / n

calc_pi(10000)
```

これは、実は以下のような二次元の数値積分をしていることと等価である。

$$
\pi \sim 4 \int_0^1 \int_0^1 \Theta(1-x^2-y^2) dx dy
$$

ただし$\Theta(x)$はステップ関数で、$x\geq 1$で1、そうでない場合は0となる関数である。

このアルゴリズムは簡単で、少ない試行回数でそこそこの精度が出るが、収束が悪いために円周率を高精度に求めるのには向かない。
そもそも単純なモンテカルロ法はあまり使われないので、もし「モンテカルロ法はいい加減」とか「精度が悪い」と思っているのなら
モンテカルロ法による円周率の推定については忘れてほしい。

モンテカルロ法による数値積分では、現在ではほとんど「マルコフ連鎖モンテカルロ法 (Markov-chain Monte Calro method, MCMC)という手法が用いられている。マルコフ連鎖モンテカルロ法は非常に重要な手法であるが、今回は触れない。

今回は、モンテカルロ法を使って様々なプログラムを組んでみよう。

## モンティ・ホール問題

モンティ・ホール問題とは、アメリカの番組の中で行われた、あるゲームに由来する。そのゲームとはこういうものである。

* 三つの箱が用意され、その中に一つだけ商品が入っており、残りの二つは空である。
* プレイヤーは、そのうちの一つを選ぶ
* 司会者は、選ばれなかった二つの箱の中身を確認し、空であるほうの箱を開ける
* その上で司会者はプレイヤーに「選んだ箱を変えてよい」という
* さて、プレイヤーは選んだ箱を変えたほうが得だろうか？それとも確率は変わらないだろうか？

![mh1.png](fig/mh1.png)
![mh2.png](fig/mh2.png)

この問題は有名なので、答えを知っている人も多いだろう。しかし、ここは答えを全く知らないとして、シミュレーションをしよう。

### Keep派

まずは、司会者が選ばれなかった箱のうち一つを開け、「選んだ箱を変えてよい」と言った時に「最初に選んだ箱を変えない」戦略を考えよう。
これをKeep派と呼ぶ。この人が当たる確率は自明に1/3だが、それっぽくシミュレーションしてみよう。以下、練習のため、かなり冗長なプログラムを組んでいることに留意されたい。

箱の中身のリストを渡されたときに、答えの箱と、プレイヤーの選ぶ箱をランダムに選ぶ関数`keep`を作ってみる。

```py
from random import choice, seed
```

```py
def keep(boxes):
    answer = choice(boxes)
    player_choice = choice(boxes)
    print(answer, player_choice)
```

`random.choice`とは、リストを与えられると、その中の要素をランダムに選ぶ関数である。
さて、適当な箱リストを与えて`keep`を呼んでみよう。

```py
seed(1)
boxes = ["A","B","C"]
for _ in range(10):
    keep(boxes)
```

このような結果が得られるはずである。

```sh
A C
A B
A B
B B
C B
A A
B A
B B
C A
C B
```

左が正解の箱、右がプレイヤーの選んだ箱である。では、正解を選んだ確率を計算してみよう。

まず、関数`keep`を、正解を選んだら`True`を返すように修正する。

```py
def keep(boxes):
    answer = choice(boxes)
    player_choice = choice(boxes)
    return player_choice == answer
```

次に、三番目のセルに、正解確率を計算する関数`calc_prob`を実装しよう。

```py
def calc_prob(n):
    seed(1)
    boxes = ["A","B","C"]
    k = 0
    for _ in range(n):
        if keep(boxes):
            k += 1
    print("Keep  : " + str(k/n))
```

四番目のセルに以下を入力して実行せよ。

```py
calc_prob(1000)
```

Keep派の正解確率が出てきたはずである。

ちなみに、ここでやったように部分的にコードを完成させ、そのたびに`print`で結果を確認する手法を **print文デバッグ** と呼ぶ。
print文デバッグはかなり古くからある手法であるが、デバッグの基本なので覚えておこう。

### Change派

さて、先ほどとは逆に「選んだ箱を変えてよい」と言った時に、必ず箱を変える戦略を考えよう。これをChange派と呼ぶ。
五番目のセルに、`change`を実装しよう。箱のリストを受け取り、正解と、プレイヤーが最初に選ぶ箱を決めるところまでは同じである。
さて、次に「司会者が開ける箱」を考える必要がある。司会者が開けるのは、プレイヤーが選んだ箱であっても、正解の箱あってもならない。
そこで、「箱リストから、プレイヤーが選んだ箱と、正解の箱を除外したリストを作り、そこからランダムに選ぶ」ことを考える。

```py
def change(boxes):
    answer = choice(boxes)
    player_choice = choice(boxes)
    boxes2 = list(filter(lambda x: x not in (player_choice, answer), boxes))
    print(answer, player_choice, boxes2)
```

6番目のセルにテストコードを書いて実行しよう。

```py
boxes = ["A","B","C"]
for _ in range(10):
  change(boxes)
```

種を固定していないため、実行するたびに異なるが、例えば以下のような結果が得られるはずだ。

```py
A A ['B', 'C']
C A ['B']
B A ['C']
B A ['C']
B C ['A']
C B ['A']
A A ['B', 'C']
A C ['B']
C A ['B']
B B ['A', 'C']
```

最初が正解の箱、二番目がプレイヤーの選んだ箱、三番目のリストが、司会者が開ける可能性のある箱である。司会者が開ける箱は、プレイヤーが選んだ箱でも、正解の箱でもないことに注意しよう。さて、`boxes2`から`choice`すれば、司会者が開ける箱が得られる。それを`chair_choice`としよう。
プレイヤーは、全部の箱のうち、「最初に自分が選んだ箱」でも、「司会者が開けた箱」でもないものを選ぶ。今回はそれは一つに決まるが、後の拡張のために。その候補リストを作ろう。先ほどの「司会者が開ける可能性の箱リスト」と同様に作ることができる。`change`を以下のように書き換えよ。

```py
def change(boxes):
    answer = choice(boxes)
    player_choice = choice(boxes)
    boxes2 = list(filter(lambda x: x not in (player_choice, answer), boxes))
    chair_choice = choice(boxes2)
    boxes3 = list(filter(lambda x: x not in (player_choice, chair_choice), boxes))
    print(player_choice, chair_choice, boxes3)
```

実行してみよう。

```sh
C A ['B']
B A ['C']
C A ['B']
B A ['C']
C A ['B']
B C ['A']
A B ['C']
A B ['C']
C A ['B']
B C ['A']
```

最初がプレイヤーが選んだ箱、次が司会者が開けた箱、最後が「プレイヤーが選択を変える箱の候補リスト」である。
それぞれに重複がないことを確認せよ。この「候補リスト」から`choice`したものがプレイヤーの最終選択である。

```py
def change(boxes):
    answer = choice(boxes)
    player_choice = choice(boxes)
    boxes2 = list(filter(lambda x: x not in (player_choice, answer), boxes))
    chair_choice = choice(boxes2)
    boxes3 = list(filter(lambda x: x not in (player_choice, chair_choice), boxes))
    player_choice = choice(boxes3)
    return player_choice == answer
```

先ほど作成した`calc_prob`を、Change派の確率も計算するように修正しよう。

```py
def calc_prob(n):
    seed(1)
    boxes = ["A","B","C"]
    k = 0
    c = 0
    for _ in range(n):
        if keep(boxes):
            k += 1
        if change(boxes):
            c += 1
    print("Keep  : " + str(k/n))
    print("Change: " + str(c/n))
```

以下を実行してみよ。

```py
calc_prob(10000)
```

Keep派とChange派、どちらが正解確率が高いだろうか？

### 課題1: 箱が４つの場合

`calc_prob`の中で定義している`boxes`を、`boxes = ["A","B","C", "D"]`とすると、箱が4つバージョンのモンティ・ホール問題となる。
この場合は、

* 4つ箱が用意され、一つだけ正解の箱がある
* プレイヤーは最初に一つ箱を選ぶ
* 司会者は、プレイヤーが選んでいない箱の中から、正解でない箱を一つランダムに開ける
* プレイヤーは最初に選んだ箱から、残りの箱のどれかに選択を変更することができる

というルールとなる。さて、Keep派とChange派、どちらが得かはもうわかるだろうが、どちらがどれだけ得か、理論計算できるだろうか？
まず理論計算してから、実際にシミュレーションし、予想が当たっていたか考察せよ。

## パーコレーション

![percolation.png](fig/percolation.png)

札幌の市街のような、碁盤の目のような道路があるとしよう。ところがある日、大雪が降って、道がところどころ通行止めになってしまった。いま、道が通行可能な確率をpとしよう。通行可能な道だけを通って「こっち側」から「向こう側」に渡れる確率(Crossing Probability)$C$を知りたい。渡れる確率$C$は確率pの関数となる。当然、$p$が小さければ渡れる確率は低く、大きければ渡れる確率は高くなると思われるが、どんな関数になるか想像できるだろうか？

いま、正方格子の「辺」を通ることを考えたが、これはボンド・パーコレーションと呼ばれるモデルとなる。同様に、正方形に区切られたパネルがあるとする。その区画が、確率$p$で通行可能、$1-p$で通行不可だとしよう。通行人は、かつ上下左右につながった、通行可能なパネルのみ渡ることができる。「こちら側」から「向こう側」にわたることができる確率は、pに対してどう振る舞うだろうか？こちらはサイト・パーコレーションと呼ばれるモデルである。

この「向こう岸に渡れる確率」だが、十分大きなシステムでは、「$p$がある臨界値$p_c$未満ではほぼ確実に渡ることができず、$p_c$より大きければほぼ確実に渡ることができる」という振る舞いを見せる。つまり、系の振る舞いがパラメータのある一点を境に大きく変化する。このように、あるパラメータを変化させていったときに、ある点で系の性質が大きく変化することを **相転移(Phase Transigion)** と呼ぶ。パーコレーションは、相転移を示す最も簡単なモデルのひとつだ。身近な相転移としては、水の沸騰などが挙げられる。水を一気圧の条件で温度を徐々に挙げていくと、摂氏100度で沸騰し、水蒸気になる。水も水蒸気も水分子から構成されており、それは全く変化していない。しかし、水分子の集団としての振る舞いが大きく変化するのである。0度以下に冷やすと凍るのも相転移である。

TODO: 相転移の説明の図

ここでは、サイト・パーコレーションについてシミュレーションしてみよう。

### 状態の生成

正方格子上に確立$p$で「玉」をばらまくプログラムを作ろう。それぞれの要素が確率$p$で`True`、そうでない場合は`False`となるような二次元のリストを作る。

まずは必要なモジュールをインポートしよう。最初のセルに以下を入力せよ。

```py
import random
import IPython
from PIL import Image, ImageDraw
```

次に、一辺のサイズ(`size`)と確率(`p`)を受け取り、それぞれのサイトに確率$p$で玉をばらまくような関数`make_lattice`を作る。以下を二番目のセルに入力せよ。

```py
def make_lattice(size, p):
    lattice = [[False] * size for _ in range(size)]
    for x in range(size):
        for y in range(size):
            lattice[x][y] = random.random() < p
    return lattice
```

動作確認してみよう。三番目のセルに以下を入力、実行してみよ。

```py
make_lattice(2,0.5)
```

実行するたびに結果が異なるが、例えばこんな結果が得られるはずだ。

```py
[[False, True], [False, True]]
```

2x2の二次元配列で、各要素が確率0.5で`True`になっていると思う。ここで安心して次に行かず、
確率を0にしたら必ず`False`だけに、1にしたらかならず`True`だけになることも確認しておこう。

```py
make_lattice(4,0)
make_lattice(4,1)
```

極端な入力値(ここでは0や1)について振る舞いがよくわかっている場合、そこを確認するのは極めて重要である。ここでテストをおざなりにする人は、ちゃんとテストする人に比べて生産性に桁で違いが出てしまう。プログラムを書いたら、しつこいほどテストをしよう。

さて、`make_lattice`のテストが完了したら、三番目のテスト用のセルは削除して良い。

### 状態の描画

二次元正方格子にランダムに「玉」をばらまいた。ではそれを可視化してみよう。

三番目、四番目のセルに以下のプログラムを入力せよ。

```py
def draw_sites(lattice, g, draw):
    size = len(lattice)
    for x, row in enumerate(lattice):
        for y, site in enumerate(row):
            if not site:
                continue
            ix = x * g
            iy = y * g
            pos = (ix+1, iy+1, ix+g-1, iy+g-1)
            draw.ellipse(pos, fill=(255,0,0))
```

```py
def draw_all(lattice):
    size = len(lattice)
    g = 16
    s = size * g
    im = Image.new("RGB", (s, s), (255, 255, 255))
    draw = ImageDraw.Draw(im)
    black = (0, 0, 0)
    draw.rectangle((0, 0, s-1, s-1), outline=black)
    for i in range(size):
        draw.line((0, i*g, s, i*g), fill=black)
        draw.line((i*g, 0, i*g, s), fill=black)
    draw_sites(lattice, g, draw)
    im.save("test.png")
```

入力できたら、五つ目のセルに以下を入力し、実行してみよ。

```py
size = 32
lattice = make_lattice(size, 0.5)
draw_all(lattice)
IPython.display.Image("test.png")
```

正しく入力されていれば、32x32の正方格子に、確率0.5で赤い玉がばらまかれたはずである。実行するたびに形が変わるので見てみよう。

### 色の描画

さて、この後「上下左右に隣接したセルは同じグループとして、同じグループは同じ色に塗る」という処理をするのだが、その前に色を塗る処理だけ先に作っておこう。
このグループは「クラスター」と呼ばれる。よくネット上で同じ趣味を持つ仲間を「○○クラスタ」などと言うが、あのクラスターである。
この同じグループは同じクラスターに属すとして、クラスター番号を得る処理を作ろう。

今、セルは以下のようになっているはず。

1. import
2. make_lattice
3. draw_sites
4. draw_all
5. IPython.display.Image

この状態で、二つ目と三つ目のセルの間に新たにセルを作り、以下のようなコードを入力せよ。

```py
def get_cluster_index(i, cluster_index):
    while cluster_index[i] != i:
        i = cluster_index[i]
    return i
```

これが何をする関数かは後で説明する。これで、セルはこうなった。

1. import
2. make_lattice
3. get_cluster_index
4. draw_sites
5. draw_all
6. IPython.display.Image

この状況で、`draw_sites`に、引数として`cluster_index`というリストを受け取るように修正しよう。

```py
def draw_sites(lattice, g, draw, cluster_index): # 引数追加
    size = len(lattice)
    colors = [(255, 0, 0), (0, 255, 0), (0, 0, 255)
      , (255, 255, 0), (255, 0, 255), (0, 255, 255)] # 追加
    for x, row in enumerate(lattice):
        for y, site in enumerate(row):
            if not site:
                continue
            ix = x * g
            iy = y * g
            ci = x + y * size   # 追加
            c = get_cluster_index(ci, cluster_index) # 追加
            c = c % 6 # 追加
            pos = (ix+1, iy+1, ix+g-1, iy+g-1)
            draw.ellipse(pos, fill=colors[c]) # 修正
```

また、`draw_all`も、`cluster_index`を受け取り、それをそのまま`draw_sites`に渡すように修正しよう。

```py
def draw_all(lattice, cluster_index): # 引数追加
    size = len(lattice)
    g = 16
    s = size * g
    im = Image.new("RGB", (s, s), (255, 255, 255))
    draw = ImageDraw.Draw(im)
    black = (0, 0, 0)
    draw.rectangle((0, 0, s-1, s-1), outline=black)
    for i in range(size):
        draw.line((0, i*g, s, i*g), fill=black)
        draw.line((i*g, 0, i*g, s), fill=black)
    draw_sites(lattice, g, draw, cluster_index) # 修正
    im.save("test.png")
```

この状態で、六つ目のセルを以下のように修正、実行してみよう。

```py
size = 32
lattice = make_lattice(size, 0.5)
cluster_index = list(range(size*size)) # 追加
draw_all(lattice, cluster_index) # 修正
IPython.display.Image("test.png")
```

それぞれの玉に色がついたはずである。

### Union-Findアルゴリズム

TODO: Union-Findの説明

現在、セル状況はこうなっている。

1. import
2. make_lattice
3. get_cluster_index
4. draw_sites
5. draw_all
6. IPython.display.Image

この三つ目と四つ目のセルの間に、以下を入力しよう。

```py
def connect(i, j, lattice, cluster_index):
    size = len(lattice)
    (ix, iy) = i
    (jx, jy) = j
    if size in (ix, iy, jx, jy):
        return
    if not lattice[ix][iy]:
        return
    if not lattice[jx][jy]:
        return
    ci = ix + iy * size
    cj = jx + jy * size
    ci = get_cluster_index(ci, cluster_index)
    cj = get_cluster_index(cj, cluster_index)
    if ci > cj:
        ci, cj = cj, ci
    cluster_index[cj] = ci
```

```py
def clastering(lattice, cluster_index):
    size = len(lattice)
    for x in range(size):
        for y in range(size):
            connect((x, y), (x+1, y), lattice, cluster_index)
            connect((x, y), (x, y+1), lattice, cluster_index)
```

セル状況はこうなったはずである。

1. import
2. make_lattice
3. get_cluster_index
4. connect
5. clastering
6. draw_sites
7. draw_all
8. IPython.display.Image

番号がよくわからなくなったら、「ランタイム」から「再起動してすべてのセルを実行」を実行せよ。

8番目のセルを以下のように修正せよ。

```py
size = 32
lattice = make_lattice(size, 0.5)
cluster_index = list(range(size*size))
clastering(lattice, cluster_index) # 追加
draw_all(lattice, cluster_index)
IPython.display.Image("test.png")
```

ここまで正しく入力できていれば、上下左右に隣接した「玉」が同じ色で塗られたはずである。

### 相転移の確認

TODO: Crossing Probabilityの計算

## 余談：確率の難しさ

確率が絡んだ問題は、時として直観と合わない結果を生む。そんな問題は(厳密にはパラドックスではないが)パラドックスと呼ばれる。
有名なのは「誕生日のパラドックス」であろう。今、うるう年は考えず、一年が365日だとしよう。また、誕生日は一様であるとする。
さて、30人いるクラスで、誕生日が同じペアが存在する確率はどのくらいだろうか？
ちょっと想像してから、こんなコードを書いて確認してみよう。

```py
def p(n):
    r = 1.0
    for i in range(n):
        r *= (365-i)/365
    return 1.0 - r

p(30)
```

思ったより大きかったのではないだろうか？逆に、直観より確率が小さいことを「悪用」する例としては「コンプガチャ」と呼ばれる景品がある。
これは「絵合わせ」もしくは「カード合わせ」と呼ばれる古典的なギャンブルであり、

* 複数種類の絵柄のあるカードがあり、お金を払うとそのどれかがランダムで手に入る
* 複数の絵柄をすべて揃えたら、景品が当たる

というものである。例えば、カードが10種類あり、一枚100円とする。全種類揃えるのに必要な経費の期待値はどのくらいか、すぐにわかるだろうか？
やはり少し想像してから計算してみよう。

```py
def p(n):
    r = 0.0
    for i in range(n):
        r += n/(i+1)
    return r

p(10)
```

「10種類ある絵柄が等確率で当たり、10種類揃えたら景品を渡す」という文面に嘘がなく、確率操作などをせずその通りに実施するとしても、これは違法となる。なぜ違法とすべきなのか、考えてみると面白いであろう。

モンティ・ホール問題でも、直観と乖離した結果に多くの人が騙された。間違った人々の中には数学者もいて、新聞に意見を投書して紹介され、のちに恥をかいたようだ。現在はネット社会であり、何か肩書を持った人が間違ったことを言うと多くの人の目に触れ、昔より炎上しやすい。この問題が教えてくれる本当の教訓は「何か発言するときは気を付けよう」ということかもしれない。