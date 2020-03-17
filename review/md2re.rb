require "redcarpet"
require "redcarpet/render/review"

render = Redcarpet::Render::ReVIEW.new
mk = Redcarpet::Markdown.new(render)

def escape_underscore(str)
  str.gsub("_", "@<underscore>")
end

def escape_inline_math(str)
  while str =~ /\$(.*?)\$/
    math = escape_underscore($1)
    str = $` + "@<m>|" + math + "|" + $'
  end
  str
end

def convert2re(str, mkrender)
  str = escape_inline_math(str)
  str = mkrender.render(str)
  str.gsub("@<underscore>", "_")
end

def in_block
  while (line=gets)
    if line=~/```/
      puts "//}"
      return
    end
    print line
  end
end

def in_math
  while (line = gets)
    if line=~/\$\$/
      puts "//}"
      return
    end
    print line
  end
end

lines = ""
yodan = false
while (line=gets)
  if line=~/```(.*)$/
    print convert2re(lines, mk)
    lines = ""
    puts "//emlist[][#{$1}]{"
    in_block
  elsif line=~/\$\$/
    print convert2re(lines, mk)
    lines = ""
    puts "//texequation{"
    in_math
  elsif line=~/^## 余談：(.*)/
    print convert2re(lines, mk)
    lines = ""
    yodan = true
    puts "//memo[#{$1}]{"
  else
    lines += line
  end
end
print mk.render(lines)

puts "//}" if yodan
