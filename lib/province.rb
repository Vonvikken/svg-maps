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

# Italian metropolitan cities and provinces
class Province < AdminSubdivisionSet
  def code
    'IT-' << @abbr
  end

  # Metropolitan cities
  self << AdminSubdivision.new('Bari', 'BA')
  self << AdminSubdivision.new('Bologna', 'BO')
  self << AdminSubdivision.new('Cagliari', 'CA')
  self << AdminSubdivision.new('Catania', 'CT')
  self << AdminSubdivision.new('Firenze', 'FI')
  self << AdminSubdivision.new('Genova', 'GE')
  self << AdminSubdivision.new('Messina', 'ME')
  self << AdminSubdivision.new('Milano', 'MI')
  self << AdminSubdivision.new('Napoli', 'NA')
  self << AdminSubdivision.new('Palermo', 'PA')
  self << AdminSubdivision.new('Reggio Calabria', 'RC')
  self << AdminSubdivision.new('Roma', 'RM')
  self << AdminSubdivision.new('Torino', 'TO')
  self << AdminSubdivision.new('Venezia', 'VE ')

  # Provinces
  self << AdminSubdivision.new('Agrigento', 'AG')
  self << AdminSubdivision.new('Alessandria', 'AL')
  self << AdminSubdivision.new('Ancona', 'AN')
  self << AdminSubdivision.new('Arezzo', 'AR')
  self << AdminSubdivision.new('Ascoli Piceno', 'AP')
  self << AdminSubdivision.new('Asti', 'AT')
  self << AdminSubdivision.new('Avellino', 'AV')
  self << AdminSubdivision.new('Barletta-Andria-Trani', 'BT')
  self << AdminSubdivision.new('Belluno', 'BL')
  self << AdminSubdivision.new('Benevento', 'BN')
  self << AdminSubdivision.new('Bergamo', 'BG')
  self << AdminSubdivision.new('Biella', 'BI')
  self << AdminSubdivision.new('Bolzano', 'BZ')
  self << AdminSubdivision.new('Brescia', 'BS')
  self << AdminSubdivision.new('Brindisi', 'BR')
  self << AdminSubdivision.new('Caltanissetta', 'CL')
  self << AdminSubdivision.new('Campobasso', 'CB')
  self << AdminSubdivision.new('Caserta', 'CE')
  self << AdminSubdivision.new('Catanzaro', 'CZ')
  self << AdminSubdivision.new('Chieti', 'CH')
  self << AdminSubdivision.new('Como', 'CO')
  self << AdminSubdivision.new('Cosenza', 'CS')
  self << AdminSubdivision.new('Cremona', 'CR')
  self << AdminSubdivision.new('Crotone', 'KR')
  self << AdminSubdivision.new('Cuneo', 'CN')
  self << AdminSubdivision.new('Enna', 'EN')
  self << AdminSubdivision.new('Fermo', 'FM')
  self << AdminSubdivision.new('Ferrara', 'FE')
  self << AdminSubdivision.new('Foggia', 'FG')
  self << AdminSubdivision.new('Forlì-Cesena', 'FC')
  self << AdminSubdivision.new('Frosinone', 'FR')
  self << AdminSubdivision.new('Gorizia', 'GO')
  self << AdminSubdivision.new('Grosseto', 'GR')
  self << AdminSubdivision.new('Imperia', 'IM')
  self << AdminSubdivision.new('Isernia', 'IS')
  self << AdminSubdivision.new('La Spezia', 'SP')
  self << AdminSubdivision.new("L'Aquila", 'AQ')
  self << AdminSubdivision.new('Latina', 'LT')
  self << AdminSubdivision.new('Lecce', 'LE')
  self << AdminSubdivision.new('Lecco', 'LC')
  self << AdminSubdivision.new('Livorno', 'LV')
  self << AdminSubdivision.new('Lodi', 'LO')
  self << AdminSubdivision.new('Lucca', 'LU')
  self << AdminSubdivision.new('Macerata', 'MC')
  self << AdminSubdivision.new('Mantova', 'MN')
  self << AdminSubdivision.new('Massa-Carrara', 'MS')
  self << AdminSubdivision.new('Matera', 'MT')
  self << AdminSubdivision.new('Monza e Brianza', 'MB')
  self << AdminSubdivision.new('Modena', 'MO')
  self << AdminSubdivision.new('Novara', 'NO')
  self << AdminSubdivision.new('Nuoro', 'NU')
  self << AdminSubdivision.new('Oristano', 'OR')
  self << AdminSubdivision.new('Padova', 'PD')
  self << AdminSubdivision.new('Parma', 'PR')
  self << AdminSubdivision.new('Pavia', 'PV')
  self << AdminSubdivision.new('Perugia', 'PG')
  self << AdminSubdivision.new('Pesaro e Urbino', 'PU')
  self << AdminSubdivision.new('Pescara', 'PE')
  self << AdminSubdivision.new('Piacenza', 'PC')
  self << AdminSubdivision.new('Pisa', 'PI')
  self << AdminSubdivision.new('Pistoia', 'PT')
  self << AdminSubdivision.new('Pordenone', 'PN')
  self << AdminSubdivision.new('Potenza', 'PZ')
  self << AdminSubdivision.new('Prato', 'PO')
  self << AdminSubdivision.new('Ragusa', 'RG')
  self << AdminSubdivision.new('Ravenna', 'RA')
  self << AdminSubdivision.new('Reggio Emilia', 'RE')
  self << AdminSubdivision.new('Rieti', 'RI')
  self << AdminSubdivision.new('Rimini', 'RN')
  self << AdminSubdivision.new('Rovigo', 'RO')
  self << AdminSubdivision.new('Salerno', 'SA')
  self << AdminSubdivision.new('Sassari', 'SS')
  self << AdminSubdivision.new('Savona', 'SV')
  self << AdminSubdivision.new('Siena', 'SI')
  self << AdminSubdivision.new('Siracusa', 'SR')
  self << AdminSubdivision.new('Sondrio', 'SO')
  self << AdminSubdivision.new('Sud Sardegna', 'SU')
  self << AdminSubdivision.new('Taranto', 'TA')
  self << AdminSubdivision.new('Teramo', 'TE')
  self << AdminSubdivision.new('Terni', 'TR')
  self << AdminSubdivision.new('Trapani', 'TP')
  self << AdminSubdivision.new('Trento', 'TN')
  self << AdminSubdivision.new('Treviso', 'TV')
  self << AdminSubdivision.new('Trieste', 'TS')
  self << AdminSubdivision.new('Udine', 'UD')
  self << AdminSubdivision.new('Varese', 'VA')
  self << AdminSubdivision.new('Verbano-Cusio-Ossola', 'VB')
  self << AdminSubdivision.new('Vercelli', 'VC')
  self << AdminSubdivision.new('Verona', 'VR')
  self << AdminSubdivision.new('Vibo Valentia', 'VV')
  self << AdminSubdivision.new('Vicenza', 'VI')
  self << AdminSubdivision.new('Viterbo', 'VT')
end
