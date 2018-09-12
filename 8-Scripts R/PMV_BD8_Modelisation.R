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

# Charger et preparer le dataset sur les deplacements en Bixi
mergeBixi <- pmv_loadAndPrepareBixiDeplacements(bixiPath)

# Charger et preparer le dataset sur la Meteo 
mergeMeteo <- pmv_loadAndPrepareMeteo(meteoPath)

# Parametre de chacun des dataset
names(mergeBixi)
names(mergeMeteo)
names(bixistations)



library(sqldf)

# Construire le dataset d'analyse (fusion des autres datasets)
dt <- sqldf("Select 
                m.Mois, m.Jour, m.Heure, 
                s.latitude as start_latitude, s.longitude as start_longitude,
                s.altitude as start_altitude, 
                e.latitude as end_latitude, e.longitude as end_longitude,
                e.altitude as end_altitude, 
                b.is_member, 
                m.Temperature, m.DirVent, m.VitVent,    
                m.visibilite, m.Pression, m.Temps as temps,
                b.duration_sec
                from mergeBixi b
                left join bixistations s on b.start_station_code = s.code
                left join bixistations e on b.end_station_code = e.code
                left join mergeMeteo m on b.meteoLink = m.bixilink")

summary(dt)

# Supprimer de la mémoire les dataset qui ne servent plus
rm("mergeBixi")
rm("mergeMeteo")
rm("bixistations")

# ************************************************************************************
# 
#  préparation finale du dataset
#
# ************************************************************************************

# calculer la distance entre les 2 stations pour chaque enregistrement
dt <- mutate(dt, distance = earth.dist(start_longitude, start_latitude, end_longitude, end_latitude))

# Filtrer les enregistrements dont la distance est nulle (ne sert pas èa la modélisation)
#Compter le nombre d'enregistrement vide
xx <- dt %>% filter(distance < 50)
nbDis50 <- dim(xx)

dt<- dt %>% filter(distance >= 50) # Ne conserver que les distances de plus de 50m

# Ajouter la diff d'altitude entre 2 stations
dt <- mutate(dt, diffAltitude = end_altitude - start_altitude)

# Supprimer les donnees (longitude, latitude, altitude) qui ne servent plus
dt <- select(dt, -start_latitude)
dt <- select(dt, -start_longitude)
dt <- select(dt, -end_latitude)
dt <- select(dt, -end_longitude)
dt <- select(dt, -start_altitude)
dt <- select(dt, -end_altitude)

# pour une classification 
# Faire une catégorie pour le temps de parcours (période de 15 minutes (900 sec))
pCat <- c(0, 900, 1800, 2700, 3600, Inf)
pLab <- c("moins de 15","[15-30)","[30-45)","[45-60)","Plus de 60")
dt <- mutate(dt, period_duration = cut(duration_sec, pCat, labels = pLab, right=FALSE))

dt <- mutate(dt, period_duration = factor(period_duration))  # factoriser 
dt <- mutate(dt, period_duration = as.numeric(period_duration)) # convertir en numérique
#dt <- select(dt, -duration_sec) # Supprimer la variable

# Afficher la liste des parametres
names(dt)


# ************************************************************************************
# 
#  Correlation entre les variables
#
# ************************************************************************************

# Les variables non numeriques sont enlevees ou transformees
dt <- mutate(dt, temps2 = factor(temps))  # factoriser le temps
dt <- mutate(dt, temps2 = as.numeric(temps2)) # convertir en numérique
dt <- select(dt, -temps) # Supprimer la variable (elle a ete factorisee)

# Sommaire des descripteurs
summary(dt)


# Normaliser
dt.scaled <- scale(dt)
summary(dt.scaled)

# Faire la correlation entre les variables
cormat <- round(cor(dt.scaled),2)
head(cormat)

library(reshape2)
melted_cormat <- melt(cormat)
head(melted_cormat)

# Afficher la matrice de correlation
library(ggplot2)
ggplot(data = melted_cormat, aes(x=Var1, y=Var2, fill=value)) + 
  geom_tile()

rm("dt.scaled")

# ************************************************************************************
# 
#  split data set (train/test)
#
# ************************************************************************************

# Se limiter aux predicteurs choisis
dt.predicteurs <- data.frame(dt$distance, dt$is_member, dt$Temperature, dt$period_duration)

# factoriser la classe (sinon la prediction ne fonctionne pas)
dt.predicteurs$dt.period_duration <- as.factor(dt.predicteurs$dt.period_duration)
str(dt.predicteurs)
summary(dt.predicteurs)

# Generer un ID unique pour chaque enregistrement (pour faire le split)
dt.predicteurs$id <- 1:nrow(dt)

# Separer le data set en deux pour la modelisation (80% vs 20%)
train <- dt.predicteurs %>% dplyr::sample_frac(.80)
dim(train)  # Taille de l'echantillon pour l'apprentissage

test  <- dplyr::anti_join(dt.predicteurs, train, by = 'id')
dim(test) # Taille de l'echantillon pour les tests


# Enlever l'ID
train <- select(train, -id)
test <- select(test, -id)
str(train)

# ************************************************************************************
# 
#  Prediction naice bayes
#
# ************************************************************************************

library(e1071)

summary(train)

# Creer le modele d'apprentissage (sur les predicteurs normalises)
modelenaiveBayes <- naiveBayes(scale(train[,1:3]), train[,4])


# Inspecter le modele
summary(modelenaiveBayes)
head(modelenaiveBayes)

# Appliquer une prediction
prediction <- predict(modelenaiveBayes,scale(test[,-4]))

# Inspecter la prediction
head(prediction)

# Comparer le test avec la prediction
table(prediction, test[,4], dnn=list('prediction','actual'))

library(gmodels)
CrossTable(test[,4], prediction,
           prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actuel', 'prediction'))

# ************************************************************************************
# 
#  Prediction C50 (distance duree)
#
# ************************************************************************************

library(C50)
c50model <- C5.0(train[,-4], train[,4])

summary(c50model)

c50pred <- predict(c50model, test[,-4])

# Comparer le test avec la prediction
table(c50pred, test[,4], dnn=list('prediction','actual'))

library(gmodels)
CrossTable(test[,4], c50pred,
           prop.chisq = FALSE, prop.c = FALSE, prop.r = FALSE,
           dnn = c('actuel', 'prediction'))

# ************************************************************************************
# 
#  Arbre de decision
#
# ************************************************************************************

dt.predicteurs <- data.frame(dt$distance, dt$duration_sec)
dt.predicteurs <- mutate(dt.predicteurs, dt.durationMinute = dt.duration_sec/60) # Ajouter le temps en minutes)
dt.predicteurs <- select(dt.predicteurs, -dt.duration_sec)
summary(dt.predicteurs)

#dt.predicteurs <- data.frame(dt$distance, dt$diffAltitude, dt$duration_sec)

train <- dt.predicteurs %>% dplyr::sample_frac(.60)
train <- dt.predicteurs

summary(train)

library(rpart)
set.seed(55)
model.tree <- rpart(dt.durationMinute ~ dt.distance, train)
#model.tree <- rpart(dt.duration_sec ~ dt.distance + dt.diffAltitude, train)
model.tree
summary(model.tree)

plot(model.tree, uniform=T, main = "Arbre de décision")
text(model.tree, use.n=T)


# *************************************************************
#
# KNN
#
# *************************************************************
library(e1071)
library(caret)

train2 <- train %>% dplyr::sample_frac(.02)

set.seed(1234)
x = trainControl(method = 'repeatedcv',
                 number = 10,
                 repeats = 3,
                 classProbs = TRUE)

str(train2)
train2 <- rename(train2, "y" = "dt.period_duration")
levels(train2$y) <- c('P1','P2','P3','P4','P5')

modelKNN <- train(y~. ,  train2, method = 'knn',
                trControl = x,
                preProcess = c("center", "scale"),
                tuneLength = 10)

# Summary of model
modelKNN
plot(modelKNN)

