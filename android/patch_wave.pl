use strict;
use warnings;

my $file = '../lib/chat/screen/widgets/wave.dart';
open(my $fh, '<', $file) or die "Cannot open $file: $!";
my $content = do { local $/; <$fh> };
close($fh);

$content =~ s/child: CustomPaint\(\s*repaint: _notifier,\s*painter: _ModernWavePainter\(/child: CustomPaint(\n                painter: _ModernWavePainter(\n                  repaint: _notifier,/g;

$content =~ s/(_ModernWavePainter\(\{\s*)(required this\.history,)/$1required Listenable repaint,\n    $2/s;

$content =~ s/(required this\.origin,\s*)\}\);/$1}) : super(repaint: repaint);/s;

open(my $out_fh, '>', $file) or die "Cannot open $file: $!";
print $out_fh $content;
close($out_fh);
