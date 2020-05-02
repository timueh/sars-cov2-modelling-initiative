all: johns_hopkins get_rki clean_data

.PHONY: johns_hopkins get_rki clean_data clean

johns_hopkins:
	if [ ! -d johns_hopkins ] ; then  git clone https://github.com/CSSEGISandData/COVID-19 johns_hopkins; fi
	cd johns_hopkins; git pull origin master

d=`date +%Y-%m-%d`
get_rki:
	mkdir -p rki_data
	# csv seems unreliable use arcgis query api instead
	#cd rki_data; wget -O RKI_COVID19_$d.csv https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv
	python3 rki_query.py
	cd rki_data; mv RKI_COVID19.csv RKI_COVID19_$d.csv

clean_data:
	mkdir -p clean
	Rscript --verbose clean.r

clean:
	rm -rf clean rki_data
