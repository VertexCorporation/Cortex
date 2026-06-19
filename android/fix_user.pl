use strict;
use warnings;

my $file = '../lib/server/user.dart';
open(my $fh, '<', $file) or die "Cannot open $file: $!";
my @lines = <$fh>;
close($fh);

for my $i (0 .. $#lines) {
    if ($lines[$i] =~ /return level >= 1 && level <= 6 \? level : 0;/) {
        $lines[$i] = "      return level >= 4 ? level : 0;\n";
    }
}

open(my $out_fh, '>', $file) or die "Cannot open $file: $!";
print $out_fh @lines;
close($out_fh);
