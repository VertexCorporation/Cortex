use strict;
use warnings;

my $file = '../lib/chat/services/pii_filter.dart';
open(my $fh, '<', $file) or die "Cannot open $file: $!";
my $content = do { local $/; <$fh> };
close($fh);

$content =~ s/r'\b\(\\?\:\\\+\\?\\d\{1,3\}\[- \]\?\)\?\(\\?\\d\{3\}\\)\?\[- \]\?\\d\{3\}\[- \]\?\\d\{4\}\b'/r'(?<!\d)(?:\+?\d{1,3}[- ]?)?\(?\d{3}\)?[- ]?\d{3}[- ]?\d{4}(?!\d)'/;

open(my $out_fh, '>', $file) or die "Cannot open $file: $!";
print $out_fh $content;
close($out_fh);
