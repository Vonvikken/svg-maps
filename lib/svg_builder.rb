# Class:     /home/vonvikken/svg-maps/lib/svg_builder.rb
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

require_relative 'metadata_reader'

# Class used to generate an SVG map from a GeoJSON dataset
class SVGBuilder
  def initialize(data_dir, tmp_dir_name, dataset_filename, options)
    @data_dir = data_dir
    @tmp_dir_name = tmp_dir_name
    @dataset_filename = dataset_filename
    @options = options
    @metadata = nil
  end

  def build_svg
    extract_metadata
    convert_to_svg @options[:svg_width]
  end

  private

  def extract_metadata
    @metadata = MetadataReader.new("#{@data_dir}/#{@tmp_dir_name}/#{@dataset_filename}").metadata
  end

  def convert_to_svg(width)
    puts 'Converting GeoJSON to SVG...'
    cmd = "mapshaper -i #{@data_dir}/#{@tmp_dir_name}/#{@dataset_filename} "\
          "-o format=svg id-field=@id width=#{width} #{@data_dir}/#{@tmp_dir_name}/#{base_svg_filename}"
    `#{cmd}`
  end

  # Filename methods

  # Temporary directory path
  def tmp_dir
    "#{@data_dir}/#{@tmp_dir_name}"
  end

  # Base SVG file name
  def base_svg_filename
    @dataset_filename.gsub(/(.+)\.geojson$/, '\1-plain.svg')
  end
end
