library(tidyverse)

# ********************************************************************
#
#                               Initialisation
#
# ********************************************************************

# Repertoires et nom des Datasets
bixiFile <- "F:/Disque H/Projet/Sources/Stations_2017-5.csv"      # fichier des stations
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

# Lire et preparer le dataset decrivant les stations (1 fichier par année)
bixistations <- pmv_loadAndPrepareBixiStations(bixiFile)
dim(bixistations)
names(bixistations)
summary(bixistations)
str(bixistations)

# Charger et preparer le dataset sur les deplacements en Bixi
mergeBixi <- pmv_loadAndPrepareBixiDeplacements(bixiPath)
dim(mergeBixi)
names(mergeBixi)
summary(mergeBixi)
str(mergeBixi)

# Charger et preparer le dataset sur la Meteo 
mergeMeteo <- pmv_loadAndPrepareMeteo(meteoPath)
summary(mergeMeteo)
str(mergeMeteo)

# Lire et preparer le dataset decrivant les stations de la STM
stmstations <- pmv_loadAndPrepareSTMStations(stmFile)
dim(stmstations)
names(stmstations)
summary(stmstations)
str(stmstations)

# Construire un gros dataset avec les deplacements, la meteo et les stations
library(sqldf)


# Data set trop gros pour être traite avec toutes ces variables
#grpAll <- sqldf("Select 
#     m.Annee, m.Mois, m.Jour, m.Heure, b.period,
#     b.start_date, b.start_station_code, s.name as start_station_name, 
#     s.latitude as start_latitude, s.longitude as start_longitude, s.altitude as start_altitude, 
#     s.postal as start_postal, s.postal3 as start_postal3, s.postal2 as start_postal2, 
#     b.end_date, b.end_station_code, e.name as end_station_name, 
#     e.latitude as end_latitude, e.longitude as end_longitude, e.altitude as end_altitude, 
#     e.postal as end_postal, e.postal3 as end_postal3, e.postal2 as end_postal2,  
#     b.duration_sec, b.is_member, 
#     m.Temperature, m.DirVent, m.VitVent,    
#     m.visibilite, m.Pression, m.Temps
#     from mergeBixi b
#     left join bixistations s on b.start_station_code = s.code
#     left join bixistations e on b.end_station_code = e.code
#     left join mergeMeteo m on b.meteoLink = m.bixilink")

# Dataset reduit
grpAll <- sqldf("Select 
              b.start_date, b.period,
              b.start_station_code, s.name as start_station_name, 
              s.latitude as start_latitude, s.longitude as start_longitude,
              s.altitude as start_altitude, 
              s.postal as start_postal, s.postal3 as start_postal3, s.postal2 as start_postal2, 
              b.end_date, 
              b.end_station_code, e.name as end_station_name, 
              e.latitude as end_latitude, e.longitude as end_longitude,
              e.altitude as end_altitude, 
              e.postal as end_postal, e.postal3 as end_postal3, e.postal2 as end_postal2,  
              b.duration_sec, b.is_member, 
              m.Temperature, m.DirVent, m.VitVent,    
              m.visibilite, m.Pression, m.Temps as temps
              from mergeBixi b
              left join bixistations s on b.start_station_code = s.code
              left join bixistations e on b.end_station_code = e.code
              left join mergeMeteo m on b.meteoLink = m.bixilink")

# calculer la distance entre les 2 stations pour chaque enregistrement
grpAll <- mutate(grpAll, distance = earth.dist(start_longitude, start_latitude, end_longitude, end_latitude))

# ************************************************************************************
# 
#  Analyse descriptive
#
# ************************************************************************************


# Nombre de déplacements
dim(grpAll)


# Description des variables
names(grpAll)

# Structure
str(grpAll)

# Sommaire
summary(grpAll)

# Distribution de la duree des deplacements (en minute)
hist(mergeBixi$duration_sec/60)
plot(density(mergeBixi$duration_sec/60),main="Densité de la durée des déplacements en minute")

# Distribution de la duree des deplacements
hist(grpAll$Temperature, main = "Histogramme de la température", xlab = "Température")

# covariance et correlation entre la duree et si l'utilisateur est un membre
cov(mergeBixi$duration_sec, mergeBixi$is_member)
cor(mergeBixi$duration_sec, mergeBixi$is_member)

# Repartition des deplacements en fonction des membres et des non membres
bymembers <- mergeBixi %>%
  group_by(is_member) %>%
  summarise(freq=n())

# Deplacements en fonction de la météo
byTemps <- grpAll %>%
  group_by(temps) %>%
  summarise(freq=n())


# relation entre la distance et la durée du déplacement
summary(select(grpAll, distance, duration_sec))
# prendre un echantillon car trop long avec tous les enregistrements
grpAll40 <- grpAll %>% dplyr::sample_frac(.40)
pairs(select(grpAll40, distance, duration_sec))

# relation entre la distance et la durée du déplacement pour les 45 minutes et plus
# Pour comprendre le resultat du modele naives bayes qui ne donne pas de bon résulats
tmp <- grpAll %>% filter(duration_sec > 2700)
dim(tmp)
tmp <- select(tmp, distance, duration_sec)
pairs(select(tmp, distance, duration_sec))

