# Ce programme permet de générer une liste de (cpStart, cpEnd) nombre de déplacements
# En input: Le fichier de déplacement de Bixi_Stations
# Les paramètres en option: 
#	Bixi_Stations: La description des stations Bixi_Stations
#  	PostalCodeLength: Pour récupérer le code postal sur 2 ou 3 caractères (ex. PostalCodeLength=2)
# Note: Pour rediriger l'output, utiliser les options --output-dir "local directory" --no-output"


from mrjob.job import MRJob
from mrjob.job import MRStep


class MRPMV_Bixi1(MRJob):

    #OUTPUT_PROTOCOL = CsvProtocol  # write output as CSV

    # permet d'avoir des paramètres autre que le fichier d'entrée
    # --Bixi_Stations suivi du fichier avec les données sur les stations BIXI
    def configure_args(self):
        super(MRPMV_Bixi1, self).configure_args()
        self.add_passthru_arg(
            '--Bixi_Stations', default='string',help="Specify bixi stations data")
        self.add_passthru_arg(
            '--PostalCodeLength', default='int', help="Specify Postal code Length")

    #def configure_options(self):
    #    super(MRPMV_Bixi1, self).configure_options()
    #    self.add_file_option('--Bixi_Stations', help="Specify bixi stations data")

    # Initialisation au mapper pour avoir la liste des stations et ses paramètres (code postal) 
    def mapper_init_stations(self):
        self.stations = { }
        file = open(self.options.Bixi_Stations, "r")

        for line in file.readlines():
            (code,name,latitude,longitude,altitude,postal,city) = line.strip().split(",")
            # associer l'ID de la station avec le code postal (3 premiers caracteres)
            self.stations[code] = postal[:int(self.options.PostalCodeLength)]
        file.close()
                
    # première step. Parsing des déplacements
    # clé : code de la station; values :compte au départ et compte à l'arrivée
    def mapper_get_count(self, key, line):
        (start_date,start_station_code,end_date,end_station_code,duration_sec,is_member) = line.split(',')
        if (start_date != 'start_date'):  #skip first line
            # récupérer les codes postaux d'arrivée et de départ
            cpStart = self.stations[start_station_code]
            cpEnd = self.stations[end_station_code]


            # skip stations non associées à un code postal (il y en avait 6)
            if (cpStart != "None"[:int(self.options.PostalCodeLength)] and cpEnd != "None"[:int(self.options.PostalCodeLength)]):
                yield (self.stations[start_station_code],self.stations[end_station_code]), 1


    # Faire la somme du nonbre de départ et d'arrivée par station
    def reducer_total_station(self, key, occurences):       
        yield key, sum(occurences)

  
    def steps(self):
        return [
            MRStep(mapper_init=self.mapper_init_stations, mapper=self.mapper_get_count, reducer=self.reducer_total_station)
        ]


if __name__ == '__main__':
    MRPMV_Bixi1.run()