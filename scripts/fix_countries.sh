#!/bin/bash
#
# Class:     /home/vonvikken/svg-maps/scripts/fix_countries.sh
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

countries=("fr" "ch" "at" "sl" "sm" "va")

cd ../data/states || exit

for c in "${countries[@]}"; do
  filename="${c}.geojson"
  echo -e "Processing ${CYAN}${filename}${NORM}..."
  mapshaper -i "${filename}" -each 'admin_level=admin_level.toString();id=id.toString()' -o force "${filename}"
  # shellcheck disable=SC2181
  if [ $? -eq 0 ]; then
    echo -e "${GREEN}Done!${NORM}"
    echo
  else
    echo -e "${RED}Error!${NORM}"
    echo -e "Could not process file!"
    exit
  fi
done

cd ../../scripts || exit
