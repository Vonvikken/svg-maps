# Class:     /home/vonvikken/svg-maps/lib/metadata_reader.rb
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

require 'json'

# Extract metadata from GeoJSON
class MetadataReader
  attr_reader :metadata

  def initialize(path)
    file_in = File.read path
    full_json = JSON.parse file_in

    feats = full_json['features']
    a_p = []
    feats.map { |feat| feat['properties'] }.each { |p| a_p << [p['@id'], p] }
    @metadata = a_p.to_h
  end
end
