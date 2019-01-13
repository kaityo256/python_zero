TARGET=$(shell ls */README.md | sed 's/README.md/index.html/')

all: $(TARGET)

%/index.html: %/README.md
	pandoc -s --mathjax $< -o $@
