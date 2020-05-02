## COVID-19 German forecasting tool
## Johannes Ponge, Till Sahlmüller European Research Center for Information Systems (ERCIS) at Muenster University (johannes.ponge@uni-muenster.de), March 2020

## includes code adapted from the following sources:
#https://github.com/eparker12/nCoV_tracker/

# load required packages
library(sf)
library(ggplot2)
library(dplyr)
library(data.table)
library(stringr)
library(rstudioapi)
library(lubridate)

# set working directory to current file
if(Sys.getenv("RSTUDIO") == "1"){
  setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
}

### POPULATION DATA ###

# census
census <- read.csv("data/census/Kreisnummern.csv", sep = ";",skip = 8,header = FALSE, colClasses=c(rep("character", 5), "numeric", rep(NA,34)), encoding = "UTF-8")

# filter census for counties
district_data <- census %>%
  filter(nchar(V1) == 5) %>%
  select(V1, V3, V6)
colnames(district_data) = c("ags", "ags_name", "population")

### COMMUTING DATA ###

# custom import function for data separating 1k with commas
setClass("num.with.commas")
setAs("character", "num.with.commas", 
      function(from) as.numeric(gsub(",", "", from)))

# function to load commute statistics from Agentur fuer Arbeit
load_commutes = function(){
  pend_SH <- read.csv("data/commutes/krpend_01_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_HH <- read.csv("data/commutes/krpend_02_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_NI <- read.csv("data/commutes/krpend_03_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_HB <- read.csv("data/commutes/krpend_04_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_NW <- read.csv("data/commutes/krpend_05_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_HE <- read.csv("data/commutes/krpend_06_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_RP <- read.csv("data/commutes/krpend_07_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_BW <- read.csv("data/commutes/krpend_08_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_BY <- read.csv("data/commutes/krpend_09_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_SL <- read.csv("data/commutes/krpend_10_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_BE <- read.csv("data/commutes/krpend_11_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_BB <- read.csv("data/commutes/krpend_12_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_MV <- read.csv("data/commutes/krpend_13_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_SN <- read.csv("data/commutes/krpend_14_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_ST <- read.csv("data/commutes/krpend_15_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  pend_TH <- read.csv("data/commutes/krpend_16_0.csv", sep = ";", colClasses=c(rep("character",4), rep("num.with.commas",6)), encoding = "UTF-8", fileEncoding="latin1")
  
  # remove row numbers if present (first column)
  pend_SH <- pend_SH %>% select(-X)
  pend_HH <- pend_HH %>% select(-X)
  pend_NI <- pend_NI %>% select(-X)
  pend_HB <- pend_HB %>% select(-X)
  pend_NW <- pend_NW %>% select(-X)
  pend_HE <- pend_HE %>% select(-X)
  pend_RP <- pend_RP %>% select(-X)
  pend_BW <- pend_BW %>% select(-X)
  pend_BY <- pend_BY %>% select(-X)
  pend_SL <- pend_SL %>% select(-X)
  pend_BE <- pend_BE %>% select(-X)
  pend_BB <- pend_BB %>% select(-X)
  pend_MV <- pend_MV %>% select(-X)
  pend_SN <- pend_SN %>% select(-X)
  pend_ST <- pend_ST %>% select(-X)
  pend_TH <- pend_TH %>% select(-X)
  
  # combine all commute (travel) statistics
  commutes <- rbind(pend_SH, pend_HH, pend_NI, pend_HB,
                    pend_NW, pend_HE, pend_RP, pend_BW,
                    pend_BY, pend_SL, pend_BE, pend_BB,
                    pend_MV, pend_SN, pend_ST, pend_TH)
  
  # filter for empty rows & non-county entries
  commutes <- commutes %>%
    filter(as.numeric(TOTAL) >= 0) %>%
    filter(nchar(WORK_KRS) == 5) %>% # counties have a 5-digit identifier
    select(HOME_KRS, WORK_KRS, TOTAL)
  colnames(commutes) = c("ags_origin", "ags_destination", "travelers")
  
  commutes
}

#load commutes
commutes_data = suppressWarnings(load_commutes())

### AIRTRAVEL DATA ###

# airport data
air_data <- read.csv("data/airtravel/Flugdaten_2019.csv",header = TRUE, sep = ";", colClasses = c("start_closest_city_code" = "character",
                                                                                                  "dest_closest_city_code" = "character"),
                     encoding = "UTF-8")

air_data = air_data %>% 
  filter(nchar(dest_closest_city_code) == 5) %>%
  filter(!is.na(avg_passengers_per_day)) %>%
  filter(start_closest_city_code != dest_closest_city_code) %>%
  filter((start_closest_city_code %in% district_data$ags) && (dest_closest_city_code %in% district_data$ags)) %>%
  select(start_closest_city_code, dest_closest_city_code, avg_passengers_per_day) %>%
  rename(ags_origin = start_closest_city_code) %>%
  rename(ags_destination = dest_closest_city_code) %>%
  rename(travelers = avg_passengers_per_day) %>%
  unique() %>%
  filter(ags_origin %in% district_data$ags) %>%
  filter(ags_destination %in% district_data$ags)


### TRAINTRAVEL DATA ###

# TO BE DONE


### INFECTION DATA ###

# load empirical cases from official RKI csv file
# https://npgeo-corona-npgeo-de.hub.arcgis.com/datasets/dd4580c810204019a7b8eb3e0b329dd6_0/data
load_covid_cases_RKI <- function(){
  
  #covid_cases <- read.csv2("data/cases/RKI_COVID19.csv", sep = ",", colClasses = c(rep("character", 5), rep("numeric", 3), rep("character", 3), rep("numeric", 2)), encoding = "UTF-8")
  covid_cases <- read.csv2("data/cases/RKI_COVID19.csv", sep = ",", colClasses = c("Meldedatum" = "character",
                                                                                   "IdLandkreis" = "character",
                                                                                   "Landkreis" = "character",
                                                                                   "AnzahlFall" = "numeric"),
                           encoding = "UTF-8")
  
    # avg time it takes to recover
  recovery_duration = 15
  
  covid_cases <- covid_cases %>%
    mutate(date = as.POSIXct(Meldedatum)) %>%
    rename(ags = IdLandkreis) %>%
    # aggregate Berlin data (this is treated as 12 individual districts, while other statistics only have Berlin as one entity)
    mutate(ags = replace(ags, grepl("11[0-9]{3}", ags), "11000")) %>%
    rename(ags_name = Landkreis) %>%
    rename(new_infections = AnzahlFall) %>%
    filter(new_infections >= 0) %>%
    group_by(date, ags, ags_name) %>%
    summarize(new_infections = sum(new_infections)) %>%
    ungroup()
  
  min_date = min(covid_cases$date)
  max_date = max(covid_cases$date)
  
  covid_cases = covid_cases %>%
    mutate(day = yday(date) - yday(min_date) + 1) %>%
    mutate(new_recoveries = 0) %>%
    select(date, day, ags, ags_name, new_infections, new_recoveries)
  
  recovered_cases = covid_cases %>%
    mutate(date = date + days(recovery_duration)) %>%
    mutate(day = day + recovery_duration) %>%
    mutate(new_recoveries = new_infections) %>%
    mutate(new_infections = 0) %>%
    select(date, day, ags, ags_name, new_infections, new_recoveries)
  
  covid_cases = rbind(covid_cases, recovered_cases) %>%
    group_by(date, day, ags, ags_name) %>%
    summarize(new_infections = sum(new_infections), new_recoveries = sum(new_recoveries)) %>%
    filter(date <= max_date) %>%
    arrange(day)

  covid_cases
}


# load empirical cases from ODS file
covid_cases <- load_covid_cases_RKI()

