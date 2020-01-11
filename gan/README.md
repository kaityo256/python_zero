
# [簡単な機械学習](https://kaityo256.github.io/python_zero/gan/)

## 本講の目的

* 機械学習の概要について学ぶ
* GANを体験する
* 余談：心理的安全性について

## 機械学習とは

昨今、「機械学習」「ディープラーニング」「AI」といった言葉をよく聞く。Googleによる機械学習のフレームワーク「TensorFlow」や、PFNによる「Chainer」などがPythonで記述されていることもあり、機械学習をする上でPythonが事実上の共通語になりつつある。機械学習による派手な結果を目にすることも多いだろう。せっかく本講義でPythonを学んだのであるから、最後は機械学習を体験してみよう。今回は、ざっと機械学習の概要について触れてから、機械学習で注目されている技術の一つ、GANによる画像生成を体験してみる。

### 機械学習の種類

一口に「機械学習」と言っても、機械学習がカバーする範囲は広い。現在も様々な技術が提案されているため、その全てを厳密に分類するのは難しいが、よく言われるのは以下の三種類の分類である。

1. 教師あり学習
2. 教師なし学習
3. 強化学習

**教師あり学習(Supervised Learning)** とは、「問題と解答のセット」を与えて、それで学習させる方法である。例えば、予め大量の写真を用意し、それぞれに「ネコ」や「イヌ」といったラベルをつけておく。それを学習させることで、「学習に用いたデータセットに含まれていない、初めて見る写真」に対しても正しく「ネコ」や「イヌ」と判定できるようにさせるのが典型的な教師あり学習である。

**教師なし学習(Unsupervised Learning)** とは、データだけを与えて、データを分類したり、似ているものを探したりさせる方法である。例えば物品の売上データを解析し、「ある商品Aを購入した人は、次は商品Bを購入する可能性が高い」といった関係を見つければ、商品Aを購入した人に「Bはいかがでしょうか？」と勧めることができ、売上向上につながる。オンラインショップなどでよく見る「この商品を買った人はこんな商品も買っています」というアレである。

**強化学習(Reinforcement Learning)** とは、何かエージェントに行動をさせて、その結果として報酬を与えることで、「うまく」行動できるように学習させていく手法である。典型的な応用例はチェスや囲碁、将棋などのボードゲームのAIであろう。ある局面において、多数ある合法手の中から「次の一手」を選ばなければならない。この時、とりあえず(現在の知識で)適当に指してみて、勝負が決まってから振り返り、「最終的に勝利につながった手」に正の報酬を、「敗北につながった手」に負の報酬を与えることで、それぞれの局面において「これは良い手だった」「これは悪手だった」と学習していく。

これらはどれも面白く、それぞれ奥が深いのだが、ここでは教師あり学習に注目する。

「教師あり学習」が扱う問題は、さらに「分類問題」と「回帰問題」にわけることができる。分類問題とは、入力に対して有限のラベルのどれかを当てる問題である。例えば「ネコ」「イヌ」「ゾウ」「パンダ」のどれかが写っている写真を見せられ、何が写っているかを答えるのが典型的な分類問題である。特に、ラベルが「Yes」か「No」の二種類である時、これを二値分類問題と呼ぶ。回帰問題とは、入力に対して何か連続な値を返す問題である。例えば家の広さ、築年数、駅からの距離や周りの条件等から家賃を推定するのが典型的な回帰問題である。

### 学習と最適化

機械学習では、よく「学習」という言葉が出てくる。学習とは、ある量を最適化することだ。その最適化の簡単な例として、線形回帰を見てよう。

回帰とは、何かしらの入力$x$に対して、出力$y$が得られる時、その間の関係$y = f(x)$を推定する問題である。例えば片方を固定されたバネに荷重をかけ、どのくらい伸びるかを調べる実験を考える。この場合の入力$x$は荷重、出力$y$はバネの伸びである。とりあえずいくつか重りを乗せてみて、荷重と伸びの観測値をグラフにプロットしてみたら以下のようになったとしよう。

![バネの伸びと荷重の関係](fig/regression.png)

ここから、バネ定数を推定するには最小二乗法を使えば良いことは知っているであろうが、簡単におさらいしておこう。いま、$N$回異なる荷重をかける実験を行い、荷重とバネの伸びの観測値の組$(x_i, y_i)$が得られたとする。さて、フックの法則から$y = a x$が予想される。$x_i$の荷重がかかった時、このモデルによる予想値は$a x_i$だが、観測値は$y_i$だ。そのズレ$y_i - a x_i$を残差と呼ぶ。この残差の二乗和は$a$の関数であり、以下のように表すことができる。

$$
C(a) = \sum_i^N (a x_i - y_i)^2
$$

$C(a)$はモデルと観測値の誤差を表している。$a$が大きすぎても小さすぎても$C(a)$は大きくなるので、どこかに最適な$a$があるだろう。$C(a)$を最小化するような$a$の値は、$C(a)$を$a$で微分してゼロになるような点であるはずだ。微分してみよう。

$$
\frac{dC}{da} = \sum_i^N (2 a x_i^2 - 2a x_i y_i) = 0
$$

これを$a$について解けば、

$$
a = \frac{\sum_i^N x_i y_i}{\sum_i^N x_i^2}
$$

を得る。さて、実はこれは最も単純な機械学習の例となっている。

我々は、$y = a x$というモデルを仮定し、$N$個の観測値の組$(x_i, y_i)$を使ってモデルパラメータ$a$を決定した。このパラメータを決定するプロセスを「学習」と呼ぶ。「学習」では、$C(a)$を最小化するようにモデルのパラメータ$a$を決定した。この最小化する関数を **目的関数 (Cost Function)**と呼ぶ。目的関数を最小化するために使われた観測データを「トレーニングデータ」と呼ぶ。トレーニングデータに対する誤差を**訓練誤差**と呼ぶ。

![訓練誤差と汎化誤差](fig/error.png)

さて、我々の目的はあくまで「バネの伸び」という物理現象を記述することであって、「観測データを再現するモデルの構築」は、その手段に過ぎなかった。したがって、こうして得られた$y = ax$というモデルは、未知の入力$x$に対して、良い予想値$y$を与えなくてはならない。トレーニングデータに含まれない入力$x$に対して、我々が構築したモデルがどれくらい良いかを調べることを「テスト」と呼ぶ。

具体的には、モデルを決める時に使ったトレーニングデータとは別のデータセットを用意しておき、そのデータについてモデルがどれくらいよく予想できるかを確認する、ということがよく行われる。このような目的に使われるデータを「テストデータ」と呼び、テストデータに対する誤差を**汎化誤差**と呼ぶ。

訓練誤差は小さいのに、汎化誤差が大きい場合、トレーニングデータに最適化され過ぎており、応用が効かない「頭でっかち」なモデルになっていることを示唆する。これを **過学習(overfitting)** と呼ぶ。データの数に比べてモデルパラメータが多い時によく起きる。

![訓練誤差・汎化誤差・過学習](fig/overfitting.png)

今回の講義で用いるTensorFlowをはじめとして、機械学習は高度に完成されたライブラリやフレームワークが多数存在する。その内部で用いられている理論やアルゴリズムは難しいものが多く、それらのフレームワークを「ブラックボックス」として用いるのはある程度やむを得ないところもある。しかし、機械学習に限らないことだが、基本的な概念、用語については、簡単な例でしっかり理解しておいた方が良い。「機械学習は最小二乗法のお化けのようなものだ」というと語弊があるのだが、学習、目的関数、訓練誤差、汎化誤差、過学習といった機械学習で頻出する単語のイメージを、中身がよくわかる単純な例、例えば線形モデルの最小二乗法で理解しておく、ということは非常に重要なことである。

機械学習に限らないことだが、「何かよくわからない概念が出てきたら、簡単な例で考えてみる」癖をつけておきたい。

### GANとは

通常よく使われる機械学習、例えば「植物の写真を見せて名前を答えるモデル」や「人間の写真を見せて年齢を推定するモデル」などでは、モデルは入力となるデータに対して何かしら「答え」を返すことが目的である。しかし、そういう分類や回帰ができるようになってくると、もっと難しい作業、例えば「有名な画家の絵を多数模写させることで、その画家のタッチでオリジナルの絵が書けるモデル」や、「テーマを伝えただけで映画やドラマの脚本を書けるモデル」などをやらせてみたくなるのが人情である。ここではそんな例として、GANを取り上げる。GAN (Generative Adversarial Networks)とは、直訳すると「敵対的生成ネットワーク」であり、二つのモデルを競わせることで画像を生成する手法である。

GANでは、GeneratorとDiscriminatorの二つのモデルを用意する。これらはよく「偽造者」「鑑定者」に例えられる。まず、本物のデータセット(例えば有名な画家の絵)を用意する。その後、ランダムに「本物のデータ」と「偽造者」が生成した「偽物のデータ」を「鑑定士」に見せ、それを本物か、偽物か判定させる。鑑定者から見れば、これは二値分類問題になっている。ラベルは「本物」か「偽物」である。鑑定者は大量に見せられるデータをどんどん鑑定することで「鑑定士」としての観察眼を磨いていく。

逆に、偽造者は、自分が提出したデータが「偽物」と見破られたら失敗、「本物」と鑑定されたら成功であり、そのフィードバックを受けながら「偽造者」としての腕を磨いていく。

![GANの概念図](fig/gan.png)

こうして「偽造者」と「鑑定者」がお互いに切磋琢磨しながら学習していくと、最終的に「本物と見紛うばかりのデータを生成できる偽造者が誕生するだろう」というのがGANの要諦である。今回の課題では、適当なデータセットを用意し、偽造者と鑑定者を学習させることで、最終的に偽造者が用意したデータセットを真似た絵を生成できるようになるプロセスを観察しよう。

# 簡単な機械学習：課題

## GAN

Googleによる機械学習のライブラリ、Tensorflowを使ってGAN (Generative Adversarial Networks)を組んでみよう。それなりにコード量があるので、間違いないように注意して入力すること。

### 課題1: GANの実行テスト

新しいノートブックを開き、`gan.ipynb`という名前で保存せよ。

#### 1. TensorFlowのダウングレード

以下のコードは最新のTensorFlowでは動作しない。まずバージョンを落とそう。

```py
%tensorflow_version 1.x
!pip install tensorflow==1.13.1
```

#### 2. import

二つ目のセルで必要なモジュールをインポートする。

```py
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
tf.logging.set_verbosity(tf.logging.ERROR)
```

#### 3. 宣言

今後使うオブジェクトやパラメータの宣言を行う。

```py
tfgan = tf.contrib.gan
layers = tf.contrib.layers
framework = tf.contrib.framework
slim = tf.contrib.slim
dataprovider = slim.dataset_data_provider.DatasetDataProvider
BATCH_SIZE = 32
```

「WARNING: The TensorFlow contrib module will not be included in TensorFlow 2.0.」といったTensorFlowからの警告が出るが気にしなくてよい。

#### 4. Generatorの宣言

Generator(偽造者)の宣言を行う。

```py
def generator_fn(noise, weight_decay=2.5e-5, is_training=True):
    f1 = framework.arg_scope(
        [layers.fully_connected, layers.conv2d_transpose],
        activation_fn=tf.nn.relu,
        normalizer_fn=layers.batch_norm,
        weights_regularizer=layers.l2_regularizer(weight_decay))
    f2 = framework.arg_scope(
        [layers.batch_norm],
        is_training=is_training,
        zero_debias_moving_mean=True)
    with f1, f2:
        net = layers.fully_connected(noise, 1024)
        net = layers.fully_connected(net, 7 * 7 * 256)
        net = tf.reshape(net, [-1, 7, 7, 256])
        net = layers.conv2d_transpose(net, 64, [4, 4], stride=2)
        net = layers.conv2d_transpose(net, 32, [4, 4], stride=2)
        net = layers.conv2d(net, 1, 4, activation_fn=tf.tanh)
        return net
```

#### 5. Discriminatorの宣言

Discriminator(鑑定者)の宣言を行う。

```py
def discriminator_fn(img, _, weight_decay=2.5e-5, is_training=True):
    with framework.arg_scope(
            [layers.conv2d, layers.fully_connected],
            activation_fn=(lambda n: tf.nn.leaky_relu(n, alpha=0.01)),
            weights_regularizer=layers.l2_regularizer(weight_decay),
            biases_regularizer=layers.l2_regularizer(weight_decay)):
        net = layers.conv2d(img, 64, [4, 4], stride=2)
        net = layers.conv2d(net, 128, [4, 4], stride=2)
        net = layers.flatten(net)
        with framework.arg_scope([layers.batch_norm], is_training=is_training):
            net = layers.fully_connected(
                net, 1024, normalizer_fn=layers.batch_norm)
        return layers.linear(net, 1)
```

#### 6. データセットの準備

「本物」のデータを供給する関数を定義する。

```py
def provide_data(source, batch_size):
    keys_to_features = {
        'image/encoded': tf.FixedLenFeature((), tf.string, default_value=''),
        'image/format': tf.FixedLenFeature((), tf.string, default_value='raw'),
    }
    datanum = sum(1 for _ in tf.python_io.tf_record_iterator(source))
    items_to_handlers = {
        'image': slim.tfexample_decoder.Image(shape=[28, 28, 1], channels=1),
    }
    decoder = slim.tfexample_decoder.TFExampleDecoder(
        keys_to_features, items_to_handlers)
    reader = tf.TFRecordReader
    dataset = slim.dataset.Dataset(source, reader, decoder, datanum, None)
    provider = dataprovider(dataset, shuffle=True)
    image, = provider.get(['image'])
    image = (tf.cast(image, tf.float32) - 128.0) / 128.0
    images = tf.train.batch([image], batch_size=batch_size)
    return images
```

#### 7. データセットのダウンロード

学習に用いるデータセットをダウンロードしよう。データセットは以下の三種類を用意してある。

* `mnist.tfrecord` 手書きの数字(MNIST)
* `hiragana.tfrecord` ひらがなすべて(IPAゴシックフォント)
* `fontawesome.tfrecord` Font Awesomeというフォントのシンボルアイコン10種類

上記のうち、好きなものを一つ選んで`TRAIN_DATA`とすること。以下はMNISTを選んだ場合の例である。

```py
TRAIN_DATA = "mnist.tfrecord"
url="https://kaityo256.github.io/python_zero/gan/"
file=url+TRAIN_DATA
!wget $file
```

上記を実行すると、ファイルがダウンロードされる。最後に以下のような表示がされたら成功である。

```sh
2019-05-31 08:03:55 (138 MB/s) - ‘mnist.tfrecord’ saved [20852051/20852051]
```

#### 8. 初期化

TensorFlowを初期化し、データをバッチに変換する。

```py
tf.reset_default_graph()
with tf.device('/cpu:0'):
    real_images = provide_data(TRAIN_DATA, BATCH_SIZE)
```

#### 9. GANの宣言

これまで宣言した「偽造者(Generator)」と「鑑定者(Discriminator)」を競争させるGANを宣言する。

```py
gan_model = tfgan.gan_model(
    generator_fn,
    discriminator_fn,
    real_data=real_images,
    generator_inputs=tf.random_normal([BATCH_SIZE, 64]))

improved_wgan_loss = tfgan.gan_loss(
    gan_model,
    generator_loss_fn=tfgan.losses.wasserstein_generator_loss,
    discriminator_loss_fn=tfgan.losses.wasserstein_discriminator_loss,
    gradient_penalty_weight=1.0)

generator_optimizer = tf.train.AdamOptimizer(0.001, beta1=0.5)
discriminator_optimizer = tf.train.AdamOptimizer(0.0001, beta1=0.5)
gan_train_ops = tfgan.gan_train_ops(
    gan_model,
    improved_wgan_loss,
    generator_optimizer,
    discriminator_optimizer)

with tf.variable_scope('Generator', reuse=True):
    eval_images = gan_model.generator_fn(
        tf.random_normal([500, 64]),
        is_training=False)

visualizer = tfgan.eval.image_reshaper(eval_images[:20, ...], num_cols=10)

train_step_fn = tfgan.get_sequential_train_steps()
global_step = tf.train.get_or_create_global_step()
```

#### 10. GANの実行

それではいよいよGANを実行してみよう。とりあえずテストとして200回ほど学習させる。25回に一度、Generatorが生成する画像を表示させている。ここまで正しく入力できていれば、学習過程が可視化されていくはずである。

```py
TOTAL_STEPS = 201
INTERVAL = 25
with tf.train.SingularMonitoredSession() as sess:
    for i in range(TOTAL_STEPS):
        train_step_fn(sess, gan_train_ops, global_step,
                        train_step_kwargs={})
        if i % INTERVAL == 0:
            digits_np = sess.run([visualizer])
            plt.axis('off')
            plt.imshow(np.squeeze(digits_np), cmap='gray')
            plt.show()
```

Generatorが生成する画像は、最初は単なるノイズだが、徐々に「それっぽい」画像になっていくのがわかるであろう。

### 課題2: 別のデータセットのテスト

うまくいったら、他のデータセットも試してみよ。データをダウンロードするセル(6つ目)で`TRAIN_DATA`を書き換え、そこから順番にセルを再実行すれば、別のデータセットで学習をするはずである。もしくは，`TOTAL_STEPS`をもう少し長くして、学習結果がどうなるを見ても良い。MNISTやFont Awesomeなら1000ステップもあればそれなりの画像となるが、ひらがなは種類が多いため、学習に苦しむようである。その観察結果を報告せよ。

## 余談：心理的安全性について

例えば子育てをしている人が、ブログなりSNSなりで子育ての経験を書いているとしよう。子育てをしていると、たまに「ヒヤッ」とすることがある。いつの間にか子供が危険なもので遊んでいた、危険なものの近くにいた、ふと目を離しスキにいなくなった……そんな「ヒヤッ」としたり「ハッ」としたりする、重大事故一歩手前の状態を俗に「ヒヤリハット」と呼ぶ。そんな「ヒヤリハット」をネットに流した時の、まわりの人の反応を想像してみてほしい。「そんな危険な目に合わせるなんて子供がかわいそう」「○○に気をつけないなんて親として失格」という非難のコメントが付きそうな気がするであろう。実際、子供がらみの事件のニュースサイトのコメント欄で親を責める声はよく見かける。さて、「ヒヤリハット」を公開し、非難された親はどうするか。もちろん「次回は気をつけよう」と思うであろうが、それ以上に「子育てのヒヤリハットはネットに公開してはいけない」と学ぶであろう。そして、そのブログなりSNSの読者が「うちも気をつけよう」と思うような情報の共有機会が失われることになる。

全く同様なことが会社組織などで起きる。工事現場で危険な目にあったことを何気なく上長に伝えたら、「危ないだろ！」と叱責されたとしよう。その部下はおそらく次から危険な事例を報告しなくなるだろう。1つの重大事故の影には、多数の「ヒヤリハット」が隠れているという。頻繁に「ヒヤリハット」が発生するということは、安全性になんらかの根本的な問題があるという重要なサインなのであるが、それを言い出しづらい雰囲気の中では「危険の芽」は黙殺され、そのうち重大事故につながってしまう。

このような「ネガティブな報告」をしづらい雰囲気がまずいことは感覚的にわかるであろう。逆に、「ネガティブな報告をしても責められない、初歩的な質問をしても馬鹿にされない」状態を「心理的安全性が保たれた状態」と呼ぶ。心理的安全性(Psychological Safety)は、Googleの働き方の研究(Project Aristotle)の報告から広まったものだ。

KPIという言葉を聞いたことがあるだろう。Key Performance Indicatorの略で、要するに数値目標のことだ。心理的安全性なしにKPIの数値だけに着目すると、必ずまずい状態になる。例えば、あるソフトウェア開発グループでは、「バグゼロ」を目指し、バグの報告が多い部署は「目標達成度が低い」とみなされた。すると、当然のことながらバグを見つけてもそれはバグとして報告されず、例えば「機能追加の要望」などとして処理されるようになった。数字の上では全体的に「報告される」バグの数は激減したが、これが望ましい状態ではないことは明らかであろう。逆に、ある工場では、製品の完成チェック時に必ず一定数以上の問題を見つけることを強制した。するとどうなるか。品質管理部は、たとえほとんど問題がない製品でも、言いがかりのような問題を見つけて報告するようになった。それに対抗するように、工場ではわざと目に付きやすい問題点を残すようになった。「バグが許されない職場」は「バグが報告されない職場」になり、「問題を必ず見つける職場」では「問題を必ず作る職場」になってしまった。

共通するのは心理的安全性であり、もっと言えばチームの目的意識の共有である。我々は本質的なバグの数を減らしたいのであって、バグの報告を減らしてはならない。「心理的安全性なしにKPIのみを重視すると、必ず数値ハックされる」ということは心に留めておきたい。

参考URL

* re:Work - The five keys to a successful Google team
  * [https://rework.withgoogle.com/blog/five-keys-to-a-successful-google-team/](https://rework.withgoogle.com/blog/five-keys-to-a-successful-google-team/)
* チャットコミュニケーションの問題と心理的安全性の課題
  * [https://www.slideshare.net/TokorotenNakayama/eof2019/](https://www.slideshare.net/TokorotenNakayama/eof2019/)