from collections import defaultdict
import io
import re
import urllib.request
from zipfile import ZipFile

import MeCab


def loadfromurl(url):
    data = urllib.request.urlopen(url).read()
    zipdata = ZipFile(io.BytesIO(data))
    filename = zipdata.namelist()[0]
    text = zipdata.read(filename).decode("shift-jis")
    text = re.sub(r'［.+?］', '', text)
    text = re.sub(r'《.+?》', '', text)
    return text


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


#URL = "https://www.aozora.gr.jp/cards/000119/files/624_ruby_5668.zip"  # 山月記
URL = "https://www.aozora.gr.jp/cards/000119/files/621_ruby_661.zip"  # 名人伝
download_text = loadfromurl(URL)
show_top10(download_text)
