# YAML Color schemes for Gnome Terminal

Script(s) for defining Gnome Terminal themes with a YAML file.

Builds on the [Anthony repo] for solarized Gnome Terminal colors (the
repository is added as a submodule of this repository).

## Copyright & License

Copyright (C) 2017  Steven Bakker

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the [GNU General Public License](LICENSE)
along with this program.  If not, see [<http://www.gnu.org/licenses/>](http://www.gnu.org/licenses/).

## Requirements

### Perl

The following modules should be part of the default Perl installation:

    * File::Basename
    * FindBin
    * Getopt::Long

The following modules will probably need to be installed separately:

    * Modern::Perl (>= 1.20170117)
    * Pod::Usage (1.69)
    * YAML (>= 1.23)

## Initialisation

```
git clone git@github.com:sbakker/gnome-terminal-profile.git
git submodule init
```

## Usage

See the POD documentation of `parse_yaml_theme.pl`

```
perldoc src/parse_yaml_theme.pl

src/parse_yaml_theme.pl --manual
```

### Using with gnome-terminal-colors-solarized

To use with the [Anthony repo]:

Copy your YAML file to a new directory in the `colors` directory:

```
mkdir /path/to/gnome-terminal-colors-solarized/my-theme
cp my-theme.yaml /path/to/gnome-terminal-colors-solarized/my-theme/colors.yaml
```

Then, "compile" it to create the appropriate files:

```
src/parse_yaml_theme.pl /path/to/gnome-terminal-colors-solarized/my-theme/colors.yaml compile
```

Finally, use the `install.sh` script to install the color theme.

```
cd /path/to/gnome-terminal-colors-solarized
./install.sh
```

### Standalone usage

The `install.sh` script was copied from [Anthony repo] and modified to include
the use of the YAML parser.

```
mkdir -p ./colors/my-color
cp my-color.yaml ./colors/my-color/colors.yaml
./install.sh
```

**NOTE: At this moment this will fail due to missing support scripts.**

## Scripts

### parse_yaml_theme.pl

### color_matrix

### tools.sh 

(copied from [Anthony repo])

---

[Anthony repo]: https://github.com/Anthony25/gnome-terminal-colors-solarized
[Solarized homepage]:   http://ethanschoonover.com/solarized
[Solarized repository]: https://github.com/altercation/solarized
[Gnome Terminal Colors Solarized repository]: https://github.com/sigurdga/gnome-terminal-colors-solarized
[dircolors solarised color theme]: https://github.com/seebi/dircolors-solarized
