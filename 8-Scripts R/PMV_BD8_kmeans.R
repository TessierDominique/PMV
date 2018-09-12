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

# Lire et preparer le dataset decrivant les stations Bixi (1 fichier par année)
bixistations <- pmv_loadAndPrepareBixiStations(bixiFile)
summary(bixistations)
str(bixistations)

# Charger et preparer le dataset sur les deplacements en Bixi
mergeBixi <- pmv_loadAndPrepareBixiDeplacements(bixiPath)
summary(mergeBixi)
str(mergeBixi)


# extraire la longitude et la latitude pour déterminer le K
kBixi <- bixistations[,3:4]

library(cluster)
library(factoextra)
library(ggplot2)
library(fpc)
library(NbClust)

# Determiner le nombre de clusters avec la position des stations Bixi
nb <- NbClust(kBixi, distance = 'euclidean', min.nc = 2, max.nc = 10, method = 'complete', index = 'all')

fviz_nbclust(nb) + theme_minimal()

# faire la repartition des stations entre les clusters
km.res <- eclust(kBixi, 'kmeans', k = 3, nstart = 25, graph = FALSE)
km.res$size

# Affichage des clusters
fviz_cluster(km.res, geom = 'point', frame.type = "norm", main="Cluster Bixi")

#sil <- silhouette(km.res$cluster, dist(nb.scaled))
#dim(sil)
#head(sil[,1:3],10)
#plot(sil, main = 'silhouette plot = k-means')

library(sqldf)

# faire le merge des deplacements avec les stations base sur le code de la station de depart
# Récupérer la localisation (latitude, longitude) de tous les deplacements

# Prendre un echantillon des deplacement (car trop gros pour être traité)
depBixi <- mergeBixi %>% dplyr::sample_frac(.40)
summary(depBixi)

byK <- sqldf("Select 
             s.latitude as latitude, s.longitude as longitude
             from depBixi b
             left join bixistations s on b.start_station_code = s.code")

# Calcul du kmeans
set.seed(20)
km <- kmeans(byK, 3)
byK$Borough <- as.factor(km$cluster)
# Inspect 'clusters'
str(km)

library(ggmap)
require(ggmap)

# Afficher la carte avec la repartition par cluster
montrealPosition <- c(lon=-73.5878100, lat=45.5088400)
montreal_map=get_map(location=montrealPosition,zoom=12)
mtl <- ggmap(montreal_map)

mtl + geom_point(aes(x = longitude, y = latitude, colour = as.factor(Borough)),data = byK) +
  ggtitle("Quartier MTL avec KMean")


# Afficher la carte avec le nombde de deplacements par cluster
df <- data.frame(km$centers)
df$nbDeplacements <- km$size
str(df)
mtl + geom_point(data= df, aes(x = c(longitude), y = c(latitude), size = nbDeplacements/1000), color = 'red') 


# *************************************************************
#
#
#
# *************************************************************

