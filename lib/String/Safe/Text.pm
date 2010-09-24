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

sub from_byte_string {
  my ($class, $input, $encoding, $check) = @_;

  $encoding = 'utf-8' unless defined $encoding;
  $check    = Encode::FB_CROAK unless defined $check;

  $input    = $$input if ref $input;
  my $text  = Encode::decode($encoding, $input, $check);

  return $class->from_raw_string(\$text);
}

1;
