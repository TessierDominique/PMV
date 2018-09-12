This Tableau visualization work follows and bases on a Pig work which aims to find the 5 most important destinations for each BIXI station in terms of the frequency of trajets made between the two stations. We would like to visualize the result in a map of Montreal by showing some ligne between them, and also other informations.

This work refers to an example as followed:
https://onlinehelp.tableau.com/current/pro/desktop/en-us/help.htm#maps_howto_origin_destination.html

Two source datasets used:
1, the result of Pig work, named as "result_topEndStation2017_part-r-00000"
{(5002,5005,14),(5002,5006,34),(5002,5003,15),(5002,5007,122),(5002,5004,41)}

{(5003,6034,21),(5003,5004,31),(5003,5005,23),(5003,5006,39),(5003,5007,89)}

{(5004,5005,15),(5004,5006,22),(5004,5007,221),(5004,5002,31),(5004,5003,44)}
note: every three number in the parentheses denote (origin_station, destination_station, number_of_trajets)
2, stations of BIXI in 2017, named as "Stations_2017.csv", which can be downloaded from BIXI.com
code,name,latitude,longitude
7015,LaSalle / 4e avenue,45.43074022417498,-73.5919108253438
6714,LaSalle / Sénécal,45.43443353453236,-73.58669400215149
6712,LaSalle / Crawford,45.43791380065227,-73.58274042606354


Some data processing work is done by python to get the right format of input data in Tableau.
program file: topEndStation2017.py
input files: result_topEndStation2017_part-r-00000, Stations_2017.csv
output file: les5PlusImportantDestinations.csv


Tableau
file of Tableau: les5PlusImportantDestinations-BIXI
input files:les5PlusImportantDestinations.csv, Stations_2017.csv

