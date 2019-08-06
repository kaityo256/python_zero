INDEX=$(shell ls */README.md | sed 's/README.md/index.html/')
PANDOC=pandoc -s --mathjax -t html --template=template
PANDOC_TEXOPT=--highlight-style tango --latex-engine=lualatex -V documentclass=ltjarticle -V geometry:margin=1in 
TARGET=$(INDEX)
ASSIGNMENT=string/assignment.pdf

pdf: $(ASSIGNMENT)

all: $(TARGET) index.html

index.md: README.md
	sed 's/README.md/index.html/' $< > $@
	gsed -i 's/assignment.md/assignment.html/' $@

index.html: index.md
	$(PANDOC) $< -o $@
	rm -f index.md 

%/index.md: %/README.md
	gsed '2a [[Up]](../index.html)' $< > $@
	gsed -i '3a [[Repository]](https://github.com/kaityo256/python_zero)\n' $@
	gsed -i 's/assignment.md/assignment.html/' $@ 

%/index.html: %/index.md
	$(PANDOC) $< -o $@

%/assignment.md: %/README.md
	gsed -n '/^#\s.*課題/,$$p' $< > $@

%/assignment.pdf: %/assignment.md
	pandoc $< -s -o $@ -o $@ $(PANDOC_TEXOPT)

clean:
	rm -f $(TARGET) index.html
