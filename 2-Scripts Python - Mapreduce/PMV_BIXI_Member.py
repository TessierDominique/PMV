# coded in PyCharms
# parametres: data/OD_2017-11.csv -o output_PMV_BIXI_Member.txt
# le but de ce code est de calculer les deplacements par membre et non_membre


from mrjob.job import MRJob

class PMV_BIXI_Member(MRJob):
    def mapper(self, key, line):
        start_date, start_station_code, end_date, end_station_code, duration_sec, is_member = line.split(',')
        if start_date != "start_date":
            yield is_member,1


    def reducer(self, is_member, counts):
        if is_member == '1':
            yield "Member",sum(counts)
        elif is_member == '0':
            yield "Non_Member",sum(counts)
        else:
            yield 'Unknown', sum(counts)



if __name__ == '__main__':
    PMV_BIXI_Member.run()

