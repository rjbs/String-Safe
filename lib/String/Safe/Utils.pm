use strict;
use warnings;
package String::Safe::Utils;

use Encode ();
use Scalar::Util ();
use String::Safe::Byte ();
use String::Safe::Text ();

use Sub::Exporter -setup => {
  exports => {
    text_string => \'_gen_text_string',
    byte_string => \'_gen_byte_string',
  },
};

sub _fallback_from_array {
  my ($class, $aref, $arg0) = @_;

  Carp::confess("arrayref fallback must be [ '$arg0', ENCODING, CHECK ]")
    unless $aref->[0] eq $arg0;

  my $function = Encode->can($aref->[0]);
  my $encoding = defined $aref->[1] ? $aref->[1] : 'utf-8';
  my $check    = defined $aref->[2] ? $aref->[2] : Encode::FB_CROAK;

  return sub { $function->($encoding, ${ $_[0] }, $check) };
}

# WE WANT A ____ STRING:
# * Maybe we get a String::Safe::____ -- game over!
# * Maybe we're expecting a ____ string   -- call from_raw_string
# * Maybe we're expecting a OTHERKIND string -- enc/decode
# * Maybe we demand an object -- die if not received
sub _string_processor_gen {
  my ($wanted, $enc_dec) = @_;

  return sub {
    my ($class, $name, $arg) = @_;

    my $fallback = $arg->{fallback};

    if (! defined $fallback) {
      $fallback = sub { $wanted->from_raw_string(${ $_[0] }) };
    } elsif (Params::Util::_ARRAYLIKE($fallback)) {
      $fallback = $class->_fallback_from_array($fallback, $enc_dec);
    } elsif (Scalar::Util::reftype($fallback)) {
      Carp::confess("don't know how to handle $fallback as fallback");
    } elsif ($fallback = $enc_dec) {
      $fallback = $class->_fallback_from_array([ $enc_dec ], $enc_dec);
    } elsif ($fallback = 'fatal') {
      $fallback = sub {
        Carp::croak("$wanted required, but got $_[0]");
      };
    } else {
      Carp::confess("don't know how to handle $fallback as fallback");
    }

    return sub {
      return $_[0]
        if Scalar::Util::blessed($_[0]) and $_[0]->isa($wanted);
      return $fallback->(\$_[0]);
    };
  }
}

BEGIN {
  *_gen_text_string = _string_processor_gen('String::Safe::Text', 'decode');
  *_gen_byte_string = _string_processor_gen('String::Safe::Byte', 'encode');
}

1;
