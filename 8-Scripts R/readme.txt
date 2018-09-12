Pour repertoire "Data":
Il faut télécharger les données de déplacements de BIXI de 2014 à 2017 à partir du site BIXI: http://bixi.com/fr/donnees-ouvertes. Ensuite mettez les fichiers dans les repertoires d'année respectivement.



Pour les fichiers dans le repertoire "Script R":
PMV_BD8_Descriptive.R: script pour faire l'analyse descriptive

PMV_B8_Modelisation.R: script pour faire la modelisation

PMV_BD8_Deplacement.R: script pour afficher sur carte les déplacements en Bixi

Note: au debut des scripts, on doit indiquer:
- les répertoires des datasets qui seront utilisés
- Le répertoire des sources R qui contiennent des fonctions utilisées par les scripts

PMV_BD8_Init.R: script qui prepare les datasets

PMV_BD8_kmeans.R: Script pour faire un kmeans sur la localisation des stations


PMV_BD8_stations_kmeans.R: Script pour faire un kmeans sur BIXI station avec la localisation et d'autres variables.
PMV_BD8_stations_kmeans.Rmd
PMV_BD8_stations_kmeans.html


PMV_BD8_Deplacement_timeseries.R: Script pour faire un time series analysis sur les déplacements de BIXI afin de prédire les déplacements de 2018 et 2019.
PMV_BD8_Deplacement_timeseries.Rmd
PMV_BD8_Deplacement_timeseries.html


