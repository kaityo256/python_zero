import numpy as np
import tensorflow as tf

fashion_mnist = tf.keras.datasets.fashion_mnist
(train_images, _), _ = fashion_mnist.load_data()
train_images = train_images[:10000,:,:]
np.save("fashion-mnist", train_images)

mnist = tf.keras.datasets.mnist
(train_images, _), _ = mnist.load_data()
train_images = train_images[:10000,:,:]
np.save("mnist", train_images)
