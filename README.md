# SVG Maps Italy
[![Ruby: 2.7](https://img.shields.io/badge/Ruby-2.7-orange)](https://www.ruby-lang.org/)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
![GitHub top language](https://img.shields.io/github/languages/top/Vonvikken/svg-maps)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Vonvikken/svg-maps)
![GitHub](https://img.shields.io/github/license/Vonvikken/svg-maps)

Ruby scripts used to create SVG maps of Italian _comuni_ and provinces from OSM data.

## Installation

To manually build the gem, run the following script:

    $ ./build_gem.sh

To install it in your system, execute:

    $ gem install svg_maps_italy-<version>.gem

## Description
I made these scripts to create SVG maps of Italian administrative subdivisions (namely regions, provinces and _comuni_),
intending to publish them on Wikipedia, like I did
[several years ago](https://commons.wikimedia.org/wiki/File:Map_of_comune_of_Rimini_(province_of_Rimini,_region_Emilia-Romagna,_Italy).svg).

This time I chose a more visually pleasant appearance, with the option to furtherly customize them via CSS stylesheet,
showing the neighboring provinces, regions and even the nearby nations. Moreover, when hovering above a feature on the
map, its name will be shown in a tooltip and its boundaries will be highlighted (though this feature can be turned off
via CSS).

This is how a map of a _comune_ will look like with the default style:

<img src="img/Rimini.svg" width="800" alt="Comune of Rimini, province of Rimini, Emilia-Romagna, Italy"/>

## Usage
_TO DO_

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vonvikken/svg-maps. This project is
intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the
[code of conduct](https://github.com/vonvikken/svg-maps/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the SvgMapsItaly project's codebases, issue trackers, chat rooms and mailing lists is expected
to follow the [code of conduct](https://github.com/vonvikken/svg-maps/blob/master/CODE_OF_CONDUCT.md).
