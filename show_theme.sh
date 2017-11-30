#!/bin/bash -e
#
# Show theme.
#
#   Copyright (c) 2014-2017 Steven Bakker; All rights reserved.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the same terms as Perl itself. See "perldoc perlartistic".
#
#   This software is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

dir=${0%/*}
prog=${0##*/}

die() {
    echo "$@" >&2
    exit 1
}

case $# in
    1) theme=$1 ;;
    *) die "usage: $prog theme" ;;
esac

is_yaml=false
theme_arg=''

if [[ $theme =~ \.y[a]?ml$ && -f $theme ]]; then
    is_yaml=true
    theme_arg=$theme
else
    if [[ -d $theme ]]; then
        if [[ -f $theme/colors.yaml ]]; then
            is_yaml=true
            theme_arg="$theme/colors.yaml"
        elif [[ -f $theme/palette ]]; then
            is_yaml=false
            theme_arg="$theme"
        fi
    elif [[ -f colors/$theme/colors.yaml ]]; then
        is_yaml=true
        theme_arg="colors/$theme/colors.yaml"
    elif [[ -f colors/$theme/palette ]]; then
        is_yaml=false
        theme_arg="colors/$theme"
    fi
fi

[[ -n $theme_arg ]] || die "$prog: $theme is not a valid theme file/directory"

if $is_yaml; then
    $dir/src/parse_yaml_theme.pl "$theme_arg" show
else
    $dir/src/theme_to_yaml.pl --show "$theme_arg"
fi
