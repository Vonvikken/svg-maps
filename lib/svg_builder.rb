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
require_relative 'logger_utility'
require_relative 'metadata_reader'
require_relative 'css_constants'

# Class used to generate an SVG map from a GeoJSON dataset
class SVGBuilder
  include CSSConstants
  include LoggerUtility

  def initialize(data_dir, tmp_dir_name, dataset_file_path, css_path, options)
    @data_dir = data_dir
    @tmp_dir_name = tmp_dir_name
    @dataset_file_path = dataset_file_path
    @css_path = css_path
    @options = options
  end

  def build_svg
    metadata = extract_metadata
    svg_doc = convert_to_svg @options[:svg_width]
    clean_svg svg_doc
    add_info_to_svg svg_doc, metadata
    write_svg svg_doc
    File.delete @dataset_file_path
    svg_path
  end

  private

  def extract_metadata
    MetadataReader.new(@dataset_file_path).metadata
  end

  def convert_to_svg(width)
    LOGGER.info 'Converting GeoJSON to SVG...'
    `mapshaper -i "#{@dataset_file_path}" -o format=svg id-field=@id width=#{width} "#{svg_path}"`
    File.open(svg_path) { |f| Nokogiri::XML(f) }
  end

  def clean_svg(doc)
    LOGGER.info 'Cleaning SVG...'
    grp = doc.css 'g'
    grp_kids = grp.children
    grp.remove
    doc.root.add_child grp_kids
  end

  def add_info_to_svg(doc, metadata)
    LOGGER.info 'Adding info and style to SVG...'

    insert_css doc

    paths = doc.css 'path'
    paths.each do |path|
      id = path['id']
      md = metadata[id]
      path.add_child "<title>#{md['name']}</title>"
      path.add_child "<metadata>#{doc.create_cdata metadata}</metadata>" if @options[:add_metadata]

      path['class'] = case md['admin_level'].to_i
                      when 2..3
                        CSSConstants::CLASS_FOREIGN
                      when 4
                        CSSConstants::CLASS_REGION
                      when 6
                        CSSConstants::CLASS_PROVINCE
                      when 8
                        CSSConstants::CLASS_COMUNE
                      else
                        ''
                      end
    end
  end

  def insert_css(doc)
    css_content = File.read @css_path

    css_block = <<~CSS
      <style type="text/css">
      #{doc.create_cdata css_content}
      </style>
    CSS

    doc.root.first_element_child.add_previous_sibling css_block
  end

  def write_svg(doc)
    LOGGER.info 'Writing final SVG...'
    File.write svg_path, doc.to_xml
  end

  # Filename methods

  # Temporary directory path
  def tmp_dir
    "#{@data_dir}/#{@tmp_dir_name}"
  end

  # SVG file path
  def svg_path
    @dataset_file_path.gsub(/(.+)\.geojson$/, '\1.svg')
  end
end
