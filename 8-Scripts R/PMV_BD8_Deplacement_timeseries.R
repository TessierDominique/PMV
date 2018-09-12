library(tidyverse)

bixiPath <- "F:/Disque H/Projet/Sources/SourcesDeplacementsBixi"  # repertoire des deplacements

# Lire le nombre de deplacements par mois
# chaque annee correspond a un mois (avril a novembre)
setwd(bixiPath)
father_dir = getwd()
children_dirs = c("./2014","./2015","./2016","./2017")
od_years_8 = c()
for(dir in children_dirs){
  setwd(dir)
  getwd()
  lst <- list.files(pattern="*.csv")
  od_data_8 = c()
  for(file in lst){
    currentFile = read.csv(file)
    od_data_8 = c(od_data_8,nrow(currentFile))
  }
  od_years_8 = c(od_years_8,od_data_8)
  setwd(father_dir)
}  

# prendre par milliers de deplacements 
od_years_8 <- od_years_8/1000
print(od_years_8)

# Creer un "time-serie"
od_years_ts_8 = ts(od_years_8,frequency = 8, start = 2014)
class(od_years_ts_8)
print(od_years_ts_8)

# Afficher le graphique
plot(od_years_ts_8,plot.type = "single",ylab="Milliers de deplacements", xlab="Année")

# Afficher la regression lineaire
abline(reg=lm(od_years_ts_8~time(od_years_ts_8)), col="red")

plot(aggregate(od_years_ts_8,FUN=mean))

# Affichage du nombre de déplacements par mois
boxplot(od_years_ts_8~cycle(od_years_ts_8))

install.packages("tseries")
library(tseries)

#AR order p -- acf: auto-cross-covariance-and-correlation function estimation
#MR order q -- pacf: partial auto-cross-covariance-and-correlation function estimation

adf.test(diff(od_years_ts_8),alternative = "stationary", k=0)
acf(diff(od_years_ts_8))
pacf(diff(od_years_ts_8))

fit <- arima(od_years_ts_8, c(1, 1, 1),seasonal = list(order = c(1, 1, 1), period = 8))
fit

acf(fit$residuals)
pacf(fit$residuals)

# Faire une prediction pour 2 ans (2 x 8 mois)
pred <- predict(fit, n.ahead = 2*8)

# Afficher le resultat
ts.plot(od_years_ts_8,pred$pred,lty = c(1,2),ylab="Nombre de deplacements")

pred$pred


