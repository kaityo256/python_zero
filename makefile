INDEX=$(shell ls */README.md | sed 's/README.md/index.html/')
PANDOC_HTMLOPT=--mathjax -t html --template=template
PANDOC_TEXOPT=--highlight-style tango --latex-engine=lualatex -V documentclass=ltjarticle -V geometry:margin=1in -H ../mytemplate.tex
TARGET=$(INDEX)
ASSIGNMENT=$(shell grep --exclude=answer/*.md -l ^\#.*課題 */README.md | sed 's/README.md/assignment.pdf/')

all: $(TARGET) index.html

pdf: $(ASSIGNMENT)

index.md: README.md
	sed 's/README.md/index.html/' $< > $@
	sed -i 's/assignment.md/assignment.html/' $@

index.html: index.md
	pandoc -s $< -o $@ $(PANDOC_HTMLOPT)
	rm -f index.md 

%/index.md: %/README.md
	sed '2a [[Up]](../index.html)' $< > $@
	sed -i '3a [[Repository]](https://github.com/kaityo256/python_zero)\n' $@
	sed -i 's/assignment.md/assignment.html/' $@ 

%/index.html: %/index.md
	pandoc -s $< -o $@ $(PANDOC_HTMLOPT)

errata/index.html: errata/README.md
	pandoc -s $< -o $@ $(PANDOC_HTMLOPT)
	sed -i 's/style=\"width:17%;\"//' $@ 

%/assignment.md: %/README.md
	sed -n '/^##\s.*課題/,$$p' $< > $@

%/assignment.pdf: %/assignment.md
	cd $(dir $@);pandoc $(notdir $<) -s -o $(notdir $@) $(PANDOC_TEXOPT)

clean-pdf:
	rm -f $(ASSIGNMENT)

clean:
	rm -f $(TARGET) index.html
