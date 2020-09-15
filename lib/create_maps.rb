# Class:     /home/vonvikken/svg-maps/lib/create_maps.rb
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
require 'English'
require_relative 'province'
require_relative 'region'
require_relative 'state'

# Command-line argument parser
class Parser
  attr_reader :options

  def initialize
    @options = {}
  end

  def parse(args)
    parser = OptionParser.new do |opts|
      opts.banner = "Usage: #{$PROGRAM_NAME} [options]"
      opts.separator ''
      opts.separator 'Options:'

      opts.on('-p', '--province PROV', 'Code of the province or metropolitan city to display') do |prov|
        @options[:province] = prov
      end

      opts.on('-r', '--regions REGIONS', Array, 'Codes of the neighboring regions (comma-separated list)') do |regs|
        @options[:regions] = regs
      end

      opts.on('-s', '--states STATES', Array, 'Codes of the neighboring states (comma-separated list)') do |states|
        @options[:states] = states
      end

      opts.on('-P', '--list-provinces', 'List province or metropolitan city codes and exit') do
        puts Province.instance
        exit 0
      end

      opts.on('-R', '--list-regions', 'List region codes and exit') do
        puts Region.instance
        exit 0
      end

      opts.on('-S', '--list-states', 'List neighboring state codes and exit') do
        puts State.instance
        exit 0
      end
    end

    parser.parse!(args)
  end

  def inspect
    @options.to_s
  end
end

# Class used for building the intermediate datasets of the maps
class DatasetBuilder
  def initialize(options, data_dir)
    @province = Province.instance.find(options[:province])

    reg = Region.instance
    @regions = []
    options[:regions]&.each { |r| @regions << reg.find(r) }

    st = State.instance
    @states = []
    options[:states]&.each { |s| @states << st.find(s) }

    @data_dir = data_dir
  end

  def build_dataset
    check_prerequisites
    create_datasets
  end

  private

  def check_prerequisites
    puts 'Checking if mapshaper is installed...'
    `mapshaper -v`
    abort 'mapshaper not installed!' unless $CHILD_STATUS.success?

    puts 'Checking data directory...'
    abort 'Directory "data" not found!' unless Dir.exist? @data_dir

    Dir.mkdir tmp_dir unless File.exist? tmp_dir

    puts 'Checking source datasets...'
    abort "File #{own_reg_filename} does not exist!" unless File.exist? own_reg_filename

    @regions.map { |r| reg_filename r }.each do |f|
      abort "File #{f} does not exits!" unless File.exist? f
    end

    @states.map { |s| state_filename s }.each do |f|
      abort "File #{f} does not exits!" unless File.exist? f
    end
  end

  def create_datasets
    # Extract other regions
    puts 'Generating intermediate datasets...'

    # Neighbouring regions
    @regions.each do |r|
      puts r.name
      cmd = "mapshaper -i #{reg_filename r} -target type=polygon -filter 'admin_level==4' " \
            "-o #{tmp_dir}/#{reg_dataset_filename r}"
      `#{cmd}`
    end

    # Provinces of own region
    cmd = "mapshaper -i #{own_reg_filename} -target type=polygon -filter 'admin_level==6' "\
          "-rename-fields ISO3166_2=ISO3166-2 -o #{tmp_dir}/#{reg_prov_dataset_filename}"
    `#{cmd}`

    # Communes of own region
    cmd = "mapshaper -i #{own_reg_filename} -target type=polygon -filter 'admin_level==8' "\
          "-o #{tmp_dir}/#{reg_com_dataset_filename}"
    `#{cmd}`

    Dir.chdir tmp_dir

    # Own province
    `mapshaper -i #{reg_prov_dataset_filename} -filter 'ISO3166_2=="#{@province.code}"' -o #{prov_dataset_filename}`

    # Other provinces of the region
    `mapshaper -i #{reg_prov_dataset_filename} -filter 'ISO3166_2!="#{@province.code}"' -o #{prov_no_dataset_filename}`

    # Communes of own province
    `mapshaper -i #{reg_com_dataset_filename} -clip #{prov_dataset_filename} -o #{com_dataset_filename}`
  end

  # Filename methods

  # Temporary directory path
  def tmp_dir
    "#{@data_dir}/tmp"
  end

  # Filename of the region the selected province belongs to
  def own_reg_filename
    "#{@data_dir}/regioni/#{@province.reg.filename}.geojson"
  end

  # Filename of the given region
  def reg_filename(region)
    "#{@data_dir}/regioni/#{region.filename}.geojson"
  end

  # Filename of the given state
  def state_filename(state)
    "#{@data_dir}/stati/#{state.filename}.geojson"
  end

  # Filename of the intermediate dataset with the boundaries of the given region
  def reg_dataset_filename(region)
    "#{region.filename}-4.geojson"
  end

  # Filename of the intermediate dataset with all the province boundaries in the region of the selected province
  def reg_prov_dataset_filename
    "#{@province.reg.filename}-6.geojson"
  end

  # Filename of the intermediate dataset with the commune boundaries in the region of the selected province
  def reg_com_dataset_filename
    "#{@province.reg.filename}-8.geojson"
  end

  # Filename of the intermediate dataset with the boundaries of the selected province
  def prov_dataset_filename
    "#{@province.code}-6.geojson"
  end

  # Filename of the intermediate dataset with the boundaries of the provinces within the region except the selected one
  def prov_no_dataset_filename
    "#{@province.code}-6_no.geojson"
  end

  # Filename of the intermediate dataset with the boundaries of the communes within the selected province
  def com_dataset_filename
    "#{@province.code}-8.geojson"
  end
end
