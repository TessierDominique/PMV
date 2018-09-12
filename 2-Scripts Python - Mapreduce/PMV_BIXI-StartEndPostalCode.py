# -*- coding: UTF-8 -*-
from mrjob.job import MRJob
from mrjob.job import MRStep


class MRPMV_Bixi1(MRJob):
    # permet d'avoir des paramètres autre que le fichier d'entrée
    # --Bixi_Stations suivi du fichier avec les données sur les stations BIXI
    def configure_args(self):
        super(MRPMV_Bixi1, self).configure_args()
        self.add_passthru_arg(
            '--Bixi_Stations', default='string',
            help="Specify bixi stations data")

    # première step. Parsing des déplacements
    # clé : code de la station; values :compte au départ et compte à l'arrivée
    def mapper_get_count(self, key, line):
        (start_date,start_station_code,end_date,end_station_code,duration_sec,is_member) = line.split(',')
        if (start_date != 'start_date'):  # skip first line
            # récupérer la période
            periode = self.getPeriode(start_date)


            yield [start_station_code, periode], (1,0,periode)
            yield [end_station_code, periode], (0,1, periode)

    def getPeriode(self, start_date):
        # extraire l'heure du start_date(2017-04-15 00:00)
        periode = "??"
        #return periode

        heure = int(start_date[11:13])
        if heure >= 6 and heure < 11:
            periode = "06-11"
        elif heure >= 11 and heure < 16:
            periode = "11-16"
        elif heure >= 16 and heure < 20:
            periode = "16-20"
        else:
            periode = "20-06"
        return periode

    # Faire la somme du nonbre de départ et d'arrivée par station
    def reducer_total_station(self, key, occurences):
        total_start = 0
        total_end = 0
        for item in occurences:
            total_start += item[0]
            total_end += item[1]
        yield key, (total_start, total_end)

    # 2ieme step
    # Initialisation au mapper pour avoir la liste des stations et ses paramètres (code postal)
    def mapper_init2(self):
        self.stations = { }
        file = open(self.options.Bixi_Stations, "r")

        for line in file.readlines():
            (code,name,latitude,longitude,altitude,postal,city) = line.strip().split(",")
            # associer l'ID de la station avec le code postal (3 premiers caracteres)
            self.stations[code] = postal[:3]
        file.close()

    # Clé: Code postal
    def mapper_join(self, key, values):
        #yield [self.stations[key[0]],key[1]], values  # code postal - periode
        yield [key[1]], values   # seulement par période

    #
    def reducer_join(self, key, values):
        total_start = 0
        total_end = 0
        for item in values:
            total_start += item[0]
            total_end += item[1]

        yield key, (total_start, total_end, total_start - total_end)

    def steps(self):
        return [
            MRStep(mapper=self.mapper_get_count, reducer=self.reducer_total_station)
            , MRStep(mapper_init=self.mapper_init2, mapper=self.mapper_join, reducer = self.reducer_join)
        ]


if __name__ == '__main__':
    MRPMV_Bixi1.run()