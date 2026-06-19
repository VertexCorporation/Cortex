use strict;
use warnings;

my $file = '../lib/chat/services/compression.dart';
open(my $fh, '<', $file) or die "Cannot open $file: $!";
my $content = do { local $/; <$fh> };
close($fh);

$content =~ s/if \(!isSystem\) \{.*?return cleaned;/if (!isSystem) {
      bool changed = true;
      while (changed) {
        changed = false;
        final lower = cleaned.toLowerCase();
        for (final filler in _fillers) {
          if (lower.startsWith(filler)) {
            final len = filler.length;
            if (cleaned.length > len) {
              final nextChar = cleaned[len];
              if (nextChar == ',' || nextChar == '.' || nextChar == '!' || nextChar == ' ' || nextChar == '?') {
                cleaned = cleaned.substring(len).trim();
                if (cleaned.startsWith(',') || cleaned.startsWith('.') || cleaned.startsWith('!') || cleaned.startsWith('?')) {
                  cleaned = cleaned.substring(1).trim();
                }
                changed = true;
                break;
              }
            } elsif (cleaned.length == len) {
              cleaned = '';
              changed = true;
              break;
            }
          }
        }
      }
    }

    return cleaned;/s;

open(my $out_fh, '>', $file) or die "Cannot open $file: $!";
print $out_fh $content;
close($out_fh);
