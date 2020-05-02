library(lubridate, warn.conflicts=FALSE)
today <- today()

## script for preprocessing data ===============================================
#
# 1) generate cleaned data frames for all available regions
#    with all available factors and uniform naming conventions
#
# 2) generate aggregated data frames from 1) for availiable
#    region - sub-region combinations
#    e.g. region: "italy"        - sub-regions: "regions"
#         region: "italy"        - sub-regions: "provinces"
#         region: "Deutschland"  - sub-regions: "Bundeslaender"
#         region: "Deutschland"  - sub-regions: "Lanndkreise"
#
# 3) generates lookup tables for regions: regX.id - regX.name
#    with (optional) meta data: lat, long, population, area, ...
#
# uniform column names: (not all factors are always available)
# time:  day (counter starting at 0), yday, date
# space: reg0.id, reg0.name, reg1.id, reg1.name, ... (so far no reg2)
# case:  tot.cases, new.cases,
#        tot.dead, new.dead,
#        tot.recovered, new.recovered,
#        tot.tested, new.tested
# meta:  age, sex, ...
#
## =============================================================================


## 1) region: germany; all data ================================================
#
# this data.frame does NOT contain ALL combinations of factors !
# and they are not completed either since too many combinations...
# all combinations only in derived data frames (see below)
#
ger_today <- read.csv(paste0('./rki_data/RKI_COVID19_', today, '.csv'))
# test if all Bundeslaender are available:
if (length(unique(ger_today$IdBundesland)) == 16) {
  write.csv(ger_today,
            file='./rki_data/RKI_COVID19_latest.csv', row.names=FALSE)
}
ger <- read.csv(paste0('./rki_data/RKI_COVID19_latest.csv'))
# subsetting and reordering: (ignore "Datenstand" and "ObjectId")
ger <- subset(ger, select=c("Meldedatum", "IdBundesland", "Bundesland",
                            "IdLandkreis", "Landkreis", "AnzahlFall",
                            "AnzahlTodesfall", "Altersgruppe", "Geschlecht"))
ger <- ger[!(ger$IdBundesland == -1),] # remove "-nicht erhoben-"
ger$AnzahlFall[ger$AnzahlFall < 0] <- 0 # set negatives to 0
ger$AnzahlTodesfall[ger$AnzahlTodesfall < 0] <- 0 # set negatives to 0
# renaming:
names(ger) <- c("date", "reg0.id", "reg0.name", "reg1.id", "reg1.name",
                "new.cases", "new.dead", "age", "sex")
ger$date <- as_date(ger$date) # date in correct format
ger <- ger[!(ger$date == today),] # remove today
ger$yday <- yday(ger$date) # add yday
ger$day <- ger$yday - min(ger$yday) # add day
ger <- ger[order(ger$day),] # reorder
# for derived data frames additonal case statistics (tot.cases, ...) are added;
# here too many combinations of factors make this impractical !
# reordering:
ger <- ger[, c("day", "yday", "date",
               "reg0.id", "reg0.name", "reg1.id", "reg1.name",
               "new.cases", "new.dead",
               "age", "sex")]
write.csv(ger, file='./clean/data_ger_all.csv', row.names=FALSE)
## 3) # create lookup table for ger all ========================================
lookup_ger <- subset(ger, select=c("reg0.id", "reg0.name",
                                   "reg1.id", "reg1.name"))
lookup_ger <- unique(lookup_ger[order(lookup_ger$reg0.id),])
write.csv(lookup_ger, file='./clean/lookup_ger_all.csv', row.names=FALSE)
## =============================================================================


## 3) # create lookup table for ger bundl ======================================
lookup_ger_bundl <- subset(ger, select=c("reg0.id", "reg0.name"))
lookup_ger_bundl <- unique(lookup_ger_bundl[order(lookup_ger_bundl$reg0.id),])
codes <- data.frame(reg0.id=1:16,
                    reg0.id=c('SH', 'HH', 'NI', 'HB', 'NW', 'HE', 'RP', 'BW',
                              'BY', 'SL', 'BE', 'BB', 'MV', 'SN', 'ST', 'TH'))
lookup_ger_bundl <- merge(lookup_ger_bundl, codes)
write.csv(lookup_ger_bundl,
          file='./clean/lookup_ger_bundl.csv', row.names=FALSE)
## =============================================================================


## 2) region: "Deutschland" - sub-regions: "Bundeslaender" =====================
ger_b <- read.csv('./clean/data_ger_all.csv')
ger_b <- aggregate(cbind(new.cases, new.dead) ~ day + yday + date
                   + reg0.id + reg0.name, ger_b, sum)
# replace numerical ids with codes from lookup:
ger_b <- merge(ger_b, lookup_ger_bundl)
ger_b$reg0.id <- ger_b$reg0.id.1
ger_b$reg0.id.1 <- NULL
#ger_b <- ger_b[order(ger_b$reg0.id),]
#ger_b <- ger_b[order(ger_b$day),]
# complete combinations of factors:
#df1 <- unique(ger_b[, c("day", "yday", "date")])
ger_b$date <- as_date(ger_b$date)
dates <- seq(min(ger_b$date), max(ger_b$date), by = '1 day')
df1 <- data.frame(day=seq_along(dates)-1, yday=yday(dates), date=dates)
df2 <- unique(ger_b[, c("reg0.id", "reg0.name")])
df3 <- merge(df1, df2)
#df3$date <- as.factor(df3$date)
ger_b <- merge(ger_b, df3, all=TRUE)
ger_b[is.na(ger_b)] <- 0
# order by reg0 and date:
ger_b <- ger_b[order(ger_b$reg0.id),]
ger_b <- ger_b[order(ger_b$day),]
# add case statistics:
for (id in ger_b$reg0.id) {
  mask <- ger_b$reg0.id == id
  ger_b$tot.cases[mask] <- cumsum(ger_b$new.cases[mask])
} # add tot.cases
for (id in ger_b$reg0.id) {
  mask <- ger_b$reg0.id == id
  ger_b$tot.dead[mask] <- cumsum(ger_b$new.dead[mask])
} # add new.dead
# reorder column names:
ger_b <- ger_b[, c("day", "yday", "date",
                   "reg0.id", "reg0.name",
                   "tot.cases", "tot.dead",
                   "new.cases", "new.dead")]
write.csv(ger_b, file='./clean/data_ger_bundl.csv', row.names=FALSE)
## =============================================================================


## 2) region: "Deutschland" without sub-regions ================================
ger_tot <- read.csv('./clean/data_ger_bundl.csv')
ger_tot <- aggregate(cbind(tot.cases, tot.dead, new.cases, new.dead)
                   ~ day + yday + date, ger_tot, sum)
write.csv(ger_tot, file='./clean/data_ger_tot.csv', row.names=FALSE)
## =============================================================================


## 3) # create lookup table for world ==========================================
lookup_world <- read.csv(file.path('./johns_hopkins/csse_covid_19_data/',
                                   'UID_ISO_FIPS_LookUp_Table.csv'))
# only keep real countries no subregions:
lookup_world <- lookup_world[lookup_world$Province_State=='',]
#
lookup_world <- unique(subset(lookup_world,
                              select = c('iso3', 'Country_Region')))
# remove ships:
lookup_world <- lookup_world[lookup_world$iso3!='',]

# old:
#missing <- data.frame(iso3=c('CAN', 'AUS', 'CHN', 'USA'),
#                      Country_Region=c('Canada', 'Australia', 'China', 'US'))
#lookup_world <- merge(lookup_world, missing, all=TRUE)

# rename countries:
lookup_world$Country_Region[lookup_world$Country_Region=="Taiwan*"] <- "Taiwan"
lookup_world$Country_Region[lookup_world$Country_Region=="Korea, South"] <- "South Korea"

# old:
#levels(lookup_world$Country_Region)[levels(lookup_world$Country_Region)
#                                    == 'Taiwan*'] <- 'Taiwan'
#levels(lookup_world$Country_Region)[levels(lookup_world$Country_Region)
#                                    == 'Korea, South'] <- 'South Korea'
#lookup_world <- lookup_world[-c(1,2),]

names(lookup_world) <- c('reg0.id', 'reg0.name')
write.csv(lookup_world, file='./clean/lookup_world_jh.csv', row.names=FALSE)
## =============================================================================


## 1) region: world; all data ==================================================
#
# Johns-Hopkins data
#
path <- './johns_hopkins/csse_covid_19_data/csse_covid_19_time_series/'
world_cases <- read.csv(paste0(path,
                               'time_series_covid19_confirmed_global.csv'))
world_dead <- read.csv(paste0(path,
                              'time_series_covid19_deaths_global.csv'))
world_recovered <- read.csv(paste0(path,
                                   'time_series_covid19_recovered_global.csv'))
# date in correct format:
dates <- tail(names(world_cases), -4)
dates <- gsub('X', '', dates)
dates <- parse_date_time(dates, orders='%m%d%y')
# wide too long format:
world_cases2 <- reshape(world_cases, varying=tail(names(world_cases), -4),
                        direction = 'l', timevar = 'date',
                        v.names = 'tot.cases', times = dates)[, -c(3, 4, 7)]
world_dead2 <- reshape(world_dead, varying=tail(names(world_dead), -4),
                       direction = 'l', timevar = 'date',
                       v.names = 'tot.dead', times = dates)[, -c(3, 4, 7)]
world_recovered2 <- reshape(world_recovered,
                            varying=tail(names(world_recovered), -4),
                            direction = 'l', timevar = 'date',
                            v.names = 'tot.recovered',
                            times = dates)[, -c(3, 4, 7)]
world <- merge(merge(world_cases2, world_dead2, all=TRUE),
               world_recovered2, all=TRUE)
# reordering:
world <- world[, c("date", "Country.Region", "Province.State",
                   "tot.cases", "tot.dead", "tot.recovered")]
# renaming:
names(world) <- c("date", "reg0.name", "reg1.name",
                  "tot.cases", "tot.dead", "tot.recovered")
world <- world[!(world$date == today),] # remove today
world$yday <- yday(world$date) # add yday
world$day <- world$yday - min(world$yday) # add day
world <- world[order(world$reg0.name),] # reorder
world <- world[order(world$day),] # reorder
# aggregating reg1:
australia <- aggregate(cbind(tot.cases, tot.dead, tot.recovered)
                       ~ day + yday + date + reg0.name,
                       data=subset(world, reg0.name == 'Australia'), sum)
australia$reg1.name <- ''
world <- world[!(world$reg0.name == 'Australia'),] # remove australia
world <- merge(world, australia, all=TRUE)
canada <- aggregate(cbind(tot.cases, tot.dead)
                    ~ day + yday + date + reg0.name,
                    data=subset(world, reg0.name == 'Canada'
                                       & reg1.name != ''), sum)
canada2 <- aggregate(tot.recovered ~ day + yday + date + reg0.name,
                     data=subset(world, reg0.name == 'Canada'
                                        & reg1.name == ''), sum)
canada$reg1.name <- ''
canada <- merge(canada, canada2)
world <- world[!(world$reg0.name == 'Canada'),] # remove canada
world <- merge(world, canada, all=TRUE)
china <- aggregate(cbind(tot.cases, tot.dead, tot.recovered)
                   ~ day + yday + date + reg0.name,
                   data=subset(world, reg0.name == 'China'), sum)
china$reg1.name <- ''
world <- world[!(world$reg0.name == 'China'),] # remove china
world <- merge(world, china, all=TRUE)
# removing colonies:
world <- world[!(world$reg0.name == 'Denmark' & world$reg1.name != ''),]
world <- world[!(world$reg0.name == 'France' & world$reg1.name != ''),]
world <- world[!(world$reg0.name == 'Netherlands' & world$reg1.name != ''),]
world <- world[!(world$reg0.name == 'United Kingdom' & world$reg1.name != ''),]
# removing ships: Diamond Princess, MS Zaandam
world <- world[!(world$reg0.name == 'Diamond Princess'),]
world <- world[!(world$reg0.name == 'MS Zaandam'),]
# rename countries:
levels(world$reg0.name)[levels(world$reg0.name) == 'Taiwan*'] <- 'Taiwan'
levels(world$reg0.name)[levels(world$reg0.name)
                        == 'Korea, South'] <- 'South Korea'
# add reg0.id:
world <- merge(world, lookup_world)
# reorder:
world <- world[order(world$reg0.id),]
world <- world[order(world$day),]
# add case statistics:
for (id in world$reg0.id) {
  mask <- world$reg0.id == id
  world$new.cases[mask] <- diff(c(0, world$tot.cases[mask]))
} # add new.cases
for (id in world$reg0.id) {
  mask <- world$reg0.id == id
  world$new.dead[mask] <- diff(c(0, world$tot.dead[mask]))
} # add new.dead
for (id in world$reg0.id) {
  mask <- world$reg0.id == id
  world$new.recovered[mask] <- diff(c(0, world$tot.recovered[mask]))
} # add new.recovered
# reordering:
world <- world[, c("day", "yday", "date",
               "reg0.id", "reg0.name",
               "tot.cases", "tot.dead", "tot.recovered",
               "new.cases", "new.dead", "new.recovered")]
#world <- world[order(world$reg0.id),]
#world <- world[order(world$day),]
write.csv(world, file='./clean/data_world_jh.csv', row.names=FALSE)
# ==============================================================================

## 2) region: "world" without sub-regions ======================================
world_tot <- read.csv('./clean/data_world_jh.csv')
world_tot <- aggregate(cbind(tot.cases, tot.dead, tot.recovered,
                             new.cases, new.dead, new.recovered)
                     ~ day + yday + date, world_tot, sum)
write.csv(world_tot, file='./clean/data_world_tot.csv', row.names=FALSE)
## =============================================================================
