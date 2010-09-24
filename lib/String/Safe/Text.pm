use strict;
use warnings;
package String::Safe::Text;
use base 'String::Safe';

use Encode ();

require String::Safe::Byte;

sub encode {
  my ($self, $encoding, $check) = @_;
  $encoding = 'utf-8' unless defined $encoding;
  $check    = Encode::FB_CROAK unless defined $check;

  my $copy  = $$self;
  my $bytes = Encode::encode($encoding, $copy, $check);

  return String::Safe::Byte->from_raw_string(\$bytes);
}

1;
