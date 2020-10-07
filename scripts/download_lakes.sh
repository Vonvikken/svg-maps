#!/bin/bash
#
# Class:     /home/vonvikken/svg-maps/scripts/download_lakes.sh
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

# Delay between downloads. Used to avoid exceeding Overpass server quotas.
DELAY=30

echo -e "${RED}Warning!${NORM} This script waits ${DELAY} seconds between downloads in order to avoid exceeding server quotas."
echo -e "Press ${YELLOW}Ctrl+C${NORM} to exit or any key to continue..."
read -n 1 -s -r

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

echo

NL=$'\n'

FOOTER=$(
  cat <<EOL
);
out body;
>;
out skel qt;
EOL
)

lazio=(
  "Lago Albano"
  "Lago di Bolsena"
  "Lago di Bracciano"
  "Lago di Vico"
)

lombardia=(
  "Lago di Como"
  "Lago d'Iseo"
  "Lago di Varese"
  "Lago di Mezzola"
  "Lago di Lugano"
  "Lago d'Idro"
)

piemonte=(
  "Lago d'Orta"
  "Lago Maggiore"
)

puglia=(
  "Lago di Varano"
  "Lago di Lesina"
)

sardegna=(
  "Lago Omodeo"
  "Lago Coghinas"
)

toscana=(
  "Lago di Massaciuccoli"
)

umbria=(
  "Lago Trasimeno"
)

veneto=(
  "Lago di Garda"
  "Lago di Santa Croce"
)

cd ../data || exit
mkdir -p water

function dl_lakes() {
  local region
  local lake_list
  local lines
  local header
  local cmd

  region="$1"
  shift
  lake_list=("$@")

  echo -e "Downloading lakes in ${CYAN}${region}${NORM}..."

  header=$(
    cat <<EOL
[out:json][timeout:50];
area[name=${region}]->.searchArea;
(
EOL
  )

  for l in "${lake_list[@]}"; do
    lines=${lines}"  nwr[natural=water][name=\"${l}\"](area.searchArea);${NL}"
  done

  cmd="${header}${NL}${lines}${FOOTER}"
  curl -X POST -H "Content-Type: text/json" -d "${cmd}" "http://overpass-api.de/api/interpreter" -o "tmp/lakes_${region}.json" &&
    osmtogeojson "tmp/lakes_${region}.json" >"tmp/lakes_${region}.geojson"
  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Done!${NORM}"
    rm -f "tmp/lakes_${region}.json"
    echo
  else
    echo -e "${RED}error!${NORM}"
    echo -e "Could not download ${CYAN}${region}${NORM}!"
    exit
  fi
}

function delay() {
  echo "Waiting ${DELAY} seconds..."
  sleep ${DELAY}
}

dl_lakes "Lazio" "${lazio[@]}"
delay
dl_lakes "Lombardia" "${lombardia[@]}"
delay
dl_lakes "Piemonte" "${piemonte[@]}"
delay
dl_lakes "Puglia" "${puglia[@]}"
delay
dl_lakes "Sardegna" "${sardegna[@]}"
delay
dl_lakes "Toscana" "${toscana[@]}"
delay
dl_lakes "Umbria" "${umbria[@]}"
delay
dl_lakes "Veneto" "${veneto[@]}"

(
  cd tmp || exit
  mapfile -t file_list < <(ls lakes_*.geojson)
  echo "Combining files..."
  cmd="mapshaper -i ${file_list[*]} combine-files -merge-layers force -o ../water/lakes.geojson"
  (${cmd})
  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Done!${NORM}"
    rm -f -- *.geojson
    echo
  else
    echo -e "${RED}error!${NORM}"
    echo -e "Could not combine files!"
    exit
  fi
)

echo "$(pwd)/water/lakes.geojson created!"
cd ../scripts || exit
