library(jsonlite)
library(dplyr)


stations = fromJSON(txt ="station_information.json") %>% as.data.frame()
#head(stations)
#str(stations)
names(stations)
station_id = stations$data.stations.station_id
name = stations$data.stations.name
short_name = stations$data.stations.short_name
capacity = stations$data.stations.capacity

stations_info  = data.frame(station_id,name,short_name,capacity)
head(stations_info)
write.csv(stations_info,file="stations_capacity.csv")
