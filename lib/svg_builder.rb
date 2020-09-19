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

require 'nokogiri'
require_relative 'metadata_reader'

# Class used to generate an SVG map from a GeoJSON dataset
class SVGBuilder
  def initialize(data_dir, tmp_dir_name, dataset_filename, options)
    @data_dir = data_dir
    @tmp_dir_name = tmp_dir_name
    @dataset_filename = dataset_filename
    @options = options
  end

  def build_svg
    metadata = extract_metadata
    svg_doc = convert_to_svg @options[:svg_width]
    clean_svg svg_doc
    add_info_to_svg svg_doc, metadata
    write_svg svg_doc
  end

  private

  def extract_metadata
    MetadataReader.new(dataset_path).metadata
  end

  def convert_to_svg(width)
    puts 'Converting GeoJSON to SVG...'
    `mapshaper -i #{dataset_path} -o format=svg id-field=@id width=#{width} #{svg_path}`
    File.open(svg_path) { |f| Nokogiri::XML(f) }
  end

  def clean_svg(doc)
    puts 'Cleaning SVG...'
    grp = doc.css 'g'
    grp_kids = grp.children
    grp.remove
    doc.root.add_child grp_kids
  end

  def add_info_to_svg(doc, metadata)
    paths = doc.css 'path'
    paths.each do |path|
      id = path['id']
      md = metadata[id]
      path['name'] = md['name']
      path.add_child("<metadata>#{doc.create_cdata(metadata)}</metadata>") if @options[:add_metadata]
    end
  end

  def write_svg(doc)
    File.write svg_path, doc.to_xml
  end

  # Filename methods

  # Temporary directory path
  def tmp_dir
    "#{@data_dir}/#{@tmp_dir_name}"
  end

  # Full GeoJSON dataset path
  def dataset_path
    "#{tmp_dir}/#{@dataset_filename}"
  end

  # SVG file name
  def svg_path
    filename = @dataset_filename.gsub(/(.+)\.geojson$/, '\1.svg')
    "#{tmp_dir}/#{filename}"
  end
end
