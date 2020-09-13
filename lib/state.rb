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

require_relative 'admin_subdivision'

# Italian neighboring states
class State < AdminSubdivisionSet
  def initialize
    super

    self << AdminSubdivision.new('Slovenija', 'SL', 'slovenia')
    self << AdminSubdivision.new('Österreich', 'AT', 'austria')
    self << AdminSubdivision.new('Svizzera', 'CH', 'svizzera')
    self << AdminSubdivision.new('France', 'FR', 'francia')
    self << AdminSubdivision.new('San Marino', 'SM', 'san marino')
    self << AdminSubdivision.new('Città del Vaticano', 'CV', 'vaticano')
  end
end
