# Class:     /home/vonvikken/svg-maps/lib/dataset_builder.rb
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

require 'English'
require 'open3'
require_relative 'province'
require_relative 'region'
require_relative 'state'

# Class used for building the intermediate datasets of the maps
class DatasetBuilder
  def initialize(options, data_dir, tmp_dir_name)
    @province = Province.instance.find(options[:province])

    reg = Region.instance
    @regions = []
    options[:regions]&.each { |r| @regions << reg.find(r) }

    st = State.instance
    @states = []
    options[:states]&.each { |s| @states << st.find(s) }

    @padding = {
      n: options[:n_padding],
      s: options[:s_padding],
      w: options[:w_padding],
      e: options[:e_padding]
    }

    @data_dir = data_dir
    @tmp_dir_name = tmp_dir_name
  end

  def build_dataset
    check_prerequisites
    initial_datasets
    intermediate_datasets
    bb_info = calc_coordinates
    combine_maps bb_info
    change_projection bb_info
    clean_tmp_dir

    puts "Wrote map file #{final_filename}"
    final_filename
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

  def initial_datasets
    puts 'Extracting initial datasets...'

    # Neighbouring regions
    @regions.each do |r|
      cmd = "mapshaper -i '#{reg_filename r}' -target type=polygon -filter 'admin_level==4' " \
            "-o '#{tmp_dir}/#{reg_dataset_filename r}'"
      `#{cmd}`
    end

    # Provinces of own region
    cmd = if @province.level6
            "mapshaper -i '#{own_reg_filename}' -target type=polygon -filter 'admin_level==6' "\
            "-rename-fields ISO3166_2=ISO3166-2 -o '#{tmp_dir}/#{reg_prov_dataset_filename}'"
          else
            "mapshaper -i '#{own_reg_filename}' -target type=polygon -filter 'admin_level==4' "\
            "-o '#{tmp_dir}/#{reg_dataset_filename(@province.reg)}'"
          end
    `#{cmd}`

    # Communes of own region
    cmd = "mapshaper -i '#{own_reg_filename}' -target type=polygon -filter 'admin_level==8' "\
          "-o '#{tmp_dir}/#{reg_com_dataset_filename}'"
    `#{cmd}`
  end

  def intermediate_datasets
    Dir.chdir tmp_dir

    puts 'Generating intermediate datasets...'

    if @province.level6
      # Own province
      `mapshaper -i '#{reg_prov_dataset_filename}' -filter 'ISO3166_2=="#{@province.code}"' -o #{prov_dataset_filename}`

      # Other provinces of the region
      cmd = "mapshaper -i '#{reg_prov_dataset_filename}' -filter 'ISO3166_2!=\"#{@province.code}\"' "\
            "-o #{prov_no_dataset_filename}"
      `#{cmd}`
    end

    # Communes of own province
    clip = @province.level6 ? prov_dataset_filename : reg_dataset_filename(@province.reg)
    `mapshaper -i '#{reg_com_dataset_filename}' -clip '#{clip}' -o #{com_dataset_filename}`

    Dir.chdir @data_dir
  end

  def calc_coordinates
    puts 'Calculating coordinates...'

    # Mapshaper sends output to STDERR...
    _, info, = Open3.capture3("mapshaper -i #{tmp_dir}/#{com_dataset_filename} -info")
    info_lines = info.split "\n"
    matches = info_lines.map { |l| l.match(/^Bounds:\s+(\d{1,3}.\d+),(\d{1,3}.\d+),(\d{1,3}.\d+),(\d{1,3}.\d+)/) }
    m = matches.reject(&:nil?).first

    nw_lon = m[1].to_f
    nw_lat = m[2].to_f
    se_lon = m[3].to_f
    se_lat = m[4].to_f
    puts "Bounding box: NW (#{nw_lat}, #{nw_lon}) SE (#{se_lat}, #{se_lon})"

    nw_lon -= @padding[:w]
    nw_lat -= @padding[:n]
    se_lon += @padding[:e]
    se_lat += @padding[:s]
    puts "Padded bounding box: NW (#{nw_lat}, #{nw_lon}) SE (#{se_lat}, #{se_lon})"

    center_lon = (nw_lon + se_lon) / 2
    center_lat = (nw_lat + se_lat) / 2

    puts "Center point coordinates are (#{center_lat}, #{center_lon})"

    {
      nw_lon: nw_lon,
      nw_lat: nw_lat,
      se_lon: se_lon,
      se_lat: se_lat,
      center_lon: center_lon,
      center_lat: center_lat
    }
  end

  def combine_maps(bb_info)
    Dir.chdir tmp_dir
    regions_list = @regions.map { |r| reg_dataset_filename r }.map { |n| "'#{n}'" }.join ' '
    states_list = @states.map { |s| state_filename s }.map { |n| "'#{n}'" }.join ' '
    bbox_bounds = "#{bb_info[:nw_lon]},#{bb_info[:nw_lat]},#{bb_info[:se_lon]},#{bb_info[:se_lat]}"
    no_prov = @province.level6 ? prov_no_dataset_filename : ''
    cmd = "mapshaper -i #{com_dataset_filename} #{no_prov} #{regions_list} #{states_list} "\
          "combine-files -merge-layers force -clip bbox=#{bbox_bounds} -o #{combined_filename}"
    `#{cmd}`
    Dir.chdir @data_dir
  end

  def change_projection(bb_info)
    puts 'Changing map projection...'
    cmd = "mapshaper -i #{tmp_dir}/#{combined_filename} -proj +proj=tmerc +k_0=0.9996 " \
          "+lon_0=#{bb_info[:center_lon]} +lat_0=#{bb_info[:center_lat]} target=* -o '#{tmp_dir}/#{final_filename}'"
    `#{cmd}`
  end

  def clean_tmp_dir
    puts 'Cleaning temporary directory...'
    Dir.entries(tmp_dir)
       .reject { |e| File.directory? e or final_filename == e }
       .each { |f| File.delete "#{tmp_dir}/#{f}" }
  end

  # Filename methods

  # Temporary directory path
  def tmp_dir
    "#{@data_dir}/#{@tmp_dir_name}"
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

  # Filename of the combined map
  def combined_filename
    "#{@province.code}-combined.geojson"
  end

  # Final name of the map
  def final_filename
    "#{@province.name}.geojson"
  end
end
