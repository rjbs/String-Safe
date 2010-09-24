use strict;
use warnings;
package String::Safe;

use Encode ();
use Scalar::Util ();
use String::Safe::Byte ();
use String::Safe::Text ();
use Sub::Exporter::Util ();

use Sub::Exporter -setup => {
  exports  => {
    text   => Sub::Exporter::Util::curry_method,
    bytes  => Sub::Exporter::Util::curry_method,

    decode => Sub::Exporter::Util::curry_method,
    encode => Sub::Exporter::Util::curry_method,

    is_text  => Sub::Exporter::Util::curry_method,
    is_bytes => Sub::Exporter::Util::curry_method,

    assert_text  => Sub::Exporter::Util::curry_method,
    assert_bytes => Sub::Exporter::Util::curry_method,
  },
};

sub _text_class { 'String::Safe::Text' }
sub _byte_class { 'String::Safe::Byte' }

sub text {
  my ($class, $input) = @_;

  my $wanted = $class->_text_class;

  return $input if Scalar::Util::blessed($input) && $input->isa( $wanted );

  return $wanted->from_raw_string($input);
}

sub bytes {
  my ($class, $input) = @_;

  my $wanted = $class->_byte_class;

  return $input if Scalar::Util::blessed($input) && $input->isa( $wanted );

  return $wanted->from_raw_string($input);
}

# valid input  : raw string, byte string
# invalid input: anything else (including text string)
sub decode {
  my ($class, $bytes, $encoding, $check) = @_;

  my $wanted = $class->_text_class;

  return $bytes if Scalar::Util::blessed($bytes) && $bytes->isa( $wanted );

  $wanted->from_byte_string($bytes, $encoding, $check);
}

# valid input  : raw string, text string
# invalid input: anything else (including byte string)
sub encode {
  my ($class, $text, $encoding, $check) = @_;

  my $wanted = $class->_byte_class;
  return $text if Scalar::Util::blessed($text) && $text->isa( $wanted );

  $wanted->from_text_string($text, $encoding, $check);
}

sub is_text  { Scalar::Util::blessed($_[1]) && $_[1]->isa($_[0]->_text_class) }
sub is_bytes { Scalar::Util::blessed($_[1]) && $_[1]->isa($_[0]->_byte_class) }

sub assert_text {
  Carp::confess("not a text string") unless $_[0]->is_text($_[1])
}

sub assert_bytes {
  Carp::confess("not a byte string") unless $_[0]->is_bytes($_[1])
}

1;
