from itertools import islice
import csv

stationInfo = {}

fileStations = open("Stations_2017.csv")
for l in islice(fileStations,1,None):
    code, name, latitude, longitude = l.strip().split(",")
    stationInfo[code] = [name,latitude,longitude]
fileIn = open("result_topEndStation2017_part-r-00000")
dataOut = []

remap = {
    ord('{'):None,
    ord('('):None,
    ord(')'):None,
    ord('}'):None
}

for l in islice(fileIn, 1, None):
    l = l.translate(remap)
    print(l)
    eles = l.strip().split(",")
    for i in range(0, 5):
        origin = "Origin," + eles[i*3] + "," + eles[i*3] + "_" + eles[i*3+1]+","+stationInfo[eles[i*3]][1]+"," + \
                 stationInfo[eles[i*3]][2]+","+eles[i*3+2]
        destination = "Destination," + eles[i*3+1] + "," + eles[i*3] + "_" + eles[i*3+1]+"," + \
                      stationInfo[eles[i*3+1]][1] + "," + stationInfo[eles[i*3+1]][2]+","+eles[i*3+2]
        dataOut.append(origin)
        dataOut.append(destination)

with open('les5PlusImportantDestinations.csv', 'w') as f:
    for d in dataOut:
        f.write(d)
        f.write('\n')