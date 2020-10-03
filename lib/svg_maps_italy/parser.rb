# Class:     /home/vonvikken/svg-maps/lib/parser.rb
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

require 'optparse'
require_relative 'province'
require_relative 'region'
require_relative 'state'

module SVGMapsItaly
  # Command-line argument parser
  class Parser
    attr_reader :options

    DEF_DATA_DIR = 'data'
    DEF_SIMPLIFY = 1.0
    DEF_PADDING = 0.05
    DEF_SVG_WIDTH = 1600
    DEF_ADD_METADATA = false
    DEF_NO_CLEAN = false

    def initialize
      @options = {
        data_dir: DEF_DATA_DIR,
        extract_comuni: false,
        simplify: DEF_SIMPLIFY,
        n_padding: DEF_PADDING,
        s_padding: DEF_PADDING,
        w_padding: DEF_PADDING,
        e_padding: DEF_PADDING,
        svg_width: DEF_SVG_WIDTH,
        add_metadata: DEF_ADD_METADATA,
        no_clean: DEF_NO_CLEAN
      }
    end

    def parse(args)
      parser = OptionParser.new do |opts|
        opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
        opts.separator ''
        opts.separator 'Options:'

        opts.on('-d', '--data-dir DATA_DIR', %(Path of the data directory (default: "#{DEF_DATA_DIR}"))) do |data_dir|
          @options[:data_dir] = data_dir
        end

        opts.on('-p', '--province PROV', 'Code of the province or metropolitan city to display (required)') do |prov|
          @options[:province] = prov
        end

        opts.on('-r', '--regions REGIONS', Array, 'Codes of the neighboring regions (comma-separated list)') do |regs|
          @options[:regions] = regs
        end

        opts.on('-f', '--foreign STATES', Array,
                'Codes of the neighboring foreign states (comma-separated list)') do |states|
          @options[:states] = states
        end

        opts.on('-c', '--comune COMUNE',
                'Highlight the territory of a comune given its name (in Italian). Ignored if -C option is used.') do |c|
          @options[:comune] = c
        end

        opts.on('-C', '--extract-comuni', 'Extract the maps of the comuni in the province to a separate directory.') do
          @options[:extract_comuni] = true
        end

        opts.on('-S', '--simplify RATIO', Float,
                'Simplify the map polygons to reduce the final file size. Parameter RATIO is a number ranging from '\
                "1.0 (no simplification) to 0.0 (max simplification). Default: #{DEF_SIMPLIFY}.") do |simpl|
          @options[:simplify] = simpl
        end

        opts.on('-b', '--bb-padding PADDING', Float,
                "Padding of the map bounding box in degrees (default: #{DEF_PADDING}). " \
                'Use this to set the padding for all directions.') do |bb_pad|
          @options[:n_padding] = bb_pad
          @options[:s_padding] = bb_pad
          @options[:w_padding] = bb_pad
          @options[:e_padding] = bb_pad
        end

        opts.on('-n', '--north-padding PADDING', Float,
                "North padding of the map bounding box in degrees (default: #{DEF_PADDING})") do |n_pad|
          @options[:n_padding] = n_pad
        end

        opts.on('-s', '--south-padding PADDING', Float,
                "South padding of the map bounding box in degrees (default: #{DEF_PADDING})") do |s_pad|
          @options[:s_padding] = s_pad
        end

        opts.on('-w', '--west-padding PADDING', Float,
                "West padding of the map bounding box in degrees (default: #{DEF_PADDING})") do |w_pad|
          @options[:w_padding] = w_pad
        end

        opts.on('-e', '--east-padding PADDING', Float,
                "East padding of the map bounding box in degrees (default: #{DEF_PADDING})") do |e_pad|
          @options[:e_padding] = e_pad
        end

        opts.on('-P', '--list-provinces', 'List province or metropolitan city codes and exit') do
          puts Province.instance
          exit 0
        end

        opts.on('-R', '--list-regions', 'List region codes and exit') do
          puts Region.instance
          exit 0
        end

        opts.on('-F', '--list-foreign', 'List neighboring foreign state codes and exit') do
          puts State.instance
          exit 0
        end

        opts.on('--svg-width WIDTH', Integer, "Width of the SVG map in pixels (default: #{DEF_SVG_WIDTH})") do |width|
          @options[:svg_width] = width
        end

        opts.on('--add-osm-metadata', "Add OSM metadata to SVG elements (default: #{DEF_ADD_METADATA})") do
          @options[:add_metadata] = true
        end

        opts.on('--css-path PATH', 'Path of the CSS stylesheet (default: "style/style.css")') do |path|
          @options[:css_path] = path
        end

        opts.on('--no-clean-tmp', "Don't clean temporary directory after completion (default: #{DEF_NO_CLEAN})") do
          @options[:no_clean] = true
        end

        opts.on_tail('-h', '--help', 'Show this message') do
          puts opts
          exit 0
        end
      end

      begin
        raise OptionParser::MissingArgument if args.length.zero?

        parser.parse!(args)
        @options[:comune] = nil if @options[:extract_comuni]
      rescue OptionParser::MissingArgument
        abort parser.help
      end
    end

    def inspect
      @options.to_s
    end
  end
end
