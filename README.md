# [ゼロから学ぶPython](https://kaityo256.github.io/python_zero/)

[リポジトリ(kaityo256/python_zero)](https://github.com/kaityo256/python_zero)

[HTML版](https://kaityo256.github.io/python_zero/)

## この記事について

プログラム初学者がPythonを学ぶための資料にする予定。

## 目的

Pythonをゼロから学び、簡単な機械学習ができるようになることを目指す。Google Colabを使うことで環境構築をせず、ブラウザだけで実習形式で学ぶ。読者としてはプログラムをほとんど触ったことがない学生を想定する。

## [はじめに](introduction/README.md)

* なぜPythonを学ぶのか。「プログラマ的」発想について。

## [Pythonのインストールと実行方法](install/README.md)

(Google Colabを使う場合は不要)

* Anacondaのインストール方法
* Pythonの実行方法

## [Pythonの概要とGoogle Colabの使い方](hello/README.md) (ほぼ完成)

* Google Colabの使い方に慣れる
* Pythonに触れてみる
* 余談：タッチタイピングについて

## [条件分岐と繰り返し処理1](basic/README.md) (ほぼ完成)

* 組み込み型
* 関数の宣言と利用方法
* for文による繰り返し処理
* if文による条件分岐
* ニュートン法
* 余談：バグについて

## [条件分岐と繰り返し処理2](while/README.md)  (ほぼ完成)

* while文
* ループのスキップと脱出
* 関数
* スコープ
* Collatz問題
* 余談：数論について

## [リストやタプルの使い方](list/README.md)  (ほぼ完成)

* リスト
* タプル
* リストのメモリ上の表現
* 参照の値渡し
* コッホ曲線の描画
* リスト内包表記
* 余談：名前解決とプログラミング言語の個性

## [文字列処理](string/README.md)

* 文字列処理
* 辞書
* 正規表現
* 形態素解析
* ワードクラウド

## [再帰処理](recursion/README.md)

* 再帰呼び出しとは
* 状態遷移図の可視化
* 木構造の編集
* 余談：エレファントな解法

## [クラスとオブジェクト指向](class/README.md)  (ほぼ完成)

* オブジェクト指向とは？
* 割り箸ゲーム
* 余談：オブジェクト指向プログラミングの意義

## [Numpyの使い方](numpy/README.md)

* Numpyとは？
* SVDを用いた画像圧縮
* 余談：スクリプト言語とコンパイラ言語

## [Pythonが動く仕組み](howtowork/README.md)

* コンピュータはなぜ動くのか？
* Pythonが動く仕組み
* 抽象構文木
* dis.dis
* 仮想マシンハック
* 余談：機械がやるべきこと、やるべきでないこと

## [計算量とアルゴリズム1](complexity/README.md)

TODO: 構成を変更中。内容を目次に追随させること

* 計算のオーダー(ランダウ表記)
* 分割統治法
  * [最近点対問題](https://en.wikipedia.org/wiki/Closest_pair_of_points_problem)を題材に
  * ボロノイ図の作成

## [動的計画法](dp/README.md)

* 組み合わせ最適化問題
* 動的計画法の要点
* 貪欲法
* メモ化再帰
* 漸化式とループ
* 余談：人外について

## [乱数を使ったプログラム](random/README.md) (ほぼ完成)

* 疑似乱数とモンテカルロ法
* 余談：疑似乱数とゲーム
* モンティ・ホール問題
* パーコレーション
* 余談：確率の難しさ

## [数値シミュレーション](simulation/README.md) (ほぼ完成)

* 空気抵抗がない場合の弾道計算
* 空気抵抗がある場合の弾道計算
* 反応拡散方程式(Gray-Scott Model)
* 余談：パーソナルスーパーコンピュータ

## [簡単な機械学習](gan/README.md)

* 機械学習の概要について学ぶ
* GANを体験する

## 参考文献

昨今、ウェブに大量に情報があるため、本など買わなくてもプログラムは独習できると思うかもしれない。しかし、ある程度わかってから見ると、いかにウェブに転がっている情報がいい加減で、薄いかがわかるようになる。特にプログラム言語に関しては誤り、誤解、意味のない文章が大量にあり、それらガラクタをかき分けて重要な情報にたどり着く努力をするよりは、さっさと数千円〜1万円ほど払って古典的名著を購入したほうが早いし有用だ。もちろん本にも当たり外れはあるが、以下は筆者が良いと思った本なので、一つの参考にしてほしい。

### 初学者向け

まったくPythonなどを触ったことが無い人が読む本。

* [入門Python3 Bill Lubanovic (著), 斎藤 康毅  (監修), 長尾 高弘  (翻訳)](https://www.amazon.co.jp/dp/4873117380) プログラムに限らずなにかを学ぶ際、最初は「軽い、薄い」本を読みたくなるが、真面目にやろうとすると、どこかで「重い、厚い」本を読む必要が出てくる。とりあえずオライリーの本を買っておけば間違いない。
* [15時間でわかるPython 集中講座 小田切 篤 (著), 露木 誠  (著)](https://www.amazon.co.jp/dp/4774178926) 全体の構成の参考にした。
* [Chainer Tutorial](https://tutorials.chainer.org/ja/tutorial.html) 機械学習フレームワーク「Chainer」のチュートリアルだが、最初の[Python入門](https://tutorials.chainer.org/ja/src/02_Basics_of_Python_ja.html)はPythonのことが簡潔にまとまっており、初学者におすすめ。

### 中級者向け

Pythonでだいたいプログラムが書けるようになった、もしくは複数のプログラム言語が書けるようになってきた人が読む本。

* [コーディングを支える技術 ~成り立ちから学ぶプログラミング作法 (WEB+DB PRESS plus) 西尾 泰和著](https://www.amazon.co.jp/dp/477415654X) プログラムを構成する要素について、様々な言語にまたがって説明することで「なぜその文法が導入されたのか、廃止されたのか」などを紐解く。一つの言語があらかたマスターできたあたりで読むといろいろ発見があるだろう。

* [リーダブルコード ―より良いコードを書くためのシンプルで実践的なテクニック (Theory in practice)](https://www.amazon.co.jp/dp/4873115655) 文法がわかり、とりあえず「動く」プログラムがかけるようになったら、次は「どのように書くべきか」を気にするべき。この本は読みやすいコード(リーダブルコード)を書くためのテクニックが詰まった古典的名著。手元において、たまに読んでみよう。その度に新たな発見があることだろう。

* [実践的低レイヤプログラミング](https://tanakamura.github.io/pllp/docs/index.html) [tanakamura](https://github.com/tanakamura)さんによる、低レベルプログラムの解説。アセンブリやリンカの解説がある。CやC++をある程度書ける人が読むと新たな発見があることだろう。

* [間違ったコードは間違って見えるようにする](http://local.joelonsoftware.com/wiki/%E9%96%93%E9%81%95%E3%81%A3%E3%81%9F%E3%82%B3%E3%83%BC%E3%83%89%E3%81%AF%E9%96%93%E9%81%95%E3%81%A3%E3%81%A6%E8%A6%8B%E3%81%88%E3%82%8B%E3%82%88%E3%81%86%E3%81%AB%E3%81%99%E3%82%8B) Joel Spolskyという人が書いた[Joel on Software](https://www.joelonsoftware.com/)というブログの記事の一つを和訳したもの。この人のブログ記事はどれも面白いが、特に若き日のビル・ゲイツによるレビューを受けた時の体験談、[My First BillG Review](https://www.joelonsoftware.com/2006/06/16/my-first-billg-review/)が面白い。[和訳](http://local.joelonsoftware.com/wiki/%E3%81%AF%E3%81%98%E3%82%81%E3%81%A6%E3%81%AEBillG%E3%83%AC%E3%83%93%E3%83%A5%E3%83%BC%E3%81%AE%E3%81%93%E3%81%A8)もある。

### 上級者向け

上級者といっても、別にプログラムがバリバリかけるという意味ではなく、たとえばプログラム書いてご飯を食べるようになっているとか、そういう感じの人が読むと面白いかな、と思う本。

* [闘うプログラマー G パスカル ザカリー (著), 山岡 洋一 (翻訳)](https://www.amazon.co.jp/dp/B00GSHI04M) マイクロソフトでWindows NTを開発した伝説のプログラマー「デイヴィッド・カトラー」の伝記のような本。Windows NTは、文字通りマイクロソフトの命運をかけたプロジェクトだった。「デスマーチ」と気軽に呼ぶのもおぞましい強行軍の描写に、僕は最初吐きそうになった。複数人である程度大きなプロジェクトに携わったことがある人は必読。

### その他参考にしたサイトや書籍

プログラムについて書いた記事や、本稿の題材(元ネタ)となった数学や科学の本など。

プログラムについて。

* [オブジェクト指向と20年戦ってわかったこと @Qiita](https://qiita.com/shibukawa/items/2698b980933367ad93b4) 「オブジェクト指向」について改めて考える良いきっかけになった。
* [「例外」がないからGo言語はイケてないとかって言ってるヤツが本当にイケてない件  @Qiita](https://qiita.com/Maki-Daisuke/items/80cbc26ca43cca3de4e4) 「例外」について改めて考える良いきっかけになった。
* [Pythonの処理系はどのように実装され，どのように動いているのか？ 我々はその実態を調査すべくアマゾンへと飛んだ． @Slideshare](https://www.slideshare.net/utgw/python-73389442) PythonのVMについて参考にした。
* [len が関数になっている理由](https://methane.hatenablog.jp/entry/20090702/1246556675) Pythonが`a.len()`ではなく、なぜ`len(a)`を採用したか(Thanks to yohhoi)。
* [Pythonはどうやってlen関数で長さを手にいれているの？](https://www.slideshare.net/shimizukawa/how-does-python-get-the-length-with-the-len-function) Pythonのlenなどがどのように動作しているか(Thanks to yohhoi)。
* [プログラミングコンテストでの動的計画法](https://www.slideshare.net/iwiwi/ss-3578511) 動的計画法の題材や計算量について参考にした。
* [計算量オーダーの求め方を総整理！ 〜 どこから log が出て来るか 〜](https://qiita.com/drken/items/872ebc3a2b5caaa4a0d0) 計算量の複雑さや題材について参考にした。
* [計算量](https://www.slideshare.net/catupper/ss-26238956) 様々なアルゴリズムの計算量について参考にした。
* [再帰関数を学ぶと、どんな世界が広がるか](https://qiita.com/drken/items/23a4f604fa3f505dd5ad) 再帰の考え方の参考にした。
* [典型的な DP (動的計画法) のパターンを整理 Part 1 ～ ナップサック DP 編 ～](https://qiita.com/drken/items/a5e6fe22863b7992efdb) 動的計画法の説明の参考にした。
* [意外と解説がない！動的計画法で得た最適解を「復元」する一般的な方法](https://qiita.com/drken/items/0c7bab0384438f285f93) 動的計画法で得た答えから、その答えを与える組み合わせを構成する方法の説明の参考にした。

数学や科学について。

* [『フカシギの数え方』 おねえさんといっしょ！ みんなで数えてみよう！](https://www.youtube.com/watch?v=Q4gTV4r0zRs) 日本科学未来館による、組み合わせ爆発を題材としたムービー。8分と短い動画ながら面白いのでおすすめ。
* [数学ガール シリーズ (結城浩 著)](https://www.hyuki.com/girl/) 高校生達の青春ドラマに、数学の楽しさ美しさを織り込んでいったような本。魅力的な登場人物の会話を追いかけているうちに「数学は面白く、そして美しい」ことが実感できると思う。
* [数学をつくった人びと I, II, III (E. T. Bell著、田中 勇、銀林 浩 訳)](https://www.amazon.co.jp/dp/4150502838) 数学という巨大で美しい学問の構築に携わった人々のドラマを描いた本。数学に興味があればもちろん、なくても楽しめる。大変おすすめ。
* [カオス―新しい科学をつくる (ジェイムズ・グリック 著, 大貫 昌子 訳)](https://www.amazon.co.jp/dp/4102361014) 決定論的なしくみから予想不可能な振る舞いが生まれる「カオス」。その「カオス」に立ち向かった人々のドラマ。本講でも頻繁に「カオス」を題材にしているが、それで興味を持った人は読んでみると面白いと思う。おすすめ。
* [複雑系―科学革命の震源地・サンタフェ研究所の天才たち (M. M. Waldrop著、田中 三彦、遠山 峻征 訳)](https://www.amazon.co.jp/dp/4102177213) こちらは「複雑系」という学問(哲学?)を構築した人々のドラマ。全体は部分の和以上のものだろうか？こちらも面白い。

## ライセンス

Copyright (C) 2018-2019 Hiroshi Watanabe

この文章と絵(pptxファイルを含む)はクリエイティブ・コモンズ 4.0 表示 (CC-BY 4.0)
で提供する。

This article and pictures are licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

本リポジトリに含まれるプログラムは、[MITライセンス](https://opensource.org/licenses/MIT)で提供する。

The source codes in this repository are licensed under [the MIT License](https://opensource.org/licenses/MIT).

なお、HTML版の作成に際し、CSSとして[github-markdown-css](https://github.com/sindresorhus/github-markdown-css)を利用しています。
