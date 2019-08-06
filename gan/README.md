
# [簡単な機械学習](https://kaityo256.github.io/python_zero/gan/)

## 本講の目的

* 機械学習の概要について学ぶ
* GANを体験する

## 機械学習とは

昨今、「機械学習」「ディープラーニング」「AI」といった言葉をよく聞く。Googleによる機械学習のフレームワーク「TensorFlow」や、PFNによる「Chainer」などがPythonで記述されていることもあり、機械学習をするには事実上Pythonが共通語になりつつある。機械学習による派手な結果を目にすることも多いだろう。せっかく本講義でPythonを学んだのであるから、最後は機械学習を体験してみよう。本稿では、ざっと機械学習の概要について触れてから、機械学習で注目されている技術の一つ、GANによる画像生成を体験してみよう。

### 機械学習の種類

機械学習がカバーする範囲は広く、現在も様々な技術が提案されているため、その全てを厳密に分類するのは難しいが、よく言われるのは以下の三種類の分類である。

1. 教師あり学習
2. 教師なし学習
3. 強化学習

教師あり学習(Supervised Learnings)とは、「正解のあるデータ」を与えて、それで学習させる方法である。例えば、予め大量の写真を用意し、それぞれに「ネコ」や「イヌ」といったラベルをつけておく。それを学習させることで、「初めて見る写真」に対しても正しく「ネコ」や「イヌ」と判定できるようにさせるのが典型的な教師あり学習である。

教師なし学習は(Unsupervised Learnings)は、データだけを与えて、データを分類したり、似ているものを探したりさせる方法である。例えば物品の売上データを解析し、「ある商品Aを購入した人は、次は商品Bを購入する可能性が高い」といった関係を見つければ、商品Aを購入した人に「Bはいかがでしょうか？」と勧めることができ、売上向上につながる(Amazonなどでよく見る「この商品を買った人はこんな商品も買っています」というアレである)。

強化学習とは、何かエージェントに行動をさせて、その結果として報酬を与えることで、「うまく」行動できるように学習させていく手法である。典型的な応用例はチェスや囲碁、将棋などのボードゲームのAIであろう。ある局面において、多数ある合法朱の中から「次の一手」を選ばなければならない。この時、「最終的に勝利につながった手」に正の報酬を、「敗北につながった手」に負の報酬を与えることで、「これは良い手」「これは悪手」と学習していく。

これらはどれも面白いのだが、ここでは教師あり学習に注目しよう。

「教師あり学習」が扱う問題は、大きく分けて「分類問題」と「回帰問題」にわけることができる。分類問題とは、入力に対して有限のラベルのどれかを当てる問題である。例えば「ネコ」「イヌ」「ゾウ」「パンダ」のどれかが写っている写真を見せられ、何が写っているかを答えるのが典型的な分類問題である。回帰問題とは、入力に対して何か連続な値を返す問題である。例えば家の広さ、築年数、駅からの距離や周りの条件等から家賃を推定するのが典型的な回帰問題である。

分類問題のうち、「○か×か」のように、答えが二種類しかないものを「二値分類」と呼ぶ。

### 学習と最適化

機械学習では、よく「学習」という言葉が出てくる。実際には、学習とは「ある関数を最適化」することである。例えば分類問題では正答率を高くしたいし、強化学習では報酬を最大化したいであろう。何か最大化、もしくは最小化したい関数を目的関数(cost function)と呼ぶ。

TODO: 目的関数の説明

TODO: 最小二乗法の説明も入れる？

### GANとは

GAN (Generative Adversarial Networks)とは、直訳すると「敵対的生成ネットワーク」であり、二つのモデルを競わせることで画像を生成する手法である。

GANはGeneratorとDiscriminatorの二つのモデルを学習させるが、これらはよく「偽造者」「鑑定者」に例えられる。まず、本物のデータセットを用意する。その後、ランダムに「本物のデータ」とGeneratorが生成した「偽物のデータ」をDiscriminatorに見せ、それを本物か、偽物か判定させる。Discriminatorから見れば、これは二値分類問題になっている。ラベルは「本物」か「偽物」である。Discriminatorは大量に見せられるデータをどんどん鑑定することで「鑑定士」としての観察眼を磨いていく。

逆に、Generatorは、自分が提出したデータが「偽物」と見破られたら失敗、「本物」と鑑定されたら成功であり、そのフィードバックを受けながら「偽造者」としての腕を磨いていく。

こうしてGeneratorとDiscriminatorがお互いに切磋琢磨しながら学習していくと、最終的に「本物と見紛うばかりのデータを生成できるGeneratorが誕生するだろう」というのがGANの要諦である。

![GANの概念図](fig/gan.png)

TODO: Lossの減少について

# 簡単な機械学習：課題

## GAN

ではさっそくGANを組んでみよう。それなりにコード量があるので、間違いないように注意して入力すること。以下、番号がセルの番号に対応するので参考にしてほしい。

### 課題1: GANの実行テスト

#### 1. import

最初のセルで必要なモジュールをimportしよう。ついでにTensorFlowの警告を減らす設定をしておく。

```py
import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf
tf.logging.set_verbosity(tf.logging.ERROR)
```

#### 2. 宣言

```py
tfgan = tf.contrib.gan
layers = tf.contrib.layers
framework = tf.contrib.framework
slim = tf.contrib.slim
dataprovider = slim.dataset_data_provider.DatasetDataProvider
BATCH_SIZE = 32
```

「WARNING: The TensorFlow contrib module will not be included in TensorFlow 2.0.」といったTensorFlowからの警告が出るが気にしなくてよい。

#### 3. Generatorの宣言

Generator(偽造者)の宣言を行う

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

#### 4. Discriminatorの宣言

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

#### 5. データセットの準備

データを受け取って、バッチとして返す関数を作成する。ここでは、「本物」のデータを作成する。

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

#### 6. データセットのダウンロード

データセットをダウンロードしよう。データセットは以下の三種類を用意してある。

* `mnist.tfrecord` 手書きの数字(MNIST)
* `hiragana.tfrecord` ひらがなすべて(IPAゴシックフォント)
* `fontawesome.tfrecord` Font Awesomeというフォントのシンボルアイコン10種類

上記のうち、好きなものを一つ選んで`TRAIN_DATA`とすること。以下はMNISTを選んだ場合の例である。

```py
TRAIN_DATA = "mnist.tfrecord"
url="https://kaityo256.github.io/simple_tfgan/dataset/"
file=url+TRAIN_DATA
!wget $file
```

上記を実行すると、ファイルがダウンロードされる。最後に以下のような表示がされたら成功である。

```sh
2019-05-31 08:03:55 (138 MB/s) - ‘mnist.tfrecord’ saved [20852051/20852051]
```

#### 7. 初期化

TensorFlowを初期化し、データをバッチに変換する。

```py
tf.reset_default_graph()
with tf.device('/cpu:0'):
  real_images = provide_data(TRAIN_DATA, BATCH_SIZE)
```

#### 8. GANの宣言

これまで宣言した「Generator」と「Discriminator」を競争させるGANを宣言する。

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

#### 9. GANの実行

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
