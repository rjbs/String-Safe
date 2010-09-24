use strict;
use warnings;
package String::Safe::Byte;
use base 'String::Safe';

use Encode ();

require String::Safe::Text;

sub decode {
  my ($self, $encoding, $check) = @_;
  $encoding = 'utf-8' unless defined $encoding;
  $check    = Encode::FB_CROAK unless defined $check;

  my $copy  = $$self;
  my $text  = Encode::decode($encoding, $copy, $check);

  return String::Safe::Text->from_raw_string(\$text);
}

1;
