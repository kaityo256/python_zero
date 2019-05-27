# encoding: utf-8

def str2b(c)
  c2 = c
  s = ""
  8.times do
    s = (c & 1).to_s + s
    c >>= 1
  end
  s = c2.to_s(16) + ":" + s
  s
end

def show(str, encode)
  puts(encode)
  a = str.encode(encode).unpack("C*")
  a.each do |c|
    puts str2b(c)
  end
  puts
end

show("表1","Shift_JIS")
show("表1","EUC-JP")
show("表1","ISO-2022-JP")
