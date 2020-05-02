#Script for downloading all necessary data from the original sources. Code by Matthias Gansen


#necessary librarys
library(readxlsb)
library(readxl)
library(rio)
library(tidyverse)
library(readr)
library(rgdal)
library(geojsonio)
library(rmapshaper)
library(geojsonR)

# set working directory to current file
if(Sys.getenv("RSTUDIO") == "1"){
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

# create data directory
dir.create("data")

#download all data from the Pendleratlas

##Baden-Württemberg
saveBW=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-08-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveBW)
##Bayern
saveBY=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-09-0-201912-zip.zip",destfile = temp)
unzip(temp,exdir = saveBY)
##Berlin
saveBE=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-11-0-201912-zip.zip",destfile = temp)
unzip(temp,exdir = saveBE)
##Brandenburg
saveBB=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-12-0-201912-zip.zip",destfile = temp)
unzip(temp,exdir = saveBB)
##Bremen
saveHB=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-04-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveHB)
##Hamburg
saveHH=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-02-0-201912-zip.zip",destfile = temp)
unzip(temp,exdir = saveHH)
##Mecklenburg-Vorpommern
saveMV=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-13-0-201912-zip.zip",destfile = temp)
unzip(temp,exdir = saveMV)
##Hessen
saveHE=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-03-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveHE)
##Niedersachsen
saveNI=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-06-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveNI)
##Nordrhein-Westfalen
saveNW=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-05-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveNW)
##Rheinland-Pfalz
saveRP=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-07-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveRP)
##Saarland
saveSL=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-10-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveSL)
##Sachsen
saveSN=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-14-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveSN)
##Sachsen-Anhalt
saveST=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-15-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveST)
##Schleswig-Holstein
saveSH=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-01-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveSH)
##Thüringen
saveTH=paste(getwd(),"/data/commutes",sep="")
temp=tempfile()
download.file("https://statistik.arbeitsagentur.de/Statistikdaten/Detail/201912/iiia6/beschaeftigung-sozbe-krpend/krpend-16-0-201912-zip.zip",destfile=temp)
unzip(temp,exdir = saveTH)

#preprocess data from the pendleratlas

##load_data
cols=c("HOME_KRS","HOME_KRS_NAME","WORK_KRS","WORK_KRS_NAME","TOTAL","M","F","GER","For","App","")
pend_SH <- read_xlsb("data/commutes/krpend_01_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_HH <- read_xlsb("data/commutes/krpend_02_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_NI <- read_xlsb("data/commutes/krpend_03_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_HB <- read_xlsb("data/commutes/krpend_04_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_NW <- read_xlsb("data/commutes/krpend_05_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_HE <- read_xlsb("data/commutes/krpend_06_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_RP <- read_xlsb("data/commutes/krpend_07_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_BW <- read_xlsb("data/commutes/krpend_08_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_BY <- read_xlsb("data/commutes/krpend_09_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_SL <- read_xlsb("data/commutes/krpend_10_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_BE <- read_xlsb("data/commutes/krpend_11_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_BB <- read_xlsb("data/commutes/krpend_12_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_MV <- read_xlsb("data/commutes/krpend_13_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_SN <- read_xlsb("data/commutes/krpend_14_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_ST <- read_xlsb("data/commutes/krpend_15_0.xlsb",sheet=3,col_names = cols, skip=8)
pend_TH <- read_xlsb("data/commutes/krpend_16_0.xlsb",sheet=3,col_names = cols, skip=8)

## fill HOME_KRS collums
fill_HOME_KRS=function(state){
  state [state==""] <- NA
  state=as.data.frame(state)
  x=filter(state, !is.na(state$HOME_KRS) | !is.na(state$WORK_KRS))
  n=nrow(x)
  rownames=c(1:n)
  z=1
  while (z < n+1){
    if (is.na(x$HOME_KRS[z+1])) {
      cur_town=z  #indize of to-be-copied town name
      z=z+1
      print(cur_town)  #checking if the correct town has been choosen
    } else {
      z=z+1
    }
    
    while (is.na(x$HOME_KRS[z]) & z<n+1){  #fill in town_code and town_name
      x$HOME_KRS[z]=x$HOME_KRS[cur_town]
      x$HOME_KRS_NAME[z]= x$HOME_KRS_NAME[cur_town]
      z=z+1
    }
  }
  x=filter(x,!is.na(x$WORK_KRS)) #filtering out collums with only town_id and town_name
  x
}

pendBB=fill_HOME_KRS(pend_BB)
export(pendBB,file="data/commutes/krpend_12_0.csv",format=";")

pendSH=fill_HOME_KRS(pend_SH)
export(pendSH,file="data/commutes/krpend_01_0.csv", format = ";")

pendHH=fill_HOME_KRS(pend_HH)
export(pendHH,file="data/commutes/krpend_02_0.csv", format = ";")

pendNI=fill_HOME_KRS(pend_NI)
export(pendNI,file="data/commutes/krpend_03_0.csv", format = ";")

pendHB=fill_HOME_KRS(pend_HB)
export(pendHB,file="data/commutes/krpend_04_0.csv", format = ";")

pendNW=fill_HOME_KRS(pend_NW)
export(pendNW,file="data/commutes/krpend_05_0.csv", format = ";")

pendHE=fill_HOME_KRS(pend_HE)
export(pendHE,file="data/commutes/krpend_06_0.csv", format = ";")

pendRP=fill_HOME_KRS(pend_RP)
export(pendRP,file="data/commutes/krpend_07_0.csv", format = ";")

pendBW=fill_HOME_KRS(pend_BW)
export(pendBW,file="data/commutes/krpend_08_0.csv", format = ";")

pendBY=fill_HOME_KRS(pend_BY)
export(pendBY,file="data/commutes/krpend_09_0.csv", format = ";")

pendSL=fill_HOME_KRS(pend_SL)
export(pendSL,file="data/commutes/krpend_10_0.csv", format = ";")

pendBE=fill_HOME_KRS(pend_BE)
export(pendBE,file="data/commutes/krpend_11_0.csv", format = ";")

pendMV=fill_HOME_KRS(pend_MV)
export(pendMV,file="data/commutes/krpend_13_0.csv", format = ";")

pendSN=fill_HOME_KRS(pend_SN)
export(pendSN,file="data/commutes/krpend_14_0.csv", format = ";")

pendST=fill_HOME_KRS(pend_ST)
export(pendST,file="data/commutes/krpend_15_0.csv", format = ";")

pendTH=fill_HOME_KRS(pend_TH)
export(pendTH,file="data/commutes/krpend_16_0.csv", format = ";")




# Download Kreisnummern

data = rio::import("https://www.destatis.de/DE/Themen/Laender-Regionen/Regionales/Gemeindeverzeichnis/Administrativ/Archiv/Standardtabellen/04_KreiseVorjahr.xlsx?__blob=publicationFile", sheet=2)
dir.create("data/census")
export(data,file="data/census/Kreisnummern.csv",format = ";")



# Download Airtravel data (only airtravel within Germany)

## import relevant data
airtravel= rio::import("https://www.destatis.de/DE/Themen/Branchen-Unternehmen/Transport-Verkehr/Personenverkehr/Publikationen/Downloads-Luftverkehr/luftverkehr-ausgewaehlte-flugplaetze-2080610197005.xlsx?__blob=publicationFile", sheet = "1.3.2" )
airtravel=airtravel[37:684,]
airtravel=airtravel[,1:5]
colnames(airtravel)=c("start_airport","dest_airport","flights_per_year","kmflights","total_passengers_per_year")

### import matching file
# Airport_closest_city=read.csv2(file = "data/airtravel/Airport_closest_city.csv", header = TRUE, sep=";", encoding = "UTF-8")
# colnames(Airport_closest_city)=c("Airport","closest_city_name","closest_city_code")
# Airport_closest_city$Airport=as.character(Airport_closest_city$Airport)
Airport_closest_city <- read_delim("data/airtravel/Airport_closest_city.csv",   ";", escape_double = FALSE, col_types = cols(Airport = col_character(),  closest_city_code = col_character(),    closest_city_name = col_character()),  trim_ws = TRUE)

## adding columms
n=nrow(airtravel)
start_closest_city_name=c(rep(NA,n))
start_closest_city_code=c(rep(NA,n))
dest_closest_city_name=c(rep(NA,n))
dest_closest_city_code=c(rep(NA,n))
avg_passengers_per_day=c(rep(NA,n))
airtravel=cbind(airtravel,start_closest_city_name,start_closest_city_code,dest_closest_city_name, dest_closest_city_code,avg_passengers_per_day)
airtravel=select(airtravel,start_airport,start_closest_city_name,start_closest_city_code,dest_airport,dest_closest_city_name,dest_closest_city_code,flights_per_year,avg_passengers_per_day,total_passengers_per_year)

## filling data

### matchfunction
match_closest_city=function(airdata,matchfile){

  n=nrow(airdata)
  m=nrow(matchfile)  #matchingfile
  for(i in 0:n){
    for(j in 0:m){  #matching start airports
      if (identical(airdata$start_airport[i],matchfile$Airport[j])){
        airdata$start_closest_city_name[i] =matchfile$closest_city_name[j]
        airdata$start_closest_city_code[i] =matchfile$closest_city_code[j]
      }
    }
    for(k in 0:m){ #matching destination airports
      if (identical(airdata$dest_airport[i],matchfile$Airport[k])){
        airdata$dest_closest_city_name[i] =matchfile$closest_city_name[k]
        airdata$dest_closest_city_code[i] =matchfile$closest_city_code[k]
      }
    }
    
  }
  airdata
}

## calculating passengers per day
airtravel$avg_passengers_per_day=ceiling(as.numeric(airtravel$total_passengers_per_year)/365)

## matching
airtravel=match_closest_city(airtravel,Airport_closest_city)
airtravel=filter(airtravel,!is.na(start_airport))

## save airtravel data
airtravel [airtravel==""] <- NA
export(airtravel,file="data/airtravel/Flugdaten_2019.csv",format = ";",row.names=TRUE)

# RKI Data

dir.create("data/cases")
##save "RKI_COVID19.csv"
#download.file("https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv", destfile="data/cases/RKI_COVID19.csv")
RKI_COVID19=rio::import("https://opendata.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0.csv", colClasses = c("Meldedatum" = "character",
                                                                                                         "IdLandkreis" = "character",
                                                                                                         "Landkreis" = "character",
                                                                                                         "AnzahlFall" = "numeric"))
RKI_COVID19=select(RKI_COVID19,IdBundesland,Bundesland,Landkreis,Altersgruppe,Geschlecht,AnzahlFall,AnzahlTodesfall,Meldedatum,IdLandkreis,Datenstand,NeuerFall,NeuerTodesfall,Refdatum,NeuGenesen,AnzahlGenesen)
export(RKI_COVID19,file="data/cases/RKI_COVID19.csv",format = ",")


# geoshapes
dir.create("data/geo")
dir.create("data/geo/json")
dir.create("data/geo/shp")

##json
download.file("https://public.opendatasoft.com/explore/dataset/landkreise-in-germany/download/?format=json&timezone=Europe/Berlin&lang=en", destfile = "data/geo/json/landkreise-in-germany.json")

##geojson
download.file("https://public.opendatasoft.com/explore/dataset/landkreise-in-germany/download/?format=geojson&timezone=Europe/Berlin&lang=en", destfile =  "data/geo/json/landkreise-in-germany.geojson")

##shapefiles
temp_geo=tempfile()
download.file("https://public.opendatasoft.com/explore/dataset/landkreise-in-germany/download/?format=shp&timezone=Europe/Berlin&lang=en",destfile =temp_geo , mode = "wb")
unzip(temp_geo,exdir = "data/geo/shp")


##building smaller data set
###load full data set

german_districts_large <- geojson_read("data/geo/json/landkreise-in-germany.geojson", what = "sp")
###simplify map (speeds up visualization)
german_districts <-  ms_simplify(german_districts_large, keep = 0.02)

###saving the file
geojson_write(german_districts,file= "data/geo/json/landkreise-in-germany_small.geojson")





