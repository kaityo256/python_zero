# 文字列処理

[[Up]](../index.html)
[[Repository]](https://github.com/kaityo256/python_zero)

## 本講で学ぶこと

* 文字列処理
* 辞書
* 正規表現

## 文字列と文字コードについて

TODO: 文字コードの説明

## 辞書

TODO: 辞書の説明

## 正規表現

TODO: 正規表現の説明

## 課題1

それでは、ここまで学んだことを使ってウェブから情報を取得し、解析してみよう。ここでは「[青空文庫](https://www.aozora.gr.jp/)」からテキストを取得し、そのテキストを解析してみる。青空文庫は著作権が消滅した作品か、著者が許諾している作品のテキストをウェブ上に公開している電子図書館である。

具体的な作業は以下の通りである。

* 青空文庫から、zipファイルをダウンロードする
* zipファイルを展開し、文字コードを変換する
* MeCabを使って形態素解析し、一般名詞のみを取り出す
* 一般名詞の頻度分布を取得し、利用頻度トップ10を出力する

このようにウェブから何か情報を抽出する技術を **ウェブスクレイピング (Web scraping)**と呼ぶ。今回の作業は、ウェブスクレイピングのうちもっとも単純なものである。

**注意**：ウェブスクレイピングは、相手のサーバに負担がかからないように注意しながら行うこと。例えば「指定のパス以下のファイルをすべて取得する」といった作業は厳禁である。また、利用規約によってそもそもウェブスクレイピングが禁止されているサービスもある(例えばTwitterなど)。その場合はサービスが提供しているAPIを通じて情報を取得することが多い。

### 課題1-1 MeCabのインストール

まず、Debianのパッケージ管理ソフトウェアであるaptitudeをインストールする。新しいPython3ノートブックを開き、最初のセルに以下を入力、実行せよ。冒頭の「!」を忘れないこと。

```py
!apt install aptitude
```

最後に「Processing triggers for libc-bin (2.27-3ubuntu1) ...」などと表示され、実行が終了したら完了である。

次に、先程インストールしたaptitudeを使ってMeCabと必要なライブラリをインストールする。最後の`-y`を忘れないように。

```py
!aptitude install mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file -y
```

出力の最後に

```sh
done!
Setting up mecab-jumandic (7.0-20130310-4) ...
```

などと表示されれば完了である。

最後に、MeCabのPythonバインディングをインストールする。

```sh
!pip install mecab-python3==0.7
```

最新版は不具合があるようなので、バージョン0.7を指定してインストールする。

```sh
Successfully installed mecab-python3-0.7
```

と表示されれば完了である。早速importしてみよう。

```py
import MeCab
```

これを実行してエラーがでなければインストールに成功している。

次のセルに以下を入力してみよう。

```py
m = MeCab.Tagger()
print(m.parse ("すもももももももものうち"))
```

以下のような実行結果が得られるはずである。

    すもも	名詞,一般,*,*,*,*,すもも,スモモ,スモモ
    も	助詞,係助詞,*,*,*,*,も,モ,モ
    もも	名詞,一般,*,*,*,*,もも,モモ,モモ
    も	助詞,係助詞,*,*,*,*,も,モ,モ
    もも	名詞,一般,*,*,*,*,もも,モモ,モモ
    の	助詞,連体化,*,*,*,*,の,ノ,ノ
    うち	名詞,非自立,副詞可能,*,*,*,うち,ウチ,ウチ
    EOS

### 課題1-2 青空文庫からのデータ取得

ノートブックの上のメニューから「編集」「すべてのセルを選択」を実行し、その後「編集」「選択したセルを削除」を実行することで、全てのセルを削除せよ。この状態でもMeCabはインストールされたままである。

「+コード」をクリックして現れた最初のセルに、以下を入力、実行せよ。

```py
from collections import defaultdict
import re
import io
import urllib.request
from zipfile import ZipFile
import MeCab
```

次のセルに、ウェブからデータを取得する関数`load_from_url`を以下のように実装せよ。

```py
def load_from_url(url):
    data = urllib.request.urlopen(url).read()
    zipdata = ZipFile(io.BytesIO(data))
    filename = zipdata.namelist()[0]
    text = zipdata.read(filename).decode("shift-jis")
    text = re.sub(r'《.+?》', '', text)
    text = re.sub(r'-.+-', '', text)
    return text
```

このセルを実行後、3つ目のセルに以下を入力、テストせよ。

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/624_ruby_5668.zip"
load_from_url(URL)
```

以下のような結果が出力されれば成功である。

    山月記\r\n中島敦 \r\n\r\n\r\n【テキスト中に現れる記号について】\r\n\r\n《》：ルビ\r\n……

これは、中島敦という作家の「山月記」という小説である。

### 課題1-3 形態素解析

ではいよいよ形態素解析をしてみよう。といってもMeCabを使えば楽勝である。

2つ目のセルと3つ目のセルの間に新たにセルを作り、以下を入力せよ。

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

`URL = "https:..."`とある4つ目のセルを、以下のように修正、実行せよ。

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/624_ruby_5668.zip"
text = load_from_url(URL)
show_top10(text)
```

文章に使われている一般名詞の頻度トップ10が、回数とともに出力されたはずである。

別の作品も見てみよう。同じく中島敦の「名人伝」で同様な解析をしてみよう。5つ目のセルに以下を入力、実行せよ。4つ目のセルをコピーすると楽である。

```py
URL = "https://www.aozora.gr.jp/cards/000119/files/621_ruby_661.zip"
text = load_from_url(URL)
show_top10(text)
```

読んだことがなくても、なんとなくどんな作品なのかがわかるであろう。