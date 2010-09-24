use strict;
use warnings;
package String::Safe;

use Carp ();
use Scalar::Util ();

sub from_raw_string {
  my ($class, $input) = @_;

  Carp::croak("can't build a $class from undef") unless defined $input;

  Carp::croak("can't build a $class from an object")
    if Scalar::Util::blessed($input);

  my $reftype = Scalar::Util::reftype $input;

  my $ref;
  if (! defined $reftype) {
    $ref = \$input;
  } elsif ($reftype eq 'SCALAR') {
    $ref =  $input;
  } else {
    Carp::croak("can't build a $class from a $reftype reference");
  }

  bless $ref => $class;
}

1;
