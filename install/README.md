# Pythonのインストール

[[Up]](../index.html)
[[Repository]](https://github.com/kaityo256/python_zero)

## 本稿の目的

* Pythonのインストールと実行方法について学ぶ
* パッケージとパッケージマネージャについて学ぶ

本講義では、原則としてGoogle Colabを用いてオンライン上でPythonを学ぶ。したがってローカルにPythonをインストールする必要はないが、後で必要になることもあるだろう。そこで、手元のPCにPythonをインストールする方法と、その実行方法について書いておく。

## Pythonのライブラリについて

Pythonのインストールそのものは難しくない。公式サイトからダウンロードしてインストールするだけである。問題なのはパッケージ管理である。Pythonには最初からよくつかうライブラリが同封されており、標準ライブラリと呼ばれている。しかし、Pythonには標準ライブラリに含まれないライブラリ(サードパーティ製のライブラリと呼ばれる)が大量にある。そして、多くの場合、そのサードパーティのライブラリが使いたくなるであろう。そのようなライブラリがウェブに分散していてはインストールが大変なので、一箇所で管理するリポジトリがある。それがPython Package Index (PyPI)である。

PyPIには誰でもライブラリを登録することができ、本稿執筆時点(2019年5月)で179710個のプロジェクトが登録されている。

![PyPI](fig/pypi.png)

PyPIから欲しいライブラリを探し、ダウンロードしてインストールすることも可能である。しかし、例えば「AというライブラリはBというライブラリに依存している」「CというライブラリはCで書かれているため、ダウンロード後にコンパイルが必要になる」といった状況があり、全部人力で解決するのは面倒である。そこで、パッケージのダウンロード、依存関係の解決などをするpipというコマンドが用意された。コマンドラインで

```sh
pip install hoge
```

とすると、自動でPyPIから`hoge`を探してきて、依存関係も解決しつつインストールしてくれるようになる。しかし、Python本体にはPython2系とPython3系があり、お互いの互換性には問題がある。さらにライブラリでもバージョンによる互換性の問題が起きたため、「Pythonの環境を管理するマネージャ」が乱立した。このあたりは闇が深いので、ここでは深く突っ込まない。

現在ではPythonの環境構築についてベストプラクティスもあるのであろうが、それはおいおい気になったらやってもらうことにして、ここでは、Anacondaというプラットフォームを紹介する。Anacondaには、科学技術計算に必要なライブラリや、Jupyter Notebookなどよく使うアプリケーションが最初から含まれているため、「とりあえず使ってみたい」という方にメリットが大きい。ただし、他のよく使われるパッケージマネージャとぶつかるため、使っていて気になりだしたら別のマネージャ(例えばpipenv)などを使えば良い。以下、Anacondaのインストールの仕方を説明しておく。

## Anacondaのインストール

以下、Windowsへのインストールを例に説明する。MacやLinuxでも手順は同様だと思われる。

Googleで「Anaconda」と検索するか、[https://www.anaconda.com/](https://www.anaconda.com/)にアクセスし、右上にある「ダウンロード」をクリックする。

![Anacondaのダウンロード](fig/download.png)

現れたページの下の方に「Windows | macOS | Linux」のタブが現れるので「Windows」をクリックしてから「Python 3.7 version」の「Download」ボタンを押す。

![Anacondaのダウンロード](fig/download_win.png)

ダウンロードが完了したら、以下のアイコンをダブルクリックしてインストールを開始する。

![Anacondaのアイコン](fig/anaconda.png)

すべてデフォルトのままで良いが、途中で自分だけにインストールするか、このPC全員にインストールされるか聞かれるので、適宜対応する。必要なパッケージをほとんど含んでいるため、インストールにはかなり時間がかかる。

インストールが完了したら、「Anaconda Cloud」や「get started」を見るか聞かれる。必要ないので、チェックを外して「Finish」を押す。

![インストール完了](fig/finish.png)

Windowsのスタートメニューから、Anaconda Navigatorを実行する。Windows 10だとメニューが折り畳まれている場合もあるので注意。

![Anaconda Navigator](fig/navigator.png)

起動すると必要なパッケージを自動でインストールするため、環境によっては初回起動時に時間がかかるかもしれない。

Navigatorが起動したら、Jupyter Notebookを実行する。以下の画面の「Jupyter Notebook」の下の「Launch」をクリックする。

![Jupyter Notebook](fig/jupyter.png)

デフォルトのブラウザで、Jupyter Notebookが開かれるので、右上の「New」ボタンから「Python 3」を選ぶ。

![Open New Book](fig/newbook2.png)

新しいタブが開き、入力待ちになるので、そこで何かプログラムを入力する。例えば

```py
print("Hello Python")
```

と入力し「Shift+Return」もしくは上の「Run」ボタンをクリックする。

![Jupyter Notebookの実行結果](fig/run2.png)

セルの真下に「Hello Python」と表示されて、次のセルが入力待ちになれば成功である。これでPythonを実行する環境は整った。

右上の「Quit」を押してサーバを終了する。「Logout」を押して終了しようとすると、Anaconda Navigatorを終了しようとする時に
「Jupyter Notebookが終了していない」と言われるの注意。その場合はそのまま終了して問題ない。

また、次回からはAnaconda Navigatorを経由せず、いきなりJupyter Notebookを実行して良い。「Jupyter Notebook」というタイトルの
コマンドライン画面経由でブラウザが起動されるが、「Quit」を押せば、コマンドライン画面は消える。この時も「Logout」を押すと
コマンドライン画面が残ってしまうが、その場合はCtrl+Cを何度か押せば消える。

### Anacondaのトラブル

たまに、Anaconda Navigatorを終了しようとすると「Anaconda Navigator is still busy. Do you want to quit?」と言われることがある。
しばらくまって、再度終了しようとしてもまた出る場合はそのまま終了して良い。
