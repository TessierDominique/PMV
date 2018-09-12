
import csv

def loadCSVFile(filenameIn, filenameOut):
    # initialisation
    result = []

    #charger fichier
    fichier = open(filenameIn)
    reader = csv.reader(fichier)

    # Fichier csv en ouptut (Note: Onprend le délimiteur | car il des des nombres qui ont des virgules
    fichierOut = open(filenameOut, "w")
    writer = csv.writer(fichierOut, delimiter='|', quoting=csv.QUOTE_MINIMAL)

    # on saute les premières lignes
    i = 0
    while (i < 15):
        next(reader, None)
        i += 1

    lastTemps = ""
    for row in reader:
        print (row)
        # Si le temps est insconnu (ND), prendre la dernière valeur connue valide
        if row[23] == 'ND':
            lastTemps = lastTemps
        else:
            lastTemps = row[23]

        writer.writerow([row[0].strip(),row[1],row[2],row[3],row[4],row[5],row[13],lastTemps])

    # fermer le fichier
    fichier.close()
    fichierOut.close()

def main():
    filenameIn = "fre-hourly-04012017-04302017.csv"
    finlenameOut = "meteoAvril.csv"
    loadCSVFile(filenameIn, finlenameOut)



if __name__ == '__main__':
    main()