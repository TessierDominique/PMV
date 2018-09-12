# coded in PyCharms
# parametres: data/OD_2017-11.csv -o output_PMV_BIXI_duration.txt
# le but de ce code est de trouver la distribution de la duration de deplacement du bixi.


from mrjob.job import MRJob
from mrjob.job import MRStep


class PMV_BIXI_Duration(MRJob):
    total = [0, 0]

    def mapper(self, key, line):
        if "duration_sec" not in line:
            start_date, start_station_code, end_date, end_station_code, duration_sec, is_member = line.split(',')
            period = int((int(duration_sec)/900))

            yield [period, is_member], 1
            yield ["Total", is_member], 1

    def reducer(self, key, counts):
        period = key[0]
        isMember = key[1]
        if period == "Total":
            periodStr = "A: Total"  # Mettre "A" devant pour avoir le total en premier lors du 2ieme reduce
        else:
            periodStr = "Periode: " + str(period*15) + "-" + str((period + 1)*15) + " minutes"

        yield [periodStr,isMember], sum(counts)

    def compute_stats(self, key, value):

        isMember = int(key[1])

        for data in value:
            if key[0] == "A: Total":
                self.total[isMember] = data
            else:
                percent = 100.0 * data / self.total[isMember]
                percentStr = "{0:.2f}%".format(percent)
                yield (key), (data, percentStr)

    def steps(self):
        return [
            MRStep(mapper=self.mapper, reducer=self.reducer)
            , MRStep(reducer=self.compute_stats)
        ]

if __name__ == '__main__':
    PMV_BIXI_Duration.run()