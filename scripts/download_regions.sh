#!/bin/bash
# Class:     /home/vonvikken/svg-maps/scripts/download_regions.sh
# Author:    Vincenzo Stornanti <von.vikken@gmail.com>
#
# Copyright 2020 Vincenzo Stornanti
#
# Licensed under the Apache License Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing software
# distributed under the License is distributed on an "AS IS" BASIS
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[1;35m'
CYAN='\033[0;36m'
NORM='\033[0m'

# Delay between downloads. Used to avoid exceeding Overpass server quotas.
DELAY=90

echo -e "${RED}Warning!${NORM} This script waits ${DELAY} seconds between downloads in order to avoid exceeding server quotas." \
  "Since there are 20 regions to download, it could take several minutes to finish."
echo -e "Press ${YELLOW}Ctrl+C${NORM} to exit or any key to continue..."
read -n 1 -s -r #-p "Press any key to continue"

echo
echo -ne "Checking whether ${PURPLE}osmtogeojson${NORM} is installed... "
npm list -g osmtogeojson --depth 1 >/dev/null 2>&1
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
  echo -e "${GREEN}OK${NORM}!"
else
  echo -e "${RED}not found${NORM}!"
  echo -e "Please install it with the command ${YELLOW}npm install -g osmtogeojson${NORM}" >&2
  exit
fi

mkdir -p ../data/regions
mkdir -p ../data/tmp

cd ../data/regions || exit

regions=("piemonte" "valle aosta" "lombardia" "trentino-alto adige" "veneto" "friuli-venezia giulia" "liguria"
  "emilia-romagna" "toscana" "umbria" "marche" "lazio" "abruzzo" "molise" "campania" "puglia" "basilicata"
  "calabria" "sicilia" "sardegna")

# ISO 3166-2:IT code of each region
codes=(21 23 25 32 34 36 42 45 52 55 57 62 65 67 72 75 77 78 82 88)

#for i in "${!regions[@]}"; do
#  r=${regions[$i]}
#  c=${codes[$i]}
#  cmd=$(
#    cat <<EOT
#[out:json][timeout:60];
#area["ISO3166-2"="IT-${c}"]->.searchArea;
#(
#  node["boundary"="administrative"]["admin_level"="4"](area.searchArea);
#  node["boundary"="administrative"]["admin_level"="6"](area.searchArea);
#  node["boundary"="administrative"]["admin_level"="8"](area.searchArea);
#  relation["boundary"="administrative"]["admin_level"="4"](area.searchArea);
#  relation["boundary"="administrative"]["admin_level"="6"](area.searchArea);
#  relation["boundary"="administrative"]["admin_level"="8"](area.searchArea);
#);
#out body;
#>;
#out skel qt;
#EOT
#  )
#
#  echo
#  echo -e "Downloading ${CYAN}${r}.json${NORM}... "
#
#  curl -X POST -H "Content-Type: text/json" -d "${cmd}" "http://overpass-api.de/api/interpreter" -o "../tmp/${r}".json
#  # shellcheck disable=SC2181
#  if [ $? -eq 0 ]; then
#    echo -e "${GREEN}Done!${NORM}"
#    echo
#  else
#    echo -e "${RED}error!${NORM}"
#    echo -e "Could not download ${CYAN}${r}${NORM}!"
#    exit
#  fi
#
#  echo -n "Converting to GeoJSON... "
#  osmtogeojson "../tmp/${r}".json >"${r}".geojson
#  # shellcheck disable=SC2181
#  if [ $? -eq 0 ]; then
#    echo -e "${GREEN}OK!${NORM}"
#    echo -e "${CYAN}$(pwd)/${r}.geojson${NORM} created!"
#    rm "../tmp/${r}".json
#    echo
#  else
#    echo -e "${RED}Error!${NORM}"
#    echo -e "Could not convert to ${CYAN}${r}.geojson${NORM}!"
#    exit
#  fi
#
#  if [ ! "${i}" -eq $((${#regions[@]} - 1)) ]; then
#    echo "Waiting ${DELAY} seconds..."
#    sleep ${DELAY}
#    echo
#  fi
#done

# Removing anomaly due to border dispute...
/usr/bin/env ruby ../../scripts/remove_vda_anomaly.rb "valle aosta.geojson"

echo -e "${GREEN}Download complete!${NORM} For a better appearance of some regions, you can now run ${YELLOW}cut_lagoons.sh${NORM}!"

cd ../.. || exit
