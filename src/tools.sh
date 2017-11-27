#!/usr/bin/env bash

declare -a gnomeVersion

gnomeVersion=($(
    gnome-terminal --version | \
        perl -p -E 'say "$1 $2 $3" if /^.*?(\d+)\.(\d+)(?:\.(\d+))/'
))

# newGnome=1 if the gnome-terminal version >= 3.8
if [[ 
    ( ${gnomeVersion[0]} -eq 3 && ${gnomeVersion[1]} -ge 8 )
    || ${gnomeVersion[0]} -ge 4
]]; then
  newGnome="1"
  dconfdir=/org/gnome/terminal/legacy/profiles:
else
  newGnome=0
  gconfdir=/apps/gnome-terminal/profiles
fi

die() {
  echo $1
  exit ${2:-1}
}

in_array() {
  local e
  for e in "${@:2}"; do [[ $e == $1 ]] && return 0; done
  return 1
}

