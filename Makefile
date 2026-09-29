INDEX=$(shell ls */README.md | sed 's/README.md/index.html/')
PANDOC_HTMLOPT=--mathjax -t html --template=template
PANDOC_TEXOPT=--highlight-style tango --pdf-engine=lualatex -V documentclass=ltjarticle -V geometry:margin=1in -H ../mytemplate.tex
TARGET=$(INDEX)
ASSIGNMENT=$(shell grep --exclude=answer/*.md -l ^\#.*課題 */README.md | sed 's/README.md/assignment.pdf/')

all: $(TARGET) index.html

pdf: $(ASSIGNMENT)

index.md: README.md
	sed 's/README.md/index.html/' $< > $@

index.html: index.md
	pandoc -s $< -o $@ $(PANDOC_HTMLOPT) --shift-heading-level-by=-1 
	rm -f index.md 

%/index.md: %/README.md
	sed '2a [[Up]](../index.html)' $< > $@
	sed -i '3a [[Repository]](https://github.com/kaityo256/python_zero)\n' $@

%/index.html: %/index.md
	pandoc -s $< -o $@ $(PANDOC_HTMLOPT) --shift-heading-level-by=-1 

errata/index.html: errata/README.md
	pandoc -s $< -o $@ $(PANDOC_HTMLOPT)  --shift-heading-level-by=-1 
	sed -i 's/style=\"width:17%;\"//' $@ 

%/assignment.md: %/README.md
	sed -n '/^##\s.*課題/,$$p' $< > $@

%/assignment.pdf: %/assignment.md
	cd $(dir $@);pandoc $(notdir $<) -s -o $(notdir $@) $(PANDOC_TEXOPT)

copy-pdf: $(ASSIGNMENT)
	cp hello/assignment.pdf assignment01.pdf
	cp basic/assignment.pdf assignment02.pdf
	cp scope/assignment.pdf assignment03.pdf
	cp list/assignment.pdf assignment04.pdf
	cp string/assignment.pdf assignment05.pdf
	cp file/assignment.pdf assignment06.pdf
	cp recursion/assignment.pdf assignment07.pdf
	cp class/assignment.pdf assignment08.pdf
	cp numpy/assignment.pdf assignment09.pdf
	cp howtowork/assignment.pdf assignment10.pdf
	cp dp/assignment.pdf assignment11.pdf
	cp random/assignment.pdf assignment12.pdf
	cp simulation/assignment.pdf assignment13.pdf
	cp ml/assignment.pdf assignment14.pdf

copy-pptx: 
	cp hello/fig/slide.pptx python01.pptx
	cp basic/fig/slide.pptx python02.pptx
	cp scope/fig/slide.pptx python03.pptx
	cp list/fig/slide.pptx python04.pptx
	cp string/fig/slide.pptx python05.pptx
	cp file/fig/slide.pptx python06.pptx
	cp recursion/fig/slide.pptx python07.pptx
	cp class/fig/slide.pptx python08.pptx
	cp numpy/fig/slide.pptx python09.pptx
	cp howtowork/fig/slide.pptx python10.pptx
	cp dp/fig/slide.pptx python11.pptx
	cp random/fig/slide.pptx python12.pptx
	cp simulation/fig/slide.pptx python13.pptx
	cp ml/fig/slide.pptx python14.pptx



clean-pdf:
	rm -f $(ASSIGNMENT)

clean:
	rm -f $(TARGET) index.html
