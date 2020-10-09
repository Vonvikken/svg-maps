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
require_relative 'logger_utility'
require_relative 'province'
require_relative 'region'
require_relative 'state'
require_relative 'constants'

module SVGMapsItaly
  # Class used for building the intermediate datasets of the maps
  class DatasetBuilder
    include LoggerUtility
    include PathConstants

    def initialize(options, data_dir, tmp_dir)
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
      @tmp_dir = tmp_dir
      @lakes_full_path = ''
      @no_clean = options[:no_clean]
    end

    def build_dataset
      check_prerequisites
      initial_datasets
      intermediate_datasets
      bb_info = calc_coordinates
      combine_maps bb_info
      change_projection bb_info
      clean_tmp_dir unless @no_clean

      LOGGER.info "Wrote map file #{final_file_path}"
      final_file_path
    end

    private

    def check_prerequisites
      LOGGER.info 'Checking prerequisites...'
      LOGGER.debug 'Checking if mapshaper is installed...'
      `mapshaper -v`
      abort 'mapshaper not installed!' unless $CHILD_STATUS.success?

      LOGGER.debug 'Checking data directory...'
      abort 'Directory "data" not found!' unless Dir.exist? @data_dir

      LOGGER.debug 'Checking source datasets...'
      abort "File #{own_reg_file_path} does not exist!" unless File.exist? own_reg_file_path

      @regions.map { |r| reg_file_path r }.each do |f|
        abort "File #{f} does not exits!" unless File.exist? f
      end

      @states.map { |s| state_file_path s }.each do |f|
        abort "File #{f} does not exits!" unless File.exist? f
      end

      LOGGER.debug 'Checking if lakes dataset is present...'
      lp = "#{@data_dir}/#{PathConstants::LAKES_PATH}"
      return unless File.exist? lp

      @lakes_full_path = lp
      LOGGER.info 'Found lakes dataset, they will be added to your map if present.'
    end

    def initial_datasets
      LOGGER.info 'Extracting initial datasets...'

      # Neighbouring regions
      @regions.each do |r|
        LOGGER.debug "Region #{r.name}"
        cmd = "mapshaper -i '#{reg_file_path r}' -target type=polygon -filter 'admin_level==4' " \
              "-o '#{reg_dataset_file_path r}'"
        `#{cmd}`
      end

      # Provinces of own region
      cmd = if @province.level6
              "mapshaper -i '#{own_reg_file_path}' -target type=polygon -filter 'admin_level==6' "\
              "-rename-fields ISO3166_2=ISO3166-2 -o '#{reg_prov_dataset_file_path}'"
            else
              "mapshaper -i '#{own_reg_file_path}' -target type=polygon -filter 'admin_level==4' "\
              "-o '#{reg_dataset_file_path(@province.reg)}'"
            end
      `#{cmd}`

      # Communes of own region
      cmd = "mapshaper -i '#{own_reg_file_path}' -target type=polygon -filter 'admin_level==8' "\
            "-o '#{reg_com_dataset_file_path}'"
      `#{cmd}`
    end

    def intermediate_datasets
      LOGGER.info 'Generating intermediate datasets...'

      if @province.level6
        # Own province
        cmd = "mapshaper -i '#{reg_prov_dataset_file_path}' -filter 'ISO3166_2==\"#{@province.code}\"' "\
              "-o #{prov_dataset_file_path}"
        `#{cmd}`

        # Other provinces of the region
        cmd = "mapshaper -i '#{reg_prov_dataset_file_path}' -filter 'ISO3166_2!=\"#{@province.code}\"' "\
              "-o #{prov_no_dataset_file_path}"
        `#{cmd}`
      end

      # Communes of own province
      clip = @province.level6 ? prov_dataset_file_path : reg_dataset_file_path(@province.reg)
      `mapshaper -i '#{reg_com_dataset_file_path}' -clip '#{clip}' -o #{com_dataset_file_path}`
    end

    def calc_coordinates
      LOGGER.info 'Calculating coordinates...'

      # Mapshaper sends output to STDERR...
      _, info, = Open3.capture3("mapshaper -i #{com_dataset_file_path} -info")
      info_lines = info.split "\n"
      matches = info_lines.map { |l| l.match(/^Bounds:\s+(\d{1,3}.\d+),(\d{1,3}.\d+),(\d{1,3}.\d+),(\d{1,3}.\d+)/) }
      m = matches.reject(&:nil?).first

      nw_lon = m[1].to_f
      nw_lat = m[2].to_f
      se_lon = m[3].to_f
      se_lat = m[4].to_f
      LOGGER.debug "Bounding box: NW (#{nw_lat}, #{nw_lon}) SE (#{se_lat}, #{se_lon})"

      nw_lon -= @padding[:w]
      nw_lat -= @padding[:n]
      se_lon += @padding[:e]
      se_lat += @padding[:s]
      LOGGER.debug "Padded bounding box: NW (#{nw_lat}, #{nw_lon}) SE (#{se_lat}, #{se_lon})"

      center_lon = (nw_lon + se_lon) / 2
      center_lat = (nw_lat + se_lat) / 2

      LOGGER.debug "Center point coordinates are (#{center_lat}, #{center_lon})"

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
      regions_list = @regions.map { |r| reg_dataset_file_path r }.map { |n| "'#{n}'" }.join ' '
      states_list = @states.map { |s| state_file_path s }.map { |n| "'#{n}'" }.join ' '
      bbox_bounds = "#{bb_info[:nw_lon]},#{bb_info[:nw_lat]},#{bb_info[:se_lon]},#{bb_info[:se_lat]}"
      no_prov = @province.level6 ? prov_no_dataset_file_path : ''
      cmd = "mapshaper -i #{com_dataset_file_path} #{no_prov} #{regions_list} #{states_list} #{@lakes_full_path} "\
            "combine-files -merge-layers force -clip bbox=#{bbox_bounds} -o #{combined_file_path}"
      `#{cmd}`
    end

    def change_projection(bb_info)
      LOGGER.info 'Changing map projection...'
      cmd = "mapshaper -i #{combined_file_path} -proj +proj=eqc " \
            "+lon_0=#{bb_info[:center_lon]} +lat_ts=#{bb_info[:center_lat]} target=* -o '#{final_file_path}'"
      `#{cmd}`
    end

    def clean_tmp_dir
      LOGGER.info 'Cleaning temporary directory...'
      Dir.entries(@tmp_dir)
         .reject { |e| File.directory? e or final_map_name == e }
         .each { |f| File.delete "#{@tmp_dir}/#{f}" }
    end

    # Filename methods

    # File path of the region the selected province belongs to
    def own_reg_file_path
      "#{@data_dir}/#{PathConstants::REGIONS_DIR}/#{@province.reg.filename}.geojson"
    end

    # File path of the given region
    def reg_file_path(region)
      "#{@data_dir}/#{PathConstants::REGIONS_DIR}/#{region.filename}.geojson"
    end

    # File path of the given state
    def state_file_path(state)
      "#{@data_dir}/#{PathConstants::STATES_DIR}/#{state.filename}.geojson"
    end

    # File path of the intermediate dataset with the boundaries of the given region
    def reg_dataset_file_path(region)
      "#{@tmp_dir}/#{region.filename}-4.geojson"
    end

    # File path of the intermediate dataset with all the province boundaries in the region of the selected province
    def reg_prov_dataset_file_path
      "#{@tmp_dir}/#{@province.reg.filename}-6.geojson"
    end

    # File path of the intermediate dataset with the commune boundaries in the region of the selected province
    def reg_com_dataset_file_path
      "#{@tmp_dir}/#{@province.reg.filename}-8.geojson"
    end

    # File path of the intermediate dataset with the boundaries of the selected province
    def prov_dataset_file_path
      "#{@tmp_dir}/#{@province.code}-6.geojson"
    end

    # File path of the intermediate dataset with the boundaries of the provinces within the region except the selected
    def prov_no_dataset_file_path
      "#{@tmp_dir}/#{@province.code}-6_no.geojson"
    end

    # File path of the intermediate dataset with the boundaries of the communes within the selected province
    def com_dataset_file_path
      "#{@tmp_dir}/#{@province.code}-8.geojson"
    end

    # File path of the combined map
    def combined_file_path
      "#{@tmp_dir}/#{@province.code}-combined.geojson"
    end

    # Filename of the final map
    def final_map_name
      "#{@province.name}.geojson"
    end

    # File path of the final map
    def final_file_path
      "#{@tmp_dir}/#{final_map_name}"
    end
  end
end
