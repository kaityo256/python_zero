# 文字列処理：課題

## 課題1：形態素解析

ウェブから情報を取得し、解析してみよう。ここでは「[青空文庫](https://www.aozora.gr.jp/)」からテキストを取得し、そのテキストを解析してみる。青空文庫は著作権が消滅した作品か、著者が許諾している作品のテキストをウェブ上に公開している電子図書館である。

具体的な作業は以下の通りである。

* 青空文庫から、zipファイルをダウンロードする
* zipファイルを展開し、文字コードを変換する
* MeCabを使って形態素解析し、一般名詞のみを取り出す
* 一般名詞の頻度分布を取得し、利用頻度トップ10を出力する

このようにウェブから何か情報を抽出する技術を **ウェブスクレイピング (Web scraping)**と呼ぶ。今回の作業は、ウェブスクレイピングのうちもっとも単純なものである。

**注意**：ウェブスクレイピングは、相手のサーバに負担がかからないように注意しながら行うこと。例えば「指定のパス以下のファイルをすべて取得する」といった作業は厳禁である。また、利用規約によってそもそもウェブスクレイピングが禁止されているサービスもある(例えばTwitterなど)。その場合はサービスが提供しているAPIを通じて情報を取得することが多い。

### 課題1-1：MeCabのインストール

#### 最初のセル

まず、Debianのパッケージ管理ソフトウェアであるaptitudeをインストールする。新しいPython3ノートブックを開き、最初のセルに以下を入力、実行せよ。冒頭の「!」を忘れないこと。

```py
!apt install aptitude
```

最後に「Processing triggers for libc-bin (2.27-3ubuntu1) ...」などと表示され、実行が終了したら完了である。

次に、先程インストールしたaptitudeを使ってMeCabと必要なライブラリをインストールする。最後の`-y`を忘れないように。

#### 二つ目のセル

```py
!aptitude install mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file -y
```

出力の最後に

```sh
done!
Setting up mecab-jumandic (7.0-20130310-4) ...
```

などと表示されれば完了である。

#### 三つ目のセル

最後に、MeCabのPythonバインディングをインストールする。

```sh
!pip install mecab-python3==0.7
```

最新版は不具合があるようなので、バージョン0.7を指定してインストールする。

```sh
Successfully installed mecab-python3-0.7
```

と表示されれば完了である。

#### 四つ目のセル

先程まででインストールしたライブラリを早速importしてみよう。

```py
import MeCab
```

これを実行してエラーがでなければインストールに成功している。

#### 五つ目のセル

次のセルに以下を入力してみよう。

```py
m = MeCab.Tagger()
print(m.parse ("すもももももももものうち"))
```

以下のような実行結果が得られるはずである。

```txt
すもも   名詞,一般,*,*,*,*,すもも,スモモ,スモモ
も      助詞,係助詞,*,*,*,*,も,モ,モ
もも    名詞,一般,*,*,*,*,もも,モモ,モモ
も      助詞,係助詞,*,*,*,*,も,モ,モ
もも    名詞,一般,*,*,*,*,もも,モモ,モモ
の      助詞,連体化,*,*,*,*,の,ノ,ノ
うち    名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
EOS
```

### 課題1-2：青空文庫からのデータ取得

ノートブックの上のメニューから「編集」「すべてのセルを選択」を実行し、その後「編集」「選択したセルを削除」を実行することで、全てのセルを削除せよ。この状態でもMeCabはインストールされたままである。

#### 最初のセル

「+コード」をクリックして現れた最初のセルに、以下を入力、実行せよ。

```py
from collections import defaultdict
import re
import io
import urllib.request
from zipfile import ZipFile
import MeCab
```

#### 二つ目のセル

次のセルに、ウェブからデータを取得する関数`load_from_url`を以下のように実装せよ。

```py
def load_from_url(url):
    data = urllib.request.urlopen(url).read()
    zipdata = ZipFile(io.BytesIO(data))
    filename = zipdata.namelist()[0]
    text = zipdata.read(filename).decode("shift-jis")
    text = re.sub(r'［.+?］', '', text)
    text = re.sub(r'《.+?》', '', text)
    return text
```

ここで、正規表現に入力するカギカッコは、それぞれ`［］`全角の角カッコと、`《》`全角の二重山括弧であることに注意。どちらも日本語入力モードで`「`や`」`を変換すると候補に出てくると思われる。ここで出てくる正規表現の意味は、「全角の角カッコや二重山括弧に囲まれた文字列を削除せよ」である。それぞれ注釈やルビに対応する。

#### 三つ目のセル

`load_from_url`を実装して実行したら、以下を入力、実行せよ。

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/624_ruby_5668.zip"
text = load_from_url(URL)
text.split()[0]
```

以下のようにタイトルが出力されれば成功である。

`山月記`

これは、中島敦という作家の「山月記」という小説である。

### 課題1-3：形態素解析

ではいよいよ形態素解析をしてみよう。といってもMeCabを使えば楽勝である。

#### 四つ目のセル

MeCabを使って、文中に出現する名詞の出現頻度トップ10を抽出してみよう。四つ目のセルに以下を入力せよ。

```py
def show_top10(text):
    m = MeCab.Tagger()
    node = m.parseToNode(text)
    dic = defaultdict(int)
    while node:
        a = node.feature.split(",")
        key = node.surface
        if a[0] == u"名詞" and a[1] == u"一般":
            dic[key] += 1
        node = node.next
    for k, v in sorted(dic.items(), key=lambda x: -x[1])[0:10]:
        print(k + ":" + str(v))
```

#### 五つ目のセル

テキストをダウンロードし、形態素解析をしてみよう。五つ目のセルに以下を入力、実行せよ。

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/624_ruby_5668.zip"
text = load_from_url(URL)
show_top10(text)
```

文章に使われている一般名詞の頻度トップ10が、回数とともに出力されたはずである。

#### 六つ目のセル

別の作品も見てみよう。同じく中島敦の「名人伝」で同様な解析をしてみよう。六つ目のセルに以下を入力せよ。五つ目のセルの内容をコピペして、URLのみ修正すると楽である。

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/621_ruby_661.zip"
text = load_from_url(URL)
show_top10(text)
```

読んだことがなくても、なんとなくどんな作品なのかがわかるであろう。

## 課題2：ワードクラウド

### 課題2-1：ワードクラウドの表示

先程得られた単語リストを使って、青空文庫のワードクラウドを作ってみよう。

まずは新しいPython3ノートブックを開く。この時、先程作成したノートブックを別のタブで開いておくといろいろ楽になる。

#### 最初のセル

最初のセルに以下を入力、実行すること、

```py
!apt install aptitude
!aptitude install mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file -y
!pip install mecab-python3==0.7
!apt-get -y install fonts-ipafont-gothic
```

形態素解析エンジンであるMeCabの他に、日本語表示のためのフォント(IPAゴシック)のインストールが追加されている。

#### 二つ目のセル

無事にインストールされたら、次のセルで必要なモジュールをインポートしよう。

```py
import io
import re
import urllib.request
from zipfile import ZipFile

import IPython
import MeCab
from wordcloud import WordCloud
```

正しくインストールされていれば、エラーなくインポートできるはずだ。

#### 三つ目のセル

三つ目のセルに、URLを指定してZipファイルをダウンロード、展開し、不要な部分を削除する`load_from_url`を実装しよう。先程書いたものと全く同じなので、コピペしてかまわない。

```py
def load_from_url(url):
    data = urllib.request.urlopen(url).read()
    zipdata = ZipFile(io.BytesIO(data))
    filename = zipdata.namelist()[0]
    text = zipdata.read(filename).decode("shift-jis")
    text = re.sub(r'［.+?］', '', text)
    text = re.sub(r'《.+?》', '', text)
    return text
```

#### 四つ目のセル

WordCloundに食わせるデータは、半角空白で区切られた文字列である。そこで、与えられた文章を解析して、一般名詞だけを空白文字列を区切り文字としてつないだ文字列を返す関数、`get_words`を実装しよう。

```py
def get_words(text):
    w = ""
    m = MeCab.Tagger()
    node = m.parseToNode(text)
    while node:
        a = node.feature.split(",")
        if a[0] == u"名詞" and a[1] == u"一般":
            w += node.surface + " "
        node = node.next
    return w
```

#### 五つ目のセル

5つ目のセルで、ダウンロードがうまくいくことを確認しよう。

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/624_ruby_5668.zip"
text = load_from_url(URL)
text.split()[0]
```

「山月記」という文字列が出力されれば、ここまでは正しく実装されている。

#### 六つ目のセル

ではいよいよワードクラウドを作ろう。六つ目のセルに以下を入力、実行せよ。

```py
fpath='/usr/share/fonts/opentype/ipafont-gothic/ipagp.ttf'
words = get_words(text)
wc = WordCloud(background_color="white", width=480, height=320, font_path=fpath)
wc.generate(words)
wc.to_file("wc.png")
IPython.display.Image("wc.png")
```

日本語表示のため、フォントの場所を指定してやる必要があることに注意。しかし、あとは`WordCloud`が勝手にやってくれる。実際にワードクラウドが出力されただろうか。

出力されたら、次は「名人伝」でやってみよう。5つ目のセルのURLを

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/621_ruby_661.zip"
```

として実行し、「名人伝」と表示されて正しくデータが取れたことを確認してから、また6つ目のセルを実行してみよう。実行の度に結果は代わるが、おそらくまんなかに大きく「名人」と表示されたことと思う。

### 課題2-2：自由課題

青空文庫で好きな小説を探し、ワードクラウドを作成して、その感想を述べよ。

「小説名　青空文庫」で検索し、出てきたページの下の方にある「図書カード」のリンクをたどると、「ファイルのダウンロード」の箇所に「テキストファイル(ルビあり)」というzipファイルがあるはずである。ブラウザによるが、右クリックで「リンクのアドレスをコピー」できるはずなので、それをURLに指定してやってみよ。

どうしても小説が思いつかない場合は、以下から選んで良い。

* 「[学問のすすめ](https://www.aozora.gr.jp/cards/000296/card47061.html)」(福沢 諭吉) [https://www.aozora.gr.jp/cards/000296/files/47061_ruby_28378.zip](https://www.aozora.gr.jp/cards/000296/files/47061_ruby_28378.zip)
* 「[走れメロス](https://www.aozora.gr.jp/cards/000035/card1567.html)」(太宰治) [https://www.aozora.gr.jp/cards/000035/files/1567_ruby_4948.zip](https://www.aozora.gr.jp/cards/000035/files/1567_ruby_4948.zip)
* 「[吾輩は猫である](https://www.aozora.gr.jp/cards/000148/card789.html)」(夏目 漱石) [https://www.aozora.gr.jp/cards/000148/files/789_ruby_5639.zip](https://www.aozora.gr.jp/cards/000148/files/789_ruby_5639.zip)

## 余談：機械がやるべきこと、やるべきでないこと

今でこそ「面倒な単純作業は人間ではなく機械にやらせるべき」という考えが(たぶん)浸透しているが、昔は計算機は非常に高価であり、その計算時間は貴重な資源であった。アセンブリを機械語、つまり数字の羅列に変換するのを「アセンブル」と呼ぶが、それを人間が手で行うことを「ハンドアセンブル」と言う。計算機が使われ始めた当初は、もちろんアセンブラなどなかったから、みんなハンドアセンブルをしていた。さて、世界で初めてアセンブラを作ったと思われているのはドナルド・ギリース(Donald B. Gillies)である。1950年代、ギリースは、フォン・ノイマンの学生だった時、アセンブリを機械語に自動で翻訳するプログラムを書いていた。ギリースがアセンブラを書いているのをフォン・ノイマンが見つけたときのことを、ダグラス・ジョーンズという人が以下のように[紹介](https://groups.google.com/forum/#!msg/alt.folklore.computers/2fdmW2PU8dU/OJ_-6BjoP0YJ)している。

> John Von Neumann's reaction was extremely negative.  Gillies quotes his boss as having said "We do not use a valuable scientific computing instrument to do clerical work!" (I wish I could reproduce Gillies' imitation of Von Neumann's Hungarian accent, he was very good at it!)

(適当な訳)

>ノイマンの反応は極めてネガティブだった。ギリースはボス(ノイマンのこと)の口真似をしながらこう言った「我々は貴重な科学計算機をそのようなつまらない仕事に使うべきでない！」 (ギリースの口真似を再現できたらと思う。彼はフォン・ノイマンのハンガリー訛りの英語の真似がすごく上手いんだ)

現在、「AIが人間を超える(シンギュラリティ)」とか「AIにより人間の仕事が奪われる」とかいった、一種の終末思想が盛んに喧伝されている。私はAIの専門家ではないので、将来どうなるかはわからない。しかし、AIは人間が作るものである。自動車ができたら、運転手という職業ができたように、「AIが人間の可能性を奪う」という「引き算の考え」よりは、「AIと人間の組み合わせで新たな可能性が生まれる」と「足し算の考え」でポジティブに考えたい。おそらくそのほうが生産的であろう。
