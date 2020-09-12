# Class:     /home/vonvikken/svg-maps/lib/admin_subdivision.rb
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

# Generic administrative subdivision
class AdminSubdivision
  attr_reader :abbr, :name

  def initialize(name, abbr, filename = nil)
    @name = name
    @abbr = abbr
    @filename = filename
  end

  def filename
    @filename ||= @name.downcase
  end
end

# Set of administrative subdivisions
class AdminSubdivisionSet
  def initialize
    @set = {}
  end

  def <<(admin_subdivision)
    @set[admin_subdivision[:abbr]] = admin_subdivision
  end

  def find(abbreviation)
    @set.select { |abbr, _| abbr == abbreviation }.first
  end
end
