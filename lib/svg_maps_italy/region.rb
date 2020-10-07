# Class:     /home/vonvikken/svg-maps/lib/region.rb
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

require_relative 'admin_subdivision'
require 'singleton'

module SVGMapsItaly
  # Italian region
  class Region < AdminSubdivisionSet
    include Singleton

    def initialize
      super
      self << AdminSubdivision.new('Abruzzo', 'ABR')
      self << AdminSubdivision.new('Basilicata', 'BAS')
      self << AdminSubdivision.new('Calabria', 'CAL')
      self << AdminSubdivision.new('Campania', 'CAM')
      self << AdminSubdivision.new('Emilia-Romagna', 'EMR')
      self << AdminSubdivision.new('Friuli-Venezia Giulia', 'FVG')
      self << AdminSubdivision.new('Lazio', 'LAZ')
      self << AdminSubdivision.new('Liguria', 'LIG')
      self << AdminSubdivision.new('Lombardia', 'LOM')
      self << AdminSubdivision.new('Marche', 'MAR')
      self << AdminSubdivision.new('Molise', 'MOL')
      self << AdminSubdivision.new('Piemonte', 'PIE')
      self << AdminSubdivision.new('Puglia', 'PUG')
      self << AdminSubdivision.new('Sardegna', 'SAR')
      self << AdminSubdivision.new('Sicilia', 'SIC')
      self << AdminSubdivision.new('Toscana', 'TOS')
      self << AdminSubdivision.new('Trentino-Alto Adige', 'TAA')
      self << AdminSubdivision.new('Umbria', 'UMB')
      self << AdminSubdivision.new("Valle d'Aosta", 'VDA')
      self << AdminSubdivision.new('Veneto', 'VEN')
    end
  end
end
