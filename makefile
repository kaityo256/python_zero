TARGET=$(shell ls */README.md | sed 's/README.md/index.html/')

all: $(TARGET) index.html

index.html: README.md
	sed 's/README.md/index.html/' README.md > index.md
	pandoc -s --mathjax $< -o $@


%/index.html: %/README.md
	pandoc -s --mathjax $< -o $@
