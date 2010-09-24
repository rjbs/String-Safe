use strict;
use warnings;
package String::Safe::Base;

use Carp ();
use Scalar::Util ();

sub from_raw_string {
  my ($class, $input) = @_;

  Carp::croak("can't build a $class from undef") unless defined $input;

  my $blessed = Scalar::Util::blessed($input);
  Carp::croak("can't build a $class from a $blessed object") if $blessed;

  my $reftype = Scalar::Util::reftype $input;

  my $ref;
  if (! defined $reftype) {
    $ref = \$input;
  } elsif ($reftype eq 'SCALAR') {
    $ref =  $input;

    if (Scalar::Util::readonly($$ref)) {
      my $copy = $$ref;
      $ref = \$copy;
    }
      
  } else {
    Carp::croak("can't build a $class from a $reftype reference");
  }

  bless $ref => $class;
}

1;
