library(tidyverse)
library(cluster)
library(factoextra)
library(ggplot2)
library(fpc)
library(NbClust)


#set Script R as the working directory
stations_1 = read.csv(file = "../Data/Stations_2017-5.csv",header = TRUE,sep = ",")
stations_2 = read.csv(file = "../Data/stations_capacity.csv",head = TRUE,sep = ",")
bixistations = merge(stations_1,stations_2,by = intersect(names(stations_1),names(stations_2)))

deplacement2017 = read.csv(file = "../Data/deplacement/nombreDeplacement2017.csv",sep = '\t')
bixistations = merge(bixistations,deplacement2017,by=intersect(names(bixistations),names(deplacement2017)))
bixistations = mutate(bixistations, postal_short = substring(postal,1,3))

stations_groupby_postal = group_by(bixistations,postal_short)    #51 groups
stations_by_group = summarise(stations_groupby_postal,n=n())
stations_by_group = stations_by_group[order(stations_by_group$n,decreasing = TRUE),]
stations_by_group


head(bixistations)
str(bixistations)


kBixi <- bixistations[,c("latitude","longitude","altitude","capacity","numOfTrajets")]
head(kBixi)
kBixi = scale(kBixi)
head(kBixi)


# Determiner le nombre de clusters avec la position des stations Bixi
nb <- NbClust(kBixi, distance = 'euclidean', min.nc = 2, max.nc = 10, method = 'complete', index = 'all')
fviz_nbclust(nb)

km.res <- eclust(kBixi, 'kmeans',k = 2, graph = TRUE)
km.res$size


km.res <- eclust(kBixi, 'kmeans',k = 10, graph = TRUE)
km.res$size

km.res <- eclust(kBixi, 'kmeans',k = 5, graph = TRUE)
km.res$size
