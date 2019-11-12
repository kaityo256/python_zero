# [ゼロから学ぶPython](https://kaityo256.github.io/python_zero/)

<a href="https://github.com/kaityo256/python_zero"> <div class="btn-square"><i class="fab fa-github"></i> View on GitHub</div></a>

## この講義ノートについて

これは、大学の学部二年生向けのプログラミングの講義ノートとして書かれたものである。講義の最初に30分程度説明をして、その後の60分実習をする形式とし、全部で14回の予定である。これまでプログラムをほとんどしたことがない学生を対象としている。Google Colabを使うことで環境構築をせず、ブラウザだけで実習形式で学ぶ。言語としてはPythonを用いるが、Pythonを学ぶことそのものを目的とせず、プログラミングの考え方や、計算機の仕組み、基本的なアルゴリズムの考え方などを学ぶことを目的とする。

## [はじめに](introduction/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-01) (「Pythonの概要とGoogle Colabの使い方」と共通)
* なぜPythonを学ぶのか。「プログラマ的」発想について。

## [Pythonのインストールと実行方法](install/README.md)

(Google Colabを使う場合は不要)

* Anacondaのインストール方法
* Pythonの実行方法

## [Pythonの概要とGoogle Colabの使い方](hello/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-01) (「はじめに」と共通)
* Google Colabの使い方に慣れる
* Pythonに触れてみる
* 余談：タッチタイピングについて

## [条件分岐と繰り返し処理](basic/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-02)
* 組み込み型
* 関数の宣言と利用方法
* for文による繰り返し処理
* if文による条件分岐
* ニュートン法
* 余談：バグについて

## [関数とスコープ](scope/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-03)
* while文
* ループのスキップと脱出
* 関数
* スコープ
* Collatz問題
* 余談：数論について

## [リストやタプルの使い方](list/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-04)
* リスト
* タプル
* 値のコピーとリストのコピーの違い
* 参照の値渡し
* リスト内包表記
* コッホ曲線
* 余談：機械がやるべきこと、やるべきでないこと

## [文字列処理](string/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-05)
* 文字列処理
* 辞書
* 正規表現
* 形態素解析
* ワードクラウド
* 余談：国際化は難しい

## [ファイル操作](file/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-06)
* ファイルシステムについて
* ファイルの読み込み
* CSVファイルの扱い
* データ解析
* 余談：消えていくアイコンのオリジナルたち

## [再帰呼び出し](recursion/README.md)

* [講義スライド](https://speakerdeck.com/kaityo256/python-07)
* 再帰呼び出しとは
* 階段の登り方問題
* 再帰による迷路の解法
* 余談：エレファントな解法

## [クラスとオブジェクト指向](class/README.md)

* オブジェクト指向とは？
* 割り箸ゲーム
* 余談：OSを作ってミュージシャンになった人

## [NumPyとSciPyの使い方](numpy/README.md)

* NumPyの使い方
* SciPyの使い方
* シュレーディンガー方程式と固有値問題
* 特異値分解と画像近似
* 余談：進化するオセロAIを作った話

## [Pythonが動く仕組み](howtowork/README.md)

* コンピュータはなぜ動くのか？
* Pythonが動く仕組み
* 抽象構文木
* dis.dis
* 仮想マシンハック
* 余談：スクリプト言語とコンパイラ言語

## [動的計画法](dp/README.md)

* 組み合わせ最適化問題
* 貪欲法
* 全探索
* メモ化再帰による動的計画法
* 余談：人外について

## [乱数を使ったプログラム](random/README.md)

* モンテカルロ法
* 疑似乱数
* モンティ・ホール問題
* パーコレーション
* 余談1：確率の難しさ
* 余談2：疑似乱数とゲーム

## [数値シミュレーション](simulation/README.md)

* ニュートンの運動方程式
* 反応拡散方程式(Gray-Scott Model)
* 余談：パーソナルスーパーコンピュータ

## [簡単な機械学習](gan/README.md)

* 機械学習の概要について学ぶ
* GANを体験する
* 余談：心理的安全性について

## [参考文献](references/README.md)

* 初学者向け
* 中級者向け
* 上級者向け
* その他参考にしたサイトや書籍

## ライセンス

Copyright (C) 2018-2019 Hiroshi Watanabe

この文章と絵(pptxファイルを含む)はクリエイティブ・コモンズ 4.0 表示 (CC-BY 4.0)
で提供する。

This article and pictures are licensed under a [Creative Commons Attribution 4.0 International License](https://creativecommons.org/licenses/by/4.0/).

本リポジトリに含まれるプログラムは、[MITライセンス](https://opensource.org/licenses/MIT)で提供する。

The source codes in this repository are licensed under [the MIT License](https://opensource.org/licenses/MIT).

なお、HTML版の作成に際し、CSSとして[github-markdown-css](https://github.com/sindresorhus/github-markdown-css)を利用しています。
