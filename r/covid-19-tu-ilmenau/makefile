all: index.html germany.html all.html impressum.html

.PHONY: all index.html germany.html all.html

index.html: index.Rmd impressum.html
	Rscript -e "rmarkdown::render('index.Rmd')"

germany.html: germany.Rmd impressum.html
	Rscript -e "rmarkdown::render('germany.Rmd')"

all.html: all.Rmd impressum.html
	Rscript -e "rmarkdown::render('all.Rmd')"

impressum.html: impressum.md
	pandoc -s impressum.md -o impressum.html

dependencies: install_dependencies.r
	Rscript install_dependencies.r

#index.Rmd: data/clean/data_ger_bundl.csv
	#cd data; make all
