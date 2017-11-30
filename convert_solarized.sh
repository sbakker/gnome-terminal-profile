#!/bin/bash -e
#
# Convert original solarized themes to YAML-based themes.
#
#   Usage:
#
#     convert_solarized.sh [colors-dir [dest-prefix]]
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

topdir=gnome-terminal-colors-solarized/colors
destprefix=solarized-

usage() {
cat <<EOF >&2

Usage: $0 [colors-dir [dest-prefix]]

default colors-dir is $topdir
default dest-prefix is \"$destprefix\"
YAML files are left in "color/\${destprefix}PROFILE/colors.yaml"

EOF
    exit 1
}

case $# in
    0) ;;
    1) topdir=$1
       ;;
    2) topdir=$1
       destprefix=$2
       ;;
    *) usage
       ;;
esac

currdir=$(pwd)

cd $topdir

for dir in *
do
    if [[ -d $dir && -f $dir/palette ]]; then
        dest=$currdir/colors/$destprefix$dir
        mkdir -p $dest
        echo "converting $topdir/$dir"
        $currdir/src/theme_to_yaml.pl $dir > $dest/colors.yaml
    fi
done
