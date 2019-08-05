INDEX=$(shell ls */README.md | sed 's/README.md/index.html/')
ASSIGNMENT=$(shell ls */assignment.md | sed 's/assignment.md/assignment.html/')
PANDOC=pandoc -s --mathjax -t html --template=template
TARGET=$(INDEX) $(ASSIGNMENT)


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

%/assignment.html: %/assignment.md
	$(PANDOC) $< -o $@

clean:
	rm -f $(TARGET) index.html
