use strict;
use warnings;
package String::Safe::Byte;
use base 'String::Safe::Base';

use Encode ();

require String::Safe::Text;

sub decode {
  my ($self, $encoding, $check) = @_;

  Carp::croak("no encoding supplied for bytes-to-text conversion")
    unless defined $encoding;

  $check    = Encode::FB_CROAK unless defined $check;

  my $copy  = $$self;
  my $text  = Encode::decode($encoding, $copy, $check);

  return String::Safe::Text->from_raw_string(\$text);
}

sub from_text_string {
  my ($class, $input, $encoding, $check) = @_;

  $encoding = 'utf-8' unless defined $encoding;

  if (my $blessed = Scalar::Util::blessed($input)) {
    Carp::croak("can't build a $class from $blessed object")
      if ! $input->isa('String::Safe::Text');;
  } elsif (my $reftype = Scalar::Util::reftype($input)) {
    Carp::croak("can't build a $class from $reftype object")
      if $reftype ne 'SCALAR'
  }

  $check    = Encode::FB_CROAK unless defined $check;

  $input    = $$input if ref $input;
  my $text  = Encode::encode($encoding, $input, $check);

  return $class->from_raw_string(\$text);
}

1;
