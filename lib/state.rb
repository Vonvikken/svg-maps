# Class:     /home/vonvikken/svg-maps/lib/state.rb
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

# Italian neighboring states
class State < AdminSubdivisionSet
  self << AdminSubdivision.new('Slovenija', 'SLO', 'slovenia')
  self << AdminSubdivisionnew('Österreich', 'AUT', 'austria')
  self << AdminSubdivisionnew('Svizzera', 'CH', 'svizzera')
  self << AdminSubdivisionnew('France', 'FR', 'francia')
  self << AdminSubdivisionnew('San Marino', 'RSM', 'san marino')
  self << AdminSubdivisionnew('Città del Vaticano', 'SCV', 'vaticano')

  class << self
    private :new
  end
end
