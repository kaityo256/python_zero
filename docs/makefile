PANDOC=pandoc --self-contained -s --mathjax=https://gist.githubusercontent.com/yohm/0c8ed72b6f18948a2fd3/raw/624defc8ffebb0934ab459854b7b3efc563f6efb/dynoload.js -c https://gist.githubusercontent.com/griffin-stewie/9755783/raw/13cf5c04803102d90d2457a39c3a849a2d2cc04b/github.css

TARGET=$(shell ls ../*/README.md | sed 's/\/README.md/.html/' | sed 's/..\///')

all: $(TARGET) index.html


index.html: ../README.md
	sed 's/\/README.md/.html/' ../README.md > index.md
	$(PANDOC) index.md -o index.html
	rm -f index.md

%.html: ../%/README.md
	cd ../$*;$(PANDOC) $< -o ../docs/$@


.PHONY: clean

clean:
	rm -f $(TARGET) index.html
