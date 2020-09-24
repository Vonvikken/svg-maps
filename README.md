# SVG Maps Italy
[![Ruby: 2.7](https://img.shields.io/badge/Ruby-2.7-orange)](https://www.ruby-lang.org/)
[![Ruby Style Guide](https://img.shields.io/badge/code_style-rubocop-brightgreen.svg)](https://github.com/rubocop-hq/rubocop)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
![GitHub top language](https://img.shields.io/github/languages/top/Vonvikken/svg-maps)
![GitHub code size in bytes](https://img.shields.io/github/languages/code-size/Vonvikken/svg-maps)
![GitHub](https://img.shields.io/github/license/Vonvikken/svg-maps)

Ruby script used to create SVG maps of Italian _comuni_ and provinces from OSM data.

## Description
I made this script to create SVG maps of Italian administrative subdivisions (namely regions, provinces and _comuni_),
intending to publish them on Wikipedia, like I did
[several years ago](https://commons.wikimedia.org/wiki/File:Map_of_comune_of_Rimini_(province_of_Rimini,_region_Emilia-Romagna,_Italy).svg).

This time I chose a more complete and visually pleasant appearance (with the option to further customize them via CSS
stylesheet), showing the nearby provinces, regions and nations. Moreover, when hovering above a subdivision on the map,
its name will be shown in a tooltip and its boundaries will be highlighted (though this feature can be turned off
modifying the CSS).

This is how a map of a _comune_ will look like with the default style (in this case Rimini, province of Rimini, region
Emilia-Romagna):

<img src="img/Rimini.svg" width="800" alt="Comune of Rimini, province of Rimini, Emilia-Romagna, Italy"/>

The _comune_ of interest is shown in red, whereas the other _comuni_ of the province are in yellow. A lighter shade of
yellow is for the other provinces of the same region, whereas the neighboring regions are in orange. Finally, the 
independent nation of San Marino is colored in gray.

_Note_: if you don't see the tooltips and the highlighted boundaries, try to right click on the image and select _Show
image_.

All the map data are from OpenStreetMaps ([copyright notice](https://www.openstreetmap.org/copyright)).

## Prerequisites
This script uses [Mapshaper](https://github.com/mbloch/mapshaper) to perform all the magics on the map data. If it isn't installed
nothing will work. And, of course, you need Ruby too! I used version 2.7, but it should work at least with 2.3.

Before the first use you need to download the source datasets. Please follow the instructions in the corresponding
[wiki page](https://github.com/Vonvikken/svg-maps/wiki/Source-datasets).

## Installation

To manually build the gem, run the following script:

    $ ./build_gem.sh

To install it in your system, execute:

    $ gem install svg_maps_italy-<version>.gem

## Usage
This script runs from command line, with the executable `create_maps`. The generated maps are put
in the subdirectory `out` of the data directory.

The simplest usage is the following, using the only mandatory option `-p`, followed by the province
code:
```bash
create_map -p PA
```
It creates a map of the given province (in this case Palermo) without highlighting any _comune_.

If the province shares borders with other states and/or Italian regions, add these with the options
`-r` and `-f`. For example, the province of Bolzano borders with the regions of Lombardia and
Veneto, plus with the countries of Austria and Switzerland, so the command will look like this:
```bash
create_map -p BZ -r LOM,VEN -f AT,CH
```
To show the list of the codes of provinces, regions and countries, use respectively the options
`-P`, `-R` or `-F`.

For specifying a _comune_ in particular, use the `-c` option, followed by the name of the _comune_
(in case of multi-language names, use the Italian one):
```bash
create_map -p CA -c "Quartu Sant'Elena"
```
This will create a map with the territory of the given _comune_ highlighted. Use the quotes around
the name only if it contains spaces or apostrophes.

Finally, the option `-C` will generate the map of each _comune_ of the province into a subdirectory
of the `out` directory.

_To do: other options._

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/vonvikken/svg-maps. This project is
intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the
[code of conduct](https://github.com/vonvikken/svg-maps/blob/master/CODE_OF_CONDUCT.md).


## Code of Conduct

Everyone interacting in the SvgMapsItaly project's codebases, issue trackers, chat rooms and mailing lists is expected
to follow the [code of conduct](https://github.com/vonvikken/svg-maps/blob/master/CODE_OF_CONDUCT.md).
