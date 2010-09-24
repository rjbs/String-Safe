use strict;
use warnings;
package String::Safe::Utils;

use Encode ();
use Scalar::Util ();
use String::Safe::Byte ();
use String::Safe::Text ();
use Sub::Exporter::Util ();

use Sub::Exporter -setup => {
  exports => {
    text  => Sub::Exporter::Util::curry_method,
    bytes => Sub::Exporter::Util::curry_method,
  },
};

sub text_class { 'String::Safe::Text' }
sub byte_class { 'String::Safe::Byte' }

sub text {
  my ($class, $input) = @_;

  my $wanted = $class->text_class;

  return $input if Scalar::Util::blessed($input) and $input->isa( $wanted );

  return $wanted->from_raw_string($input);
}

sub bytes {
  my ($class, $input) = @_;

  my $wanted = $class->byte_class;

  return $input if Scalar::Util::blessed($input) and $input->isa( $wanted );

  return $wanted->from_raw_string($input);
}

1;
