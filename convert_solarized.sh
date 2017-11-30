#!/bin/bash -e
#
# Convert original solarized themes to YAML-based themes.
#
#   Usage:
#
#     convert_solarized.sh [colors-dir]
#
#   Default "colors-dir" is "gnome-terminal-colors-solarized/colors"
#
#   Copyright (c) 2014-2017 Steven Bakker; All rights reserved.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the same terms as Perl itself. See "perldoc perlartistic".
#
#   This software is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

case $# in
    0) topdir=gnome-terminal-colors-solarized/colors ;;
    1) topdir=$1 ;;
    *) echo "usage: $0 [colors-dir]" >&2; exit 1 ;;
esac

currdir=$(pwd)

cd $topdir

for dir in *
do
    if [[ -d $dir && -f $dir/palette ]]; then
        dest=$currdir/colors/solarized-$base
        mkdir -p $dest
        echo "converting $topdir/$dir"
        $currdir/src/theme_to_yaml.pl $dir > $dest/colors.yaml
    fi
done
