#!/usr/bin/perl

use strict;
use YAML;
use Data::Dumper;
use Path::Tiny;

my $file = @ARGV ? shift @ARGV : '-';

my $in_file = path($file);
my $str = $in_file->slurp;

#my $str;
#{
    #local($/) = undef;
    #$str = <>;
#}

my $hashref = Load( $in_file->slurp );

path("bd_color")->spew($hashref->{bd}, "\n");
path("bg_color")->spew($hashref->{bg}, "\n");
path("fg_color")->spew($hashref->{fg}, "\n");

my @palette;

for my $i (0..7) {
    my $color = $hashref->{"color$i"} // '#808080';
    if (ref $color eq 'ARRAY') {
        $palette[$i]   = $color->[0];
        $palette[$i+8] = $color->[1];
    }
    else {
        $palette[$i] = $palette[$i+8] = $color;
    }
}

path("palette_dconf")->spew(
    join(", ", map { qq{'$_'} } @palette),
    "\n"
);

path("palette_gconf")->spew(
    join(":", @palette),
    "\n"
);
