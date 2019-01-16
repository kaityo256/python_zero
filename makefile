TARGET=$(shell ls */README.md | sed 's/README.md/index.html/')
CSS=https://cdn.jsdelivr.net/npm/@ajusa/lit@latest/dist/lit.css
PANDOC=pandoc -s --mathjax -t html --template=template

all: $(TARGET) index.html

index.html: README.md
	sed 's/README.md/index.html/' README.md > index.md
	$(PANDOC) index.md -o $@
	rm -f index.md


%/index.html: %/README.md
	$(PANDOC) $< -o $@

clean:
	rm -f $(TARGET) index.html
