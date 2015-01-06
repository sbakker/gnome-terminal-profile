#!/usr/bin/perl
# ============================================================================
#
#         File:  parse_yaml_theme.pl
#
#        Usage:  See POD at end.
#
#  Description:  Create gnome-terminal theme from YAML file.
#
#        Notes:  ---
#       Author:  Steven Bakker (SB), <Steven.Bakker@ams-ix.net>
#      Created:  17/12/14
#
#   Copyright (c) 2014 Steven Bakker; All rights reserved.
#
#   This program is free software; you can redistribute it and/or modify
#   it under the same terms as Perl itself. See "perldoc perlartistic".
#
#   This software is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# ============================================================================

use Modern::Perl;
use FindBin;
use Getopt::Long;
use Pod::Usage;
use YAML;
use Getopt::Long;

$::VERSION = '1.00';
my $app_header = "\nThis is $FindBin::Script, v$::VERSION\n\n"
			   . "See \"perldoc $FindBin::Script\" for more information.\n"
               ;

# Default "Tango" Scheme.
my @dfl_palette = (
    [ 'rgb(0,0,0)',       'rgb(85,87,83)'    ],
    [ 'rgb(204,0,0)',     'rgb(239,41,41)'   ],
    [ 'rgb(78,154,6)',    'rgb(138,226,52)'  ],
    [ 'rgb(196,160,0)',   'rgb(252,233,79)'  ],
    [ 'rgb(52,101,164)',  'rgb(114,159,207)' ],
    [ 'rgb(117,80,123)',  'rgb(173,127,168)' ],
    [ 'rgb(6,152,154)',   'rgb(52,226,226)'  ],
    [ 'rgb(211,215,207)', 'rgb(238,238,236)' ],
);

Getopt::Long::Configure("bundling");

GetOptions(
	'help|?'     => sub {
        pod2usage(-msg => $app_header, -exitval=>0, -verbose=>0)
    },
	'manual'     => sub { pod2usage(-exitval=>0, -verbose=>2) },
	'version|V'  => sub { print $app_header; exit(0) },
    # Custom options.
) or pod2usage(-exitval=>2);

pod2usage(-message => "\nNeed at least one argument\n", -exitval => 2)
	unless @ARGV >= 1;

my $file = shift @ARGV;

my $str = do {
  open my $fh, "<", $file or die "$FindBin::Script: cannot read $file: $!\n";
  local($/) = undef;
  <$fh>;
};

my $hashref = Load( $str );
my @palette;
for my $i (0..7) {
    my $color = ($hashref->{"color$i"} //= $dfl_palette[$i]);
    if (ref $color eq 'ARRAY') {
        @$color = rgb2hex(@$color);
        $palette[$i]   = $color->[0];
        $palette[$i+8] = $color->[1];
    }
    else {
        $color = rgb2hex($color);
        $palette[$i] = $palette[$i+8] = $color;
    }
    $hashref->{"color$i"} = $color;
}

sub rgb2hex {
    my @result;
    for my $rgb (@_) {
        $rgb =~ s/\s//g;
        if ($rgb =~ /^rgb\((\d+),(\d+),(\d+)\)$/i) {
            push @result, sprintf("#%02X%02X%02X", $1, $2, $3);
        }
        else {
            push @result, $rgb;
        }
    }
    return @result == 1 ? $result[0] : @result;
}

$hashref->{bg} //= $palette[0];
$hashref->{fg} //= $palette[1];
$hashref->{bd} //= $hashref->{fg};

my %scheme = (
    'bg' => $hashref->{bg},
    'fg' => $hashref->{fg},
    'bd' => $hashref->{bd},
    'palette_dconf' => join(', ', map { qq{'$_'} } @palette),
    'palette_gconf' => join(":", @palette),
);

if (@ARGV) {
    for my $key (@ARGV) {
        if (exists($scheme{$key})) {
            say $scheme{$key};
        }
        elsif ($key eq 'show') {
            show_palette(\%scheme, \@palette);
        }
        elsif ($key eq 'yaml') {
            print Dump($hashref);
        }
        elsif ($key eq 'shell') {
            say "bd_color='$scheme{bd}'";
            say "bg_color='$scheme{bg}'";
            say "fg_color='$scheme{fg}'";
            say q{palette_dconf="},
                $scheme{'palette_dconf'}, q{"};
            say q{palette_gconf='},
                $scheme{'palette_gconf'}, q{'};
        }
        else {
            die "$FindBin::Script: bad key \"$key\"\n";
        }
    }
}
else {
    say "bd_color='$scheme{bd}'";
    say "bg_color='$scheme{bg}'";
    say "fg_color='$scheme{fg}'";
    say "palette=( ", join(" ", map { "'$_'" } @palette), " )";
}

sub parse_rgb {
    my $rgb = shift;
    if ($rgb =~ /^\#(..)(..)(..)$/) {
        return (hex($1), hex($2), hex($3));
    }
    elsif ($rgb =~ /^\#(..)..(..)..(..)..$/) {
        return (hex($1), hex($2), hex($3));
    }
    else {
        return (127, 127, 127);
    }
}

sub rgb_str {
    my ($str, $bg, $fg) = @_;

    my @bg = parse_rgb($bg // '#101010');
    my @fg = parse_rgb($fg // '#808080');

    return "\x1b[38;2;$fg[0];$fg[1];$fg[2]m"
         . "\x1b[48;2;$bg[0];$bg[1];$bg[2]m"
         . "$str\x1b[0m";
}

sub show_palette {
    my ($scheme, $palette) = @_;

    print "bd_color: |", rgb_str("  ", $scheme->{bd}), "|\n";
    print "fg_color: |", rgb_str("  ", $scheme->{fg}), "|\n";
    print "bg_color: |", rgb_str("  ", $scheme->{bg}), "|\n";
    print "palette:\n";

    #print "@palette\n";
    print   "        ",
            " Black ", " ",
            "  Red  ", " ",
            " Green ", " ",
            "Yellow ", " ",
            " Blue  ", " ",
            "Magenta", " ",
            " Cyan  ", " ",
            " White ",
            "\n";
    print "Normal:";
    for my $i (0..7) {
        print " ", rgb_str(
            '       ',
            $palette[$i],
        );
    }
    print "\n";
    print "Bright:";
    for my $i (8..15) {
        print " ", rgb_str(
            '       ',
            $palette[$i],
        );
    }
    print "\n";
}

__END__

=head1 NAME

parse_yaml_theme.pl - create gnome-terminal theme values from a YAML file

=head1 SYNOPSIS

B<parse_yaml_theme.pl>
I<YAML-file>
[B<show>|B<bd>|B<bg>|B<fg>|B<palette_dconf>|B<palette_gconf>|B<yaml>|B<shell>] ...

=head1 DESCRIPTION

Read I<YAML-file> for the values of a GNOME terminal theme. Spit out
the colours on STDOUT.

=head1 OPTIONS

=over

=item B<--version>, B<-V>
X<--version>X<-V>

Print program version to F<STDOUT> and exit.

=back

=head1 EXAMPLES

=head2 YAML Input

    # Steven's Zenburn mod. Slightly darker background.
    ---
    bd: '#E3E3CECEABAB'
    fg: &fg '#BABABDBDB6B6'
    #bg: &bg '#181818181818'
    bg: &bg '#1C1C1C1C1C1C'
    color0: [ *bg, '#3F3F3F3F3F3F' ]
    color1: '#CCCC93939393'
    color2: '#7F7F9F9F7F7F'
    color3: '#E3E3CECEABAB'
    color4: '#DFDFAFAF8F8F'
    color5: '#CCCC93939393'
    color6: '#8C8CD0D0D3D3'
    color7: [ *fg, '#DCDCDCDCCCCC' ]

=head2 Parsed YAML

Print back the processed YAML (note that the anchors/references in the
above input have been expanded and replaced):

    $ parse_yaml_theme.pl steven.yaml yaml
    ---
    bd: '#E3E3CECEABAB'
    bg: '#1C1C1C1C1C1C'
    color0:
      - '#1C1C1C1C1C1C'
      - '#3F3F3F3F3F3F'
    color1: '#CCCC93939393'
    color2: '#7F7F9F9F7F7F'
    color3: '#E3E3CECEABAB'
    color4: '#DFDFAFAF8F8F'
    color5: '#CCCC93939393'
    color6: '#8C8CD0D0D3D3'
    color7:
      - '#BABABDBDB6B6'
      - '#DCDCDCDCCCCC'
    fg: '#BABABDBDB6B6'

=head2 Palette Output

Print the palette colors on the terminal (only works for gnome-terminal
3.12 and above):

    $ parse_yaml_theme.pl steven.yaml show

=head2 Default Output

Note that long lines are broken up with
C<\> characters, for clarity's sake:

    $ parse_yaml_theme.pl steven.yaml
    bd_color='#E3E3CECEABAB'
    bg_color='#1C1C1C1C1C1C'
    fg_color='#BABABDBDB6B6'
    palette=( '#1C1C1C1C1C1C' '#CCCC93939393' \
              '#7F7F9F9F7F7F' '#E3E3CECEABAB' \
              '#DFDFAFAF8F8F' '#CCCC93939393' \
              '#8C8CD0D0D3D3' '#BABABDBDB6B6' \
              '#3F3F3F3F3F3F' '#CCCC93939393' \
              '#7F7F9F9F7F7F' '#E3E3CECEABAB' \
              '#DFDFAFAF8F8F' '#CCCC93939393' \
              '#8C8CD0D0D3D3' '#DCDCDCDCCCCC' )

=head2 Output for "install.sh"

Output that can be C<eval>-ed in the shell to produce
strings that can be used in the C<install.sh> script.
Note that long lines are broken up with
C<\> characters, for clarity's sake:

    $ parse_yaml_theme.pl steven.yaml shell
    bd_color='#E3E3CECEABAB'
    bg_color='#1C1C1C1C1C1C'
    fg_color='#BABABDBDB6B6'
    palette_dconf="'#1C1C1C1C1C1C', '#CCCC93939393', '#7F7F9F9F7F7F', \
     '#E3E3CECEABAB', '#DFDFAFAF8F8F', '#CCCC93939393', '#8C8CD0D0D3D3', \
     '#BABABDBDB6B6', '#3F3F3F3F3F3F', '#CCCC93939393', '#7F7F9F9F7F7F', \
     '#E3E3CECEABAB', '#DFDFAFAF8F8F', '#CCCC93939393', '#8C8CD0D0D3D3', \
     '#DCDCDCDCCCCC'"
    palette_gconf='#1C1C1C1C1C1C:#CCCC93939393:#7F7F9F9F7F7F:#E3E3CECEABAB:\
     #DFDFAFAF8F8F:#CCCC93939393:#8C8CD0D0D3D3:#BABABDBDB6B6:#3F3F3F3F3F3F:\
     #CCCC93939393:#7F7F9F9F7F7F:#E3E3CECEABAB:#DFDFAFAF8F8F:#CCCC93939393:\
     #8C8CD0D0D3D3:#DCDCDCDCCCCC'

Typical usage:

    $ eval $(parse_yaml_theme.pl steven.yaml shell)

    $ dconf write $profile_path/palette "[$palette_dconf]"
    $ dconf write $profile_path/bold-color "'$bd_color'"

    $ gconftool-2 -s -t string $profile_path/palette $palette_gconf
    $ gconftool-2 -s -t string $profile_path/bold_color $bd_color

=head2 Individual Colours

Get the bold colour:

    $ parse_yaml_theme.pl steven.yaml bd
    #E3E3CECEABAB

Get the bold, foreground and background colours:

    $ parse_yaml_theme.pl steven.yaml bd fg bg
    #E3E3CECEABAB
    #BABABDBDB6B6
    #1C1C1C1C1C1C

=head2 Palette Strings

Get the palette string for dconf
(note that long lines are broken up with
C<\> characters, for clarity's sake):

    $ parse_yaml_theme.pl palette_dconf
    '#1C1C1C1C1C1C', '#CCCC93939393', \
    '#7F7F9F9F7F7F', '#E3E3CECEABAB', \
    '#DFDFAFAF8F8F', '#CCCC93939393', \
    '#8C8CD0D0D3D3', '#BABABDBDB6B6', \
    '#3F3F3F3F3F3F', '#CCCC93939393', \
    '#7F7F9F9F7F7F', '#E3E3CECEABAB', \
    '#DFDFAFAF8F8F', '#CCCC93939393', \
    '#8C8CD0D0D3D3', '#DCDCDCDCCCCC'

Get the palette string for gconf
(note that long lines are broken up with
C<\> characters, for clarity's sake):

    $ parse_yaml_theme.pl palette_gconf
    #1C1C1C1C1C1C:#CCCC93939393:#7F7F9F9F7F7F:#E3E3CECEABAB:\
    #DFDFAFAF8F8F:#CCCC93939393:#8C8CD0D0D3D3:#BABABDBDB6B6:\
    #3F3F3F3F3F3F:#CCCC93939393:#7F7F9F9F7F7F:#E3E3CECEABAB:\
    #DFDFAFAF8F8F:#CCCC93939393:#8C8CD0D0D3D3:#DCDCDCDCCCCC

=head1 EXIT CODE

=over

=item I<zero>

Success.

=item I<non-zero>

One or more errors occurred.

=back

=head1 AUTHOR

Steven Bakker E<lt>Steven.Bakker@ams-ix.netE<gt>; 2014.

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2014 Steven Bakker; All rights reserved.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. See "perldoc perlartistic".

This software is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

=cut
