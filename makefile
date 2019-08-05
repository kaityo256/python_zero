TARGET=$(shell ls */README.md | sed 's/README.md/index.html/')
PANDOC=pandoc -s --mathjax -t html --template=template

all: $(TARGET) index.html

index.html: README.md
	sed 's/README.md/index.html/' README.md > index.md
	$(PANDOC) index.md -o $@
	rm -f index.md


%/index.html: %/README.md
	gsed '2a [[Up]](../index.html)' $< > index.md
	gsed -i '3a [[Repository]](https://github.com/kaityo256/python_zero)\n' index.md
	$(PANDOC) index.md -o $@

clean:
	rm -f $(TARGET) index.html
