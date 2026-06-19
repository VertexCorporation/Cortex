use strict;
use warnings;

my $file = '../lib/chat/services/compression.dart';
open(my $fh, '<', $file) or die "Cannot open $file: $!";
my $content = do { local $/; <$fh> };
close($fh);

$content =~ s/final lower = cleaned\.toLowerCase\(\);/myLower:/g;

# Wait, it is dart code.
