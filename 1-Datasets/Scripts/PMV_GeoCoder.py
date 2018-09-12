

import geocoder
import time
from PMV_Elevation import elevation

# **********************************************************************
# Ajouter aux enregistrements du fichier des stations Bixi: l'altitude,
# le code postal et la ville.
#
# Input: Fichier Bixi a traiter
# Output: Fichier avec l'imformation ajoutee
# **********************************************************************

def loadBixiStation(filenameIn, filenameOut):
    fichierIn = open(filenameIn)

    # lire le contenu du fichier (toutes les lignes
    lignes = fichierIn.readlines()

    # fermer le fichier
    fichierIn.close()

    # Ouvrir le fichier de sortie
    fichierOut = open(filenameOut, "w")

    # ecrire l'entete
    fichierOut.writelines(["code,name,latitude,longitude,altitude,postal,city\n"])

    ligneIter = iter(lignes)

    # on saute la première ligne (l'entete)
    next(ligneIter)

    nbLignes = 0
    # Traiter chaque enregistrement du fichier
    for ligne in ligneIter:

        # Compter le nombre de lignes pour montrer l'evolution du traitement
        nbLignes += 1
        if nbLignes %10 == 0:
            print(nbLignes)

        # extraire chaque donnée, séparée par une virgule
        stationCSV = ligne.strip().split(",")
        code = int(stationCSV[0])
        name = stationCSV[1]
        latitude = stationCSV[2]
        longitude = stationCSV[3]

        # Le fichier traitee est soit le fichier d'origine de Bixi ou le resultat de ce programme (mais incomplet)
        # Le fichier comprend deja l'altitude
        if len(stationCSV) > 4:
            altitude = float(stationCSV[4])
        else:
            altitude = 0.0

        # Le fichier comprend deja le code postal
        if len(stationCSV) > 5:
            postal = stationCSV[5]
        else:
            postal = None

        # Le fichier comprend dela la ville
        if len(stationCSV) > 6:
            city = stationCSV[6]
        else:
            city = None

        # trouver l'altitude de la station
        if altitude == 0.0:
            altitude = elevation(latitude, longitude)

        # Trouver le code postal et la ville (a partit de la latitude et de la longitude)
        if postal == "Nonex":
            g = geocoder.google([latitude, longitude], method='reverse')

            # le code postal n'a pas ete trouve, on reessaye.
            if (g.postal == None):
                # on re essaye avec une pause
                nbTry = 0
                while nbTry < 5:
                    print("Tentative",nbTry)
                    nbTry += 1  #  un essai de plus
                    time.sleep(6-nbTry)
                    g = geocoder.google([latitude, longitude], method='reverse')
                    if g.postal != None:
                        nbTry = 500  # on arrete

            postal = str(g.postal)
            city = str(g.city)

        #print(postal, city)
        # Sauver le tout dans le fichier de sortie
        fichierOut.write(str(code)+","+name+","+str(latitude)+","+str(longitude)+","+ '%.0f'%float(altitude) + "," + str(postal)+","+str(city)+"\n")

    fichierOut.close()

# **********************************************************************
# Debut du programme
# **********************************************************************

inputFilename = "Stations_2017.csv"  # Nom du fichuier en imput
outputFilename = "Stations_2017-5.csv" # Nom du fichier en output
loadBixiStation(inputFilename, outputFilename) # Lancer le traitement

