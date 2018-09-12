library(tidyverse)

# ************************************************************************************
# 
#  Lecture et preparation des dataset
#
# ************************************************************************************


# Fonction qui fait le merge des fichiers d'un repertoire
pmv_mergefiles <- function (path, rowToSkip){
  # Changer de Repertoire
  setwd(path)
  
  # Recuperer la liste des fichiers a traiter
  lst <- list.files(pattern="*.csv")
  
  # Faire le merge des fichiers (de tous les fichiers du repertoire)
  res <- do.call("rbind", lapply(lst, FUN = function(currentFile) {
    read.csv(currentFile, skip = rowToSkip, header = TRUE, sep=",", stringsAsFactors = FALSE, encoding="UTF-8")
  }))
  
  return(res)
}


# Fonction qui prepare le dataset des stations Bixi
pmv_preparebixistations <- function(dataset){
  # Extraire les 3 premiers caracteres du code postal
  dataset <- mutate(dataset, postal3 = substring(postal,1,3))
  
  # Extraire les 2 premiers caracteres du code postal
  dataset <- mutate(dataset, postal2 = substring(postal,1,2))
  
  dataset <- select(dataset, -"city")
  return(dataset)
}

# fonction qui prepare le data set des deplacements
pmv_prepareBixiOD <- function(bixiOD){
  # extraire l'heure de depart
  bixiOD <- mutate(bixiOD, hourStart = as.numeric(substring(start_date,12,13)))
  
  # extraire la date et l'heure pour faire le merge avec la meteo
  bixiOD <- mutate(bixiOD, meteoLink = substring(start_date,1,13)) # Garder les 13 premiers caracteres
  
  # Calculer la periode (minuit a 4 heures, 4-8h,  ...)
  bixiOD <- mutate(bixiOD, period = cut(hourStart, c(0, 3, 7, 11, 15, 19, 23),
                                        include.lowest = TRUE))
  
  return(bixiOD)
}

# Fonction qui nettoie le dataset Meteo
pmv_prepareMeteo <- function(mergeMeteo){
  
  # Inscrire une valeur par defaut plutôt que ND (prendre la derniere valeur connue)
  
  #lastValid24 <- ""
  #for (item in 1:nrow(mergeMeteo)){
    # Traiter le temp
   # if (mergeMeteo[item,24] == "ND") {
    #  mergeMeteo[item,24] <- lastValid24
    #}
    #else{
     # lastValid24 <- mergeMeteo[item,24]
  #  }
  #}
  
  # supprimer les colonnes inutiles (ne conserver que les utiles)
  mergeMeteo <- select(mergeMeteo, "Date.Heure","Année","Mois", "Jour","Heure",
                       "Temp...C.","Dir..du.vent..10s.deg.", "Vit..du.vent..km.h." ,
                       "Visibilité..km." ,"Pression.à.la.station..kPa.", "Temps")
  
  # Renommer certaines colonnes
  mergeMeteo <- rename(mergeMeteo, "Annee" = "Année")
  mergeMeteo <- rename(mergeMeteo, "Temperature" = "Temp...C.")
  mergeMeteo <- rename(mergeMeteo, "DirVent" = "Dir..du.vent..10s.deg.")
  mergeMeteo <- rename(mergeMeteo, "VitVent" = "Vit..du.vent..km.h.")
  mergeMeteo <- rename(mergeMeteo, "visibilite" = "Visibilité..km.")
  mergeMeteo <- rename(mergeMeteo, "Pression" = "Pression.à.la.station..kPa.")

  # traiter l'heure (hh:00 -> hh)
  mergeMeteo <- mutate(mergeMeteo, Heure = substring(Heure,1,2)) # Garder les 2 premiers caracteres
  mergeMeteo <- mutate(mergeMeteo, Heure = as.numeric(Heure)) 
  
  
  # temperatue, visibilite et pression a transformer en numérique (remplacer les , par .)
  mergeMeteo <- mutate(mergeMeteo, Temperature = gsub(",",".",Temperature))
  mergeMeteo <- mutate(mergeMeteo, Temperature = as.numeric(Temperature))
  
  mergeMeteo <- mutate(mergeMeteo, visibilite = gsub(",",".",visibilite))
  mergeMeteo <- mutate(mergeMeteo, visibilite = as.numeric(visibilite)) 
  
  mergeMeteo <- mutate(mergeMeteo, Pression = gsub(",",".",Pression))
  mergeMeteo <- mutate(mergeMeteo, Pression = as.numeric(Pression)) 
  
  # Inscrire une valeur par defaut plutôt que ND ou NA (prendre la derniere valeur connue)
  # On prend des valeurs par defaut sinon la variable ne sera pas consideree
  
  lastValidTemps <- "X"
  lastValidPression <- 0
  lastValidDirVent <- 0
  lastValidVitVent <- 0
  lastValidVisibilite <- 0
  lastValidTemperature <- 0
  
  for (item in 1:nrow(mergeMeteo)){
    # Traiter le temps
    if ((mergeMeteo[item,'Temps'] == "ND")  | (str_trim(mergeMeteo[item,'Temps']) == "")){
      mergeMeteo[item,'Temps'] <- lastValidTemps
    }
    else{
      lastValidTemps <- mergeMeteo[item,'Temps']
    }
    # Traiter la pression
    if (is.na(mergeMeteo[item,'Pression'])){
      mergeMeteo[item,'Pression'] <- lastValidPression
    }
    else{
      lastValidPression <- mergeMeteo[item,'Pression']
    }
    # Traiter la direction du vent
    if (is.na(mergeMeteo[item,'DirVent'])){
      mergeMeteo[item,'DirVent'] <- lastValidDirVent
    }
    else{
      lastValidDirVent <- mergeMeteo[item,'DirVent']
    }
    # Traiter la visibilite
    if (is.na(mergeMeteo[item,'visibilite'])){
      mergeMeteo[item,'visibilite'] <- lastValidVisibilite
    }
    else{
      lastValidVisibilite <- mergeMeteo[item,'visibilite']
    }
    # Traiter la vitesse du vent
    if (is.na(mergeMeteo[item,'VitVent'])){
      mergeMeteo[item,'VitVent'] <- lastValidVitVent
    }
    else{
      lastValidVitVent <- mergeMeteo[item,'VitVent']
    }
    # Traiter la temperature
    if (is.na(mergeMeteo[item,'Temperature'])){
      mergeMeteo[item,'Temperature'] <- lastTemperature
    }
    else{
      lastTemperature <- mergeMeteo[item,'Temperature']
    }
  }
  
  summary(mergeMeteo)
  
  # Cle pour faire le lien avec les deplacements bixi
  mergeMeteo <- mutate(mergeMeteo, bixiLink = substring(Date.Heure,1,13)) # Garder les 13 premiers caracteres
  
  return(mergeMeteo)
}

# Charger et preparer le dataset sur les stations Bixi
pmv_loadAndPrepareBixiStations <- function(stationFile){
  # Lire le fichier decrivant les stations (1 fichier par année)
  bixiStations <- read.csv(stationFile, header = TRUE, sep=",", stringsAsFactors = FALSE, encoding="UTF-8")
  
  # preparer le dataset des stations
  bixiStations <- pmv_preparebixistations(bixiStations)

  return(bixiStations)
}

# Charger et preparer le dataset sur les stations de la STM
pmv_loadAndPrepareSTMStations <- function(stationFile){
  # Lire le fichier decrivant les stations 
  stmStations <- read.csv(stationFile, header = FALSE, sep=",", stringsAsFactors = FALSE, encoding="UTF-8")
  
  # Ajouter une entete
  names(stmStations) <- c('stop_id','stop_code','stop_name','stop_lat','stop_long','location_type','parent_station','wheelchair')
  # preparer le dataset des stations
  #bixiStations <- pmv_preparebixistations(bixiStations)
  
  return(stmStations)
}

# Charger et preparer le dataset sur les deplacements en Bixi
pmv_loadAndPrepareBixiDeplacements <- function(deplacementPath){
  # Lire les fichiers relies au dataset et les fusionner
  mergeBixi <- pmv_mergefiles(deplacementPath, 0)
  
  # ETL sur le data set
  mergeBixi <- pmv_prepareBixiOD(mergeBixi)
  
  return(mergeBixi)
}

# Charger et preparer le dataset sur les deplacements en Bixi
pmv_loadAndPrepareMeteo <- function(meteoPath){
  # Lire les fichiers relies au dataset et les fusionner
  mergeMeteo <- pmv_mergefiles(meteoPath, 15)

  # ETL sur le data set
  mergeMeteo <- pmv_prepareMeteo(mergeMeteo)
  
  return(mergeMeteo)
}

# Distance en metres entre 2 points
earth.dist <- function (long1, lat1, long2, lat2)
{
  earth_radius <- 6378145 # Terre = sphère de 6378km de rayon
  rad <- pi/180
  
  a1 <- lat1 * rad
  a2 <- long1 * rad
  b1 <- lat2 * rad
  b2 <- long2 * rad
  
  dlon <- (b2 - a2) / 2
  dlat <- (b1 - a1) / 2
  
  a <- (sin(dlat))^2 + cos(a1) * cos(b1) * (sin(dlon))^2
  c <- 2 * atan2(sqrt(a), sqrt(1 - a))
  
  distance <- earth_radius * c
  
  return(round(distance))
}


test1<- earth.dist(75, -45, 75.1, -45.1)
test1
