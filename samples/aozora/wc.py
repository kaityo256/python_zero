# For Google Colab
#!apt install aptitude
#!aptitude install mecab libmecab-dev mecab-ipadic-utf8 git make curl xz-utils file -y
#!pip install mecab-python3==0.7
#!apt-get -y install fonts-ipafont-gothic

import io
import re
import urllib.request
from zipfile import ZipFile

import IPython
import MeCab
from wordcloud import WordCloud


def loadfromurl(url):
    data = urllib.request.urlopen(url).read()
    zipdata = ZipFile(io.BytesIO(data))
    filename = zipdata.namelist()[0]
    text = zipdata.read(filename).decode("shift-jis")
    text = re.sub(r'［.+?］', '', text)
    text = re.sub(r'《.+?》', '', text)
    return text


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


#URL = "https://www.aozora.gr.jp/cards/000119/files/621_ruby_661.zip"
URL = "https://www.aozora.gr.jp/cards/000119/files/624_ruby_5668.zip"

# for Google Colab
# fpath='/usr/share/fonts/opentype/ipafont-gothic/ipagp.ttf'

# For Mac
fpath = "/System/Library/Fonts/ヒラギノ丸ゴ ProN W4.ttc"

download_text = loadfromurl(URL)
words = get_words(download_text)
wc = WordCloud(background_color="white", width=480,
               height=320, font_path=fpath)
wc.generate(words)
wc.to_file("wc.png")
# For Google Colab
IPython.display.Image("wc.png")
