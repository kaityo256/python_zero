敵対的生成ネットワーク、GAN (Generative Adversarial Networks)を体験してみよう。これは、偽造者(Generator)と鑑定者(Discriminator)がお互いに切磋琢磨させることで、偽造者に本物そっくりの画像を生成させるようにする手法である。

新しいノートブックを開き`gan.ipynb`として保存せよ。

**注意**：以下のコードは古いTensorFlowでしか動作しないため、書き直す予定です。

#### 1. TensorFlowのインストール

Google ColabではデフォルトでTensorFlowが使えるが、今回はやや古いバージョンを使いたいので、バージョンを指定してインストールをする。

```py
%tensorflow_version 1.x
!pip install tensorflow==1.13.1
```

最初の`%`から始まる行はマジックコメントと呼ばれ、Google Colabに「これからバージョン1.0系を使うよ」という指示をする。

```txt
Successfully installed mock-3.0.5 tensorboard-1.13.1 tensorflow-1.13.1 tensorflow-estimator-1.13.0
```

と表示されれば正しくインストールされている。

#### 2. サンプルプログラムのダウンロード

GANのプログラムは、簡単なものでもそれなりに長いコードを記述する必要がある。今回は既に入力されたプログラムをダウンロードしよう。以下を実行せよ。

```py
!wget https://kaityo256.github.io/python_zero/ml/gan_test.py
```

`‘gan_test.py’ saved`と表示されればダウンロード完了である。

#### 3. インポート

先程ダウンロードしたプログラムをインポートしよう。

```py
import gan_test
```

実行時に多数の`FutureWarning`が出るが、気にしなくて良い。これでGANが使えるようになった。

#### 4. データのダウンロード

GANでは、まず「正解の画像」をデータセットとして与える必要がある。偽造者は、その画像に似せて絵を描いていく。逆に、与えるデータによって「好きな画家」を模写できるように学習させることができる。本講義では、三つのデータセットを用意した。

* `mnist.tfrecord` 手書きの数字(MNIST)
* `fontawesome.tfrecord` Font Awesomeというフォントのシンボルアイコン10種類
* `hiragana.tfrecord` ひらがなすべて(IPAゴシックフォント)

上記のうち、好きなものを一つ選んで`TRAIN_DATA`とし、ダウンロードすること。数字は学習が容易だが、ひらがなは難しく、シンボルはその中間、といった特徴がある。

以下は手書きの数字(MNIST)を選んだ場合の例である。

```py
TRAIN_DATA = "mnist.tfrecord"
url="https://kaityo256.github.io/python_zero/ml/"
file=url+TRAIN_DATA
!wget $file
```

`‘mnist.tfrecord’ saved`など、自分が選んだファイル名が表示されればダウンロード完了である。

#### 5. GANの実行

ではいよいよGANの実行をしてみよう。以下を実行せよ。

```py
gan_test.run_gan(TRAIN_DATA)
```

最初に

```txt
WARNING: The TensorFlow contrib module will not be included in TensorFlow 2.0.
```

といった警告が出るが、気にしないで良い。

画面には、数十秒ごとに偽造者が作成した画像が表示されていく。最初は完全なノイズにしか見えなかった画像が、学習が進むにつれて偽造者が「腕を上げていく」様子が見えるであろう。学習が終わったら(もしくは途中で止めて)、別の画像でも学習させてみよ。