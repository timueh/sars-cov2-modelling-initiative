RTEXS := $(wildcard *.Rtex)
TEXS := $(patsubst %.Rtex, %.tex, $(RTEXS))
PDFS := $(patsubst %.tex, %.pdf, $(TEXS))

tex: $(TEXS)

pdf: tex $(PDFS)

.PHONY: tex pdf clean

$(TEXS): %.tex : %.Rtex
	echo "library(\"knitr\"); knit(\"$<\")" | R --no-save --no-restore

$(PDFS): %.pdf : %.tex
	# pandoc -s --filter pandoc-citeproc --filter pandoc-citeproc-preamble $< -o $@
	pdflatex $<
	bibtex $*
	pdflatex $<
	pdflatex $<


clean:
	rm -rf  *.npz *.aux *.bbl *.blg *.log *.out *.thm *.toc *.tex *.pdf figure
