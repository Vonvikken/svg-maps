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

cd ../data || exit

(
  cd water || exit
  mapshaper -i lag.geojson -target type=polygon -o lagoon.geojson || exit
)

regions=( "veneto" "friuli-venezia giulia" "emilia-romagna" "toscana")
for r in "${regions[@]}"
do
    mapshaper -i "regions/${r}.geojson" -target type=polygon -filter admin_level==4 -erase water/lagoon.geojson -o "tmp/${r}_cut_4.geojson"
    mapshaper -i "regions/${r}.geojson" -target type=polygon -filter admin_level==6 -erase water/lagoon.geojson -o "tmp/${r}_cut_6.geojson"
    mapshaper -i "regions/${r}.geojson" -target type=polygon -filter admin_level==8 -erase water/lagoon.geojson -o "tmp/${r}_cut_8.geojson"
    mapshaper -i "tmp/${r}_cut_4.geojson" "tmp/${r}_cut_6.geojson" "tmp/${r}_cut_8.geojson" combine-files -merge-layers force -o "tmp/${r}.geojson"
    rm -f "tmp/${r}_cut_[4-8].geojson"
    mv "tmp/${r}.geojson" regions/
done

cd ../scripts || exit
