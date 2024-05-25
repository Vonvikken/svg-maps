#!/bin/bash
# Class:     /home/vonvikken/svg-maps/scripts/wizard_regions.sh
# Author:    Vincenzo Stornanti <von.vikken@gmail.com>
#
# Copyright 2024 Vincenzo Stornanti
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
  "Since there are up to 20 regions to download, it could take several minutes to finish."
echo -e "Press ${YELLOW}Ctrl+C${NORM} to exit or any key to continue..."
read -n 1 -s -r

echo
echo -ne "Checking whether ${PURPLE}osmtogeojson${NORM} is installed... "
npm list -g osmtogeojson --depth 1 >/dev/null 2>&1

if [ $? -eq 0 ]; then
  echo -e "${GREEN}OK${NORM}!"
else
  echo -e "${RED}not found${NORM}!"
  echo -e "Please install it with the command ${YELLOW}npm install -g osmtogeojson${NORM}" >&2
  exit
fi

mkdir -p ../data/regions
mkdir -p ../data/tmp

pushd ../data/regions || exit

sleep 1s

declare -A regions=( \
  ["pie"]="Piemonte" \
  ["vda"]="Valle d'Aosta" \
  ["lom"]="Lombardia" \
  ["taa"]="Trentino-Alto Adige" \
  ["ven"]="Veneto" \
  ["fvg"]="Friuli-Venezia Giulia" \
  ["lig"]="Liguria" \
  ["emr"]="Emilia-Romagna" \
  ["tos"]="Toscana" \
  ["umb"]="Umbria" \
  ["mar"]="Marche" \
  ["laz"]="Lazio" \
  ["abr"]="Abruzzo" \
  ["mol"]="Molise" \
  ["cam"]="Campania" \
  ["pug"]="Puglia" \
  ["bas"]="Basilicata" \
  ["cal"]="Calabria" \
  ["sic"]="Sicilia" \
  ["sar"]="Sardegna" \
)

# ISO 3166-2:IT code of each region
declare -A codes=( \
  ["pie"]=21 \
  ["vda"]=23 \
  ["lom"]=25 \
  ["taa"]=32 \
  ["ven"]=34 \
  ["fvg"]=36 \
  ["lig"]=42 \
  ["emr"]=45 \
  ["tos"]=52 \
  ["umb"]=55 \
  ["mar"]=57 \
  ["laz"]=62 \
  ["abr"]=65 \
  ["mol"]=67 \
  ["cam"]=72 \
  ["pug"]=75 \
  ["bas"]=77 \
  ["cal"]=78 \
  ["sic"]=82 \
  ["sar"]=88 \
)

exec 3>&1

choices=($(dialog --title "Download regions" \
	--clear \
  --checklist "" 26 38 20 \
    pie "Piemonte" on \
    vda "Valle d'Aosta" on \
    lom "Lombardia" on \
    taa "Trentino-Alto Adige" on \
    ven "Veneto" on \
    fvg "Friuli-Venezia Giulia" on \
    lig "Liguria" on \
    emr "Emilia-Romagna" on \
    tos "Toscana" on \
    umb "Umbria" on \
    mar "Marche" on \
    laz "Lazio" on \
    abr "Abruzzo" on \
    mol "Molise" on \
    cam "Campania" on \
    pug "Puglia" on \
    bas "Basilicata" on \
    cal "Calabria" on \
    sic "Sicilia" on \
    sar "Sardegna" on \
    2>&1 1>&3))

return_value=$?
exec 3>&-

clear

num_elements=${#choices[@]}
if [ $num_elements -eq 0 ]; then
  echo -e "${RED}No regions selected. Quitting!${NORM}"
  exit
fi

for a in ${choices[@]}; do
  r=${regions[$a]}
  c=${codes[$a]}
  cmd=$(
    cat <<EOT
[out:json][timeout:60];
area["ISO3166-2"="IT-${c}"]->.searchArea;
(
  node["boundary"="administrative"]["admin_level"="4"](area.searchArea);
  node["boundary"="administrative"]["admin_level"="6"](area.searchArea);
  node["boundary"="administrative"]["admin_level"="8"](area.searchArea);
  relation["boundary"="administrative"]["admin_level"="4"](area.searchArea);
  relation["boundary"="administrative"]["admin_level"="6"](area.searchArea);
  relation["boundary"="administrative"]["admin_level"="8"](area.searchArea);
);
out body;
>;
out skel qt;
EOT
  )

  json_name="../tmp/${a}.json"
  geojson_name="${a}.geojson"

  echo
  echo -e "Downloading ${CYAN}${r}${NORM}... "

  curl -X POST -H "Content-Type: text/json" -d "${cmd}" "http://overpass-api.de/api/interpreter" -o "${json_name}"
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Done!${NORM}"
    echo
  else
    echo -e "${RED}error!${NORM}"
    echo -e "Could not download ${CYAN}${r}${NORM}!"
    exit
  fi

  echo -n "Converting to GeoJSON... "
  osmtogeojson "${json_name}" >"${a}".geojson

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}OK!${NORM}"
    echo -e "${CYAN}$(pwd)/${geojson_name}${NORM} created!"
    rm "${json_name}"
    echo
  else
    echo -e "${RED}Error!${NORM}"
    echo -e "Could not convert to ${CYAN}${geojson_name}${NORM}!"
    exit
  fi

  if [ $c -eq 23 ]; then
    echo -e "${YELLOW}Removing anomaly due to border dispute...${NORM}"
    /usr/bin/env ruby ../../scripts/remove_vda_anomaly.rb "vda.geojson"
  fi
  
  ((--num_elements))
  echo -e "Number of regions remaining: ${CYAN}$num_elements${NORM}"

  if [ $num_elements -gt 0 ]; then
    echo "Waiting ${DELAY} seconds..."
    sleep ${DELAY}
    echo
  fi
done

echo -e "${GREEN}Download complete!${NORM} For a better appearance of some regions, you can now run ${YELLOW}cut_lagoons.sh${NORM}!"

popd > /dev/null

