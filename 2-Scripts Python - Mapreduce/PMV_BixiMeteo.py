# Faire le lien entre les déplacements en Bixi et la météo
# Input: Fichier des déplacement en Bixi
# paramètre --Meteo : fichier météo
#           --Mode :  (1: temps; 2: Vitesse du vent)
# Output: Temps [nb de déplacements, nombre heures, moy des déplacements par heure]

from mrjob.job import MRJob
from mrjob.job import MRStep
from unidecode import unidecode


class MRPMV_BixiMeteo(MRJob):
    # permet d'avoir des paramètres autre que le fichier d'entrée
    # --Bixi_Stations suivi du fichier avec les données sur les stations BIXI
    def configure_args(self):
        super(MRPMV_BixiMeteo, self).configure_args()
        self.add_passthru_arg(
            '--Meteo', default='string', help="Specify Meteo file")
        self.add_passthru_arg(
            '--Mode', default='int', help="Specify Mode (1: temps; 2: Vitesse du vent")

    # première step. Parsing des déplacements
    # clé : date/heure; values :Deplacement (1)
    def mapper_get_count(self, key, line):
        (start_date,start_station_code,end_date,end_station_code,duration_sec,is_member) = line.split(',')
        if (start_date != 'start_date'):  # skip first line
            # Extraire la date et l'heure de depart (2017-04-15 00:00)
            key = start_date.replace("-","").replace(" ","")[:10]
            yield key, 1


    # Faire la somme du nonbre de départ et d'arrivée par station
    def reducer_total_station(self, key, occurences):
        yield key, sum(occurences)

    # 2ieme step
    # Initialisation au mapper pour associé la date au temps
    def mapper_init2(self):
        self.meteo = { }
        file = open(self.options.Meteo, "r", encoding="utf-8")

        for line in file.readlines():
            if (line.strip() != ""):  # Ne pas triater les lignes vides
                (DateHeure,Annee,Mois,Jour,Heure,Temperature,VitVent,Temps) = line.strip().split("|")
                if (Heure !=  "Heure"):  # On saute la premiere ligne
                    # associer la dateHeure avec la temperature
                    key = (Annee + Mois+Jour+Heure)[:10]
                    # construire la liste avec la vitesse du vent
                    if int(self.options.Mode) == 2:
                        self.meteo[key] = int(VitVent) #'%02d'%int(VitVent)
                    else:  # Liste avec le temps
                        self.meteo[key] = Temps   #.decode('cp1252')


        file.close()

    # Clé: Temps
    # Valeur: Nb de deplacements, 1 (1 heure)
    def mapper_join(self, key, values):
        if int(self.options.Mode) == 2:
            # regrouper le vent
            catVitesseVent  = "Moins de " + str((int(self.meteo[key]/10) +1) * 10) + " km/h"
            yield catVitesseVent, (values, 1)
        else:
            yield self.meteo[key], (values, 1)

    #
    def reducer_join(self, key, values):
        totalDeplacements = 0
        totalHeures = 0
        for item in values:
            totalDeplacements += item[0]
            totalHeures += item[1]
            # Enlever les accents
            unaccented_string = unidecode(key)
        yield unaccented_string, (totalDeplacements,totalHeures,format(totalDeplacements/totalHeures, '.2f'))

    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_count, reducer=self.reducer_total_station)
            , MRStep(mapper_init=self.mapper_init2, mapper=self.mapper_join, reducer = self.reducer_join)
        ]


if __name__ == '__main__':
    MRPMV_BixiMeteo.run()