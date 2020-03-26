import matplotlib.pyplot as plt
import numpy as np
import tensorflow as tf

tf.logging.set_verbosity(tf.logging.ERROR)


def generator_fn(noise, weight_decay=2.5e-5, is_training=True):
    layers = tf.contrib.layers
    framework = tf.contrib.framework
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


def discriminator_fn(img, _, weight_decay=2.5e-5, is_training=True):
    layers = tf.contrib.layers
    framework = tf.contrib.framework
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


def provide_data(source, batch_size):
    slim = tf.contrib.slim
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
    dataprovider = slim.dataset_data_provider.DatasetDataProvider
    reader = tf.TFRecordReader
    dataset = slim.dataset.Dataset(source, reader, decoder, datanum, None)
    provider = dataprovider(dataset, shuffle=True)
    image, = provider.get(['image'])
    image = (tf.cast(image, tf.float32) - 128.0) / 128.0
    images = tf.train.batch([image], batch_size=batch_size)
    return images


def run_gan(TRAIN_DATA, TOTAL_STEPS=400):
    BATCH_SIZE = 32
    TOTAL_STEPS += 1
    tfgan = tf.contrib.gan
    tf.reset_default_graph()
    with tf.device('/cpu:0'):
        real_images = provide_data(TRAIN_DATA, BATCH_SIZE)

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


#filename = "mnist.tfrecord"
#filename = "hiragana.tfrecord"
# run_gan(filename)
