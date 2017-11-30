#!/usr/bin/perl
# ============================================================================
#
#         File:  random_theme.pl
#
#        Usage:  random_theme.pl
#
#  Description:  Create a random gnome terminal color scheme
#
#   Copyright (c) 2017 Steven Bakker <sb@monkey-mind.net>
#
#   This program is free software; you can redistribute it and/or modify
#   it under the same terms as Perl itself. See "perldoc perlartistic".
#
#   This software is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# ============================================================================

use v5.10;
use strict;
use warnings;

use FindBin;
use Time::Piece;

sub rnd_color {
    my $r = int(rand(0x10000));
    my $g = int(rand(0x10000));
    my $b = int(rand(0x10000));
    return sprintf("'#%04x%04x%04x'", $r, $g, $b);
}

my $date = localtime->strftime("%d-%b-%Y %T %z");
print <<EOF;
# Wacko theme
# Generated by $FindBin::Script, $date
---
EOF

for my $key (qw(bd fg bg)) {
    say "$key: ".rnd_color();
}
for my $cnum (0..7) {
    say "color$cnum: ["
        .join(", ", rnd_color(), rnd_color())
        ."]"
}
