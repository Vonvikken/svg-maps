#!/bin/bash
#
# Class:     /home/vonvikken/svg-maps/scripts/cut_lagoons.sh
# Author:    Vincenzo Stornanti <von.vikken@gmail.com>
#
# Copyright 2020 Vincenzo Stornanti
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
PURPLE='\033[1;35m'
CYAN='\033[0;36m'
NORM='\033[0m'

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

echo -ne "Checking whether ${PURPLE}mapshaper${NORM} is installed... "
npm list -g mapshaper --depth 1 >/dev/null 2>&1
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
  echo -e "${GREEN}OK${NORM}!"
else
  echo -e "${RED}not found${NORM}!"
  echo -e "Please install it with the command ${YELLOW}npm install -g mapshaper${NORM}" >&2
  exit
fi

cd ../data || exit

cmd=$(
  cat <<EOT
[out:json][timeout:90];
(
  area[name="Friuli Venezia Giulia"];
  area[name="Veneto"];
  area[name="Toscana"];
  area[name="Emilia-Romagna"];
)->.searchArea;
(
  nwr[natural=water][water=lagoon](area.searchArea);
  nwr[natural=water][name="Valli di Comacchio"](area.searchArea);
);
out body;
>;
out skel qt;
EOT
)

echo
echo "Downloading coastal lagoons... "

curl -X POST -H "Content-Type: text/json" -d "${cmd}" "http://overpass-api.de/api/interpreter" -o "tmp/lagoon.json"
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Done!${NORM}"
  echo
else
  echo -e "${RED}error!${NORM}"
  echo -e "Could not download coastal lagoons!"
  exit
fi

echo
echo "Converting to GeoJson... "
osmtogeojson tmp/lagoon.json >tmp/lagoon.geojson &&
  mapshaper -i tmp/lagoon.geojson -target type=polygon -o water/lagoon.geojson
# shellcheck disable=SC2181
if [ $? -eq 0 ]; then
  echo -e "${GREEN}Done!${NORM}"
  echo
  rm -f tmp/lagoon.json
else
  echo -e "${RED}error!${NORM}"
  echo -e "Could not convert to GeoJson!"
  exit
fi

regions=("ven" "fvg" "emr" "tos")
for r in "${regions[@]}"; do
  echo -e "Converting region ${CYAN}${r}${NORM}..."
  mapshaper -i "regions/${r}.geojson" -target type=polygon -filter admin_level==4 -erase water/lagoon.geojson -o "tmp/${r}_cut_4.geojson"
  mapshaper -i "regions/${r}.geojson" -target type=polygon -filter admin_level==6 -erase water/lagoon.geojson -o "tmp/${r}_cut_6.geojson"
  mapshaper -i "regions/${r}.geojson" -target type=polygon -filter admin_level==8 -erase water/lagoon.geojson -o "tmp/${r}_cut_8.geojson"
  mapshaper -i "tmp/${r}_cut_4.geojson" "tmp/${r}_cut_6.geojson" "tmp/${r}_cut_8.geojson" combine-files -merge-layers force -o "tmp/${r}.geojson"
  rm -f "tmp/${r}_cut_[4-8].geojson"
  mv "tmp/${r}.geojson" regions/
  echo -e "${GREEN}Done!${NORM}"
  echo
done

rm -f tmp/*.geojson

cd ../scripts || exit
