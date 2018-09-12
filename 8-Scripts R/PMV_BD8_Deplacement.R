library(tidyverse)

# ********************************************************************
#
#                               Initialisation
#
# ********************************************************************

# Repertoires et nom des Datasets
bixiFile <- "F:/Disque H/Projet/Sources/Stations_2017-5.csv"      # fichier des stations Bixi
bixiPath <- "F:/Disque H/Projet/Sources/SourcesDeplacementsBixi"  # repertoire des deplacements
meteoPath <- "F:/Disque H/projet/Sources/SourcesMeteo"            # Repertoire de la meteo
stmFile <- "F:/Disque H/Projet/Sources/stop3.txt"                 # fichier des stations STM


# Repertoire des fichiers ecrits en R
sourcesPath <- "F:/Disque H/BD8/Projet/"

# Script qui contient les fonctions pour la lecture et la preparation des data set
source(file.path(sourcesPath, "PMV_BD8_Init.R"))

# ********************************************************************
#
#                               Préparation des datasets
#
# ********************************************************************

# Lire et preparer le dataset decrivant les stations de la STM
stmstations <- pmv_loadAndPrepareSTMStations(stmFile)

# Lire et preparer le dataset decrivant les stations Bixi (1 fichier par année)
bixistations <- pmv_loadAndPrepareBixiStations(bixiFile)
summary(bixistations)
str(bixistations)

# Charger et preparer le dataset sur les deplacements en Bixi
mergeBixi <- pmv_loadAndPrepareBixiDeplacements(bixiPath)
summary(mergeBixi)
str(mergeBixi)

# Charger et preparer le dataset sur la Meteo 
mergeMeteo <- pmv_loadAndPrepareMeteo(meteoPath)
summary(mergeMeteo)
str(mergeMeteo)

# Construire un gros dataset avec les deplacements, la meteo et les stations
library(sqldf)

# faire le merge des deplacements avec les stations base sur le code de la station de depart
# Faire le regroupement sur la periode et le code postal a 3 caracteres
# Sortir le nombre de deplacements, la localisation (latitude, longitude) 

byPeriod <- sqldf("Select 
            b.period as periode, s.postal3 as codePostal,
            s.latitude as latitude, s.longitude as longitude
            from mergeBixi b
            left join bixistations s on b.start_station_code = s.code") %>%
  group_by(periode, codePostal) %>%
  summarise(freq=n(), lati = mean(latitude), longi = mean(longitude))

# Deplacements par heure et code postal
byHour <- sqldf("Select b.hourStart as heure,  s.postal3 as codePostal,
            s.latitude as latitude, s.longitude as longitude
                from mergeBixi b
                left join bixistations s on b.start_station_code = s.code") %>%
  group_by(heure, codePostal) %>%
  summarise(freq=n(), lati = mean(latitude), longi = mean(longitude))


# trouver la latitude et longitude d'une adresse èa Montreal
library(ggmap)
#geocode("H2S 2B8")

# récupérer la carte de Montreal
require(ggmap)
montrealPosition <- c(lon=-73.5878100, lat=45.5088400)
montreal_map=get_map(location=montrealPosition,zoom=12)
mtl <- ggmap(montreal_map)

# Afficher la carte avec la frequence des déplacements par heure 
# Identifier les secteurs (code postal) par couleur
mtl+ geom_point(data=byHour, 
             aes(x=longi,y=lati, size=freq, color=factor(codePostal)))+
    facet_wrap(~heure) 

# Afficher la carte avec la frequence des déplacements par periode
mtl+ geom_point(data=byPeriod, 
             aes(x=longi,y=lati, color=factor(codePostal), size=freq), alpha=0.5)+
  scale_size(range = c(0, 5)) +
  facet_wrap(~periode)


# Filtrer les stations de metro (ne garder que la principale)
mainstmstations <- filter(stmstations,  location_type == 1)


# Afficher les stations de metro et les stations Bixi
mtl+   geom_point(data=mainstmstations, 
                  aes(x=stop_long,y=stop_lat, size = 1), shape = 'square', show.legend= FALSE, color='blue') +
  geom_point(data=bixistations, 
                aes(x=longitude,y=latitude), color='red')

