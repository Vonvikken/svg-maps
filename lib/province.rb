# Class:     /home/vonvikken/svg-maps/lib/province.rb
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

# Single Province element
class ProvinceElem < AdminSubdivision
  # The region the province/metropolitan city belongs to
  attr_reader :reg

  # True if the province has a level 6 entity on map, otherwise level 8 will be used. Currently only Aosta doesn't.
  attr_reader :level6

  def initialize(name, abbr, region, level_6 = true)
    super(name, abbr)
    @reg = Region.instance.find region
    @level6 = level_6
  end

  def code
    'IT-' + @abbr
  end

  def to_s
    "#{@abbr}:\t#{@name}"
  end

  def inspect
    "#{@abbr} [#{@reg.abbr}]:\t#{@name}"
  end
end

# Italian metropolitan cities and provinces
class Province < AdminSubdivisionSet
  include Singleton

  def initialize
    super

    # Metropolitan cities
    self << ProvinceElem.new('Bari', 'BA', 'PUG')
    self << ProvinceElem.new('Bologna', 'BO', 'EMR')
    self << ProvinceElem.new('Cagliari', 'CA', 'SAR')
    self << ProvinceElem.new('Catania', 'CT', 'SIC')
    self << ProvinceElem.new('Firenze', 'FI', 'TOS')
    self << ProvinceElem.new('Genova', 'GE', 'LIG')
    self << ProvinceElem.new('Messina', 'ME', 'SIC')
    self << ProvinceElem.new('Milano', 'MI', 'LOM')
    self << ProvinceElem.new('Napoli', 'NA', 'CAM')
    self << ProvinceElem.new('Palermo', 'PA', 'SIC')
    self << ProvinceElem.new('Reggio Calabria', 'RC', 'CAL')
    self << ProvinceElem.new('Roma', 'RM', 'LAZ')
    self << ProvinceElem.new('Torino', 'TO', 'PIE')
    self << ProvinceElem.new('Venezia', 'VE', 'VEN')

    # Provinces
    self << ProvinceElem.new('Agrigento', 'AG', 'SIC')
    self << ProvinceElem.new('Alessandria', 'AL', 'PIE')
    self << ProvinceElem.new('Aosta', 'AO', 'VDA', false)
    self << ProvinceElem.new('Ancona', 'AN', 'MAR')
    self << ProvinceElem.new('Arezzo', 'AR', 'TOS')
    self << ProvinceElem.new('Ascoli Piceno', 'AP', 'MAR')
    self << ProvinceElem.new('Asti', 'AT', 'PIE')
    self << ProvinceElem.new('Avellino', 'AV', 'CAM')
    self << ProvinceElem.new('Barletta-Andria-Trani', 'BT', 'PUG')
    self << ProvinceElem.new('Belluno', 'BL', 'VEN')
    self << ProvinceElem.new('Benevento', 'BN', 'CAM')
    self << ProvinceElem.new('Bergamo', 'BG', 'LOM')
    self << ProvinceElem.new('Biella', 'BI', 'PIE')
    self << ProvinceElem.new('Bolzano', 'BZ', 'TAA')
    self << ProvinceElem.new('Brescia', 'BS', 'LOM')
    self << ProvinceElem.new('Brindisi', 'BR', 'PUG')
    self << ProvinceElem.new('Caltanissetta', 'CL', 'SIC')
    self << ProvinceElem.new('Campobasso', 'CB', 'MOL')
    self << ProvinceElem.new('Caserta', 'CE', 'CAM')
    self << ProvinceElem.new('Catanzaro', 'CZ', 'CAL')
    self << ProvinceElem.new('Chieti', 'CH', 'ABR')
    self << ProvinceElem.new('Como', 'CO', 'LOM')
    self << ProvinceElem.new('Cosenza', 'CS', 'CAL')
    self << ProvinceElem.new('Cremona', 'CR', 'LOM')
    self << ProvinceElem.new('Crotone', 'KR', 'CAL')
    self << ProvinceElem.new('Cuneo', 'CN', 'PIE')
    self << ProvinceElem.new('Enna', 'EN', 'SIC')
    self << ProvinceElem.new('Fermo', 'FM', 'MAR')
    self << ProvinceElem.new('Ferrara', 'FE', 'EMR')
    self << ProvinceElem.new('Foggia', 'FG', 'PUG')
    self << ProvinceElem.new('Forlì-Cesena', 'FC', 'EMR')
    self << ProvinceElem.new('Frosinone', 'FR', 'LAZ')
    self << ProvinceElem.new('Gorizia', 'GO', 'FVG')
    self << ProvinceElem.new('Grosseto', 'GR', 'TOS')
    self << ProvinceElem.new('Imperia', 'IM', 'LIG')
    self << ProvinceElem.new('Isernia', 'IS', 'MOL')
    self << ProvinceElem.new('La Spezia', 'SP', 'LIG')
    self << ProvinceElem.new("L'Aquila", 'AQ', 'ABR')
    self << ProvinceElem.new('Latina', 'LT', 'LAZ')
    self << ProvinceElem.new('Lecce', 'LE', 'PUG')
    self << ProvinceElem.new('Lecco', 'LC', 'LOM')
    self << ProvinceElem.new('Livorno', 'LI', 'TOS')
    self << ProvinceElem.new('Lodi', 'LO', 'LOM')
    self << ProvinceElem.new('Lucca', 'LU', 'TOS')
    self << ProvinceElem.new('Macerata', 'MC', 'MAR')
    self << ProvinceElem.new('Mantova', 'MN', 'LOM')
    self << ProvinceElem.new('Massa-Carrara', 'MS', 'TOS')
    self << ProvinceElem.new('Matera', 'MT', 'BAS')
    self << ProvinceElem.new('Monza e Brianza', 'MB', 'LOM')
    self << ProvinceElem.new('Modena', 'MO', 'EMR')
    self << ProvinceElem.new('Novara', 'NO', 'PIE')
    self << ProvinceElem.new('Nuoro', 'NU', 'SAR')
    self << ProvinceElem.new('Oristano', 'OR', 'SAR')
    self << ProvinceElem.new('Padova', 'PD', 'VEN')
    self << ProvinceElem.new('Parma', 'PR', 'EMR')
    self << ProvinceElem.new('Pavia', 'PV', 'LOM')
    self << ProvinceElem.new('Perugia', 'PG', 'UMB')
    self << ProvinceElem.new('Pesaro e Urbino', 'PU', 'MAR')
    self << ProvinceElem.new('Pescara', 'PE', 'ABR')
    self << ProvinceElem.new('Piacenza', 'PC', 'EMR')
    self << ProvinceElem.new('Pisa', 'PI', 'TOS')
    self << ProvinceElem.new('Pistoia', 'PT', 'TOS')
    self << ProvinceElem.new('Pordenone', 'PN', 'FVG')
    self << ProvinceElem.new('Potenza', 'PZ', 'BAS')
    self << ProvinceElem.new('Prato', 'PO', 'TOS')
    self << ProvinceElem.new('Ragusa', 'RG', 'SIC')
    self << ProvinceElem.new('Ravenna', 'RA', 'EMR')
    self << ProvinceElem.new('Reggio Emilia', 'RE', 'EMR')
    self << ProvinceElem.new('Rieti', 'RI', 'LAZ')
    self << ProvinceElem.new('Rimini', 'RN', 'EMR')
    self << ProvinceElem.new('Rovigo', 'RO', 'VEN')
    self << ProvinceElem.new('Salerno', 'SA', 'CAM')
    self << ProvinceElem.new('Sassari', 'SS', 'SAR')
    self << ProvinceElem.new('Savona', 'SV', 'LIG')
    self << ProvinceElem.new('Siena', 'SI', 'TOS')
    self << ProvinceElem.new('Siracusa', 'SR', 'SIC')
    self << ProvinceElem.new('Sondrio', 'SO', 'LOM')
    self << ProvinceElem.new('Sud Sardegna', 'SU', 'SAR')
    self << ProvinceElem.new('Taranto', 'TA', 'PUG')
    self << ProvinceElem.new('Teramo', 'TE', 'ABR')
    self << ProvinceElem.new('Terni', 'TR', 'UMB')
    self << ProvinceElem.new('Trapani', 'TP', 'SIC')
    self << ProvinceElem.new('Trento', 'TN', 'TAA')
    self << ProvinceElem.new('Treviso', 'TV', 'VEN')
    self << ProvinceElem.new('Trieste', 'TS', 'FVG')
    self << ProvinceElem.new('Udine', 'UD', 'FVG')
    self << ProvinceElem.new('Varese', 'VA', 'LOM')
    self << ProvinceElem.new('Verbano-Cusio-Ossola', 'VB', 'PIE')
    self << ProvinceElem.new('Vercelli', 'VC', 'PIE')
    self << ProvinceElem.new('Verona', 'VR', 'VEN')
    self << ProvinceElem.new('Vibo Valentia', 'VV', 'CAL')
    self << ProvinceElem.new('Vicenza', 'VI', 'VEN')
    self << ProvinceElem.new('Viterbo', 'VT', 'LAZ')
  end
end
