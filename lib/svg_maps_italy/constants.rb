# Class:     /home/vonvikken/svg-maps/lib/constants.rb
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

# frozen_string_literal: true

module SVGMapsItaly
  # Constants used in CSS stylesheets
  module CSSConstants
    # Foreign nations
    CLASS_FOREIGN = 'foreign'

    # Other regions
    CLASS_REGION = 'region'

    # Other provinces
    CLASS_PROVINCE = 'province'

    # Comuni
    CLASS_COMUNE = 'comune'

    # Highlighted comune
    CLASS_INTEREST = 'interest'

    # Lakes
    CLASS_LAKE = 'lake'
  end

  # File and directory paths
  module PathConstants
    DEFAULT_DATA_DIR = 'data'
    OUT_DIR = 'out'
    TMP_DIR = 'tmp'
    REGIONS_DIR = 'regions'
    STATES_DIR = 'states'
    LAKES_PATH = 'water/lakes.geojson'
    DEFAULT_CSS_PATH = '../style/style.css'
  end
end
