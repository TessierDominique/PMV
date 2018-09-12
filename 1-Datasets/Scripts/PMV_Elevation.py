# -----------------------------------
# NO DEPENDANCIES except JSON and URLLIB
# -----------------------------------
# 
# Copyright (c) 2016, Guillaume Meunier <alliages@gmail.com> 
# GEOJSON_export is free software; you can redistribute it and/or modify 
# it under the terms of the GNU General Public License as published 
# by the Free Software Foundation; either version 3 of the License, 
# or (at your option) any later version. 
# 
# GEOJSON_export is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of 
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License
# along with GEOJSON_export; If not, see <http://www.gnu.org/licenses/>.
# 
# @license GPL-3.0+ <http://spdx.org/licenses/GPL-3.0+>
#
# EXAMPLE :
# print elevation(48.8445548,2.4222176)

import json
import urllib.request

# **********************************************************************
# A partir de la latitude et de la longitude
# Calculer la hauteur
# Note: Il faut un compte Google
# Input: latitude et longitude
# Output: elevation
# **********************************************************************

def elevation(lat, lng):
    elevationRes = -1.0  # Valeur invalide

    # apiKey donné par Google lorsque l'on s'inscrit (a générer pour chaque compte)
    # Inserer votre API key
    # Voir "https://developers.google.com/maps/documentation/javascript/get-api-key" pour obtenir une cle
    apikey = "Insert you key"


    # voir "https://developers.google.com/maps/documentation/elevation/start" pour plus d'info
    ELEVATION_BASE_URL = 'https://maps.googleapis.com/maps/api/elevation/json'
    URL_PARAMS = "?locations="+str(lat)+","+str(lng)+"&key="+apikey
    url = ELEVATION_BASE_URL + URL_PARAMS

    with urllib.request.urlopen(url) as f:
        response = json.loads(f.read().decode())

    # On a trouvé quelque chose
    if 0 < len(response):
        status = response["status"]
        if status == "OK":
            # extraire l'altitude
            result = response["results"][0]
            elevationRes = float(result["elevation"])
        else:
            print(status)

    else:
        print ('HTTP GET Request failed.')

    return elevationRes


# **********************************************************************
# Debut du programme pour faire un test
# **********************************************************************

if __name__ == '__main__':
    res = elevation(45.43443353453236,-73.58669400215149)
    print ('%.0f'%float(res))

