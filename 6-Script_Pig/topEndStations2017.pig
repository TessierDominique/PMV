deplacements = load '/pmv/deplacements/2017/*.*'  USING PigStorage(',') as (start_date,start_station_code,end_date,end_station_code,duration_sec,is_member);

deplacements_minus = FOREACH deplacements GENERATE start_station_code,end_station_code,duration_sec;

deplacements_important = FILTER deplacements_minus by duration_sec > 180 and start_station_code  != end_station_code;

start_end = GROUP deplacements_important by (start_station_code,end_station_code);

start_end_freq = FOREACH start_end GENERATE flatten($0),COUNT($1) as count;

gStart_end_freq = GROUP start_end_freq by start_station_code;

topEndStation = foreach gStart_end_freq generate TOP(5,2,start_end_freq);         

store topEndStation into '/pmv/topEndStation2017';
