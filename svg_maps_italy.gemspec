# Class:     /home/vonvikken/svg-maps/svg_maps_italy.gemspec
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

# coding: utf-8

# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'svg_maps_italy/version'

Gem::Specification.new do |spec|
  spec.name          = 'svg_maps_italy'
  spec.version       = SVGMapsItaly::VERSION
  spec.authors       = ['Vincenzo Stornanti']
  spec.email         = ['von.vikken@gmail.com']
  spec.license       = 'Apache-2.0'

  spec.summary       = 'Ruby scripts used to create SVG maps of Italian comuni and provinces from OSM data.'
  spec.homepage      = 'https://github.com/Vonvikken/svg-maps'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.3.0')

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'https://github.com/Vonvikken/svg-maps'
  spec.metadata['changelog_uri'] = "https://github.com/Vonvikken/svg-maps/blob/master/CHANGELOG.md"

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'bin'
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.add_dependency 'nokogiri', '~> 1.16.3'
  spec.add_dependency 'rake', '~> 12.0'
end
