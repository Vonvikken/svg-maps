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
