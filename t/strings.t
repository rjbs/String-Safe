use strict;
use warnings;
use utf8;

use Test::More;

use String::Safe -all;

my $SSB = 'String::Safe::Byte';
my $SST = 'String::Safe::Text';

# These are defined as subs instead of data so that we always get new copies
# and can't accidentally destroy the source data. -- rjbs, 2010-09-24
sub test_text  {
  return { 
    string => "Queensrÿche",
    length => 11,
  };
}

sub test_bytes { 
  my @bytes = qw(51 75 65 65 6e 73 72 c3 bf 63 68 65);

  return {
    string => join(q{}, map { chr hex } @bytes),
    length => 0+@bytes,
  };
}

subtest "starting with text" => sub {
  my $text  = text( test_text->{string} );

  isa_ok($text, $SST, "result of text");

  is(
    length($$text),
    test_text->{length},
    "we can get the text string's length normally",
  );

  my $bytes = $text->encode;

  isa_ok($bytes, $SSB, "encoded $SST");

  # This test is here because early in implementation we had done something
  # like Encode::encode('utf-8', $$string) and it was destructive to the
  # string being encoded. -- rjbs, 2010-09-24
  is(
    length($$text),
    test_text->{length},
    "... making an encoded copy of the $SST is safe",
  );

  cmp_ok(length $$bytes, '>', length $$text, "encoded string is longer");

  cmp_ok($$text, 'ne', $$bytes, 'the two "strings" are not string-equal');

  my $text_2 = $bytes->decode('utf-8');

  is($$text, $$text_2, "round-tripping text via bytes is safe");
};

subtest "starting with bytes" => sub {
  my @bytes = qw(51 75 65 65 6e 73 72 c3 bf 63 68 65);
  my $byte_raw = join q{}, map { chr hex } @bytes;

  my $bytes = bytes( test_bytes->{string} );

  isa_ok($bytes, $SSB, "result of bytes()");

  is(
    length($$bytes),
    test_bytes->{length},
    "we have as many bytes as we expected",
  );

  my $text  = $bytes->decode('utf-8');

  isa_ok($text, $SST, "decoded $SSB");

  is($$text, 'Queensrÿche', "we can decode to the expected string");
};

subtest "various inputs to text()" => sub {
  {
    my $text = text( test_text->{string} );
    isa_ok($text, $SST, 'text($string)');
    is($$text, test_text->{string}, '${ text($string) } eq $string');
  }

  {
    my $text = text( \(test_text->{string}) );
    isa_ok($text, $SST, 'text(\\$string)');
    is($$text, test_text->{string}, '${ text(\\$string) } eq $string');
  }

  {
    my $text = text( 'literal' );
    isa_ok($text, $SST, 'text("literal")');
    is($$text, 'literal', '${ text("literal") } eq "literal"');
  }

  {
    my $text = text( \'literal' );
    isa_ok($text, $SST, 'text($string)');
    is($$text, 'literal', '${ text($string) } eq $string');
  }

  my $meta = text( text( test_text->{string} ) );
  isa_ok($meta, $SST, 'text($Safe_String_Text)');
  is($$meta, test_text->{string}, '${ text($Safe_String_Text) }');

  {
    my $lives = eval { text($SSB->from_raw_string( test_bytes->{string} )); 1 };
    my $error = $@;
    ok(! $lives, "trying to text() a $SSB is fatal");
    like($error, qr/can't build.+from $SSB/, "... with expected message");
  }

  {
    my $lives = eval { text( [ ] ); 1 };
    my $error = $@;
    ok(! $lives, "trying to text() a non-string ref is fatal");
    like($error, qr/can't build.+from ARRAY/, "... with expected message");
  }
};

subtest "various inputs to bytes()" => sub {
  {
    my $bytes = bytes( test_bytes->{string} );
    isa_ok($bytes, $SSB, 'bytes($string)');
    is($$bytes, test_bytes->{string}, '${ bytes($string) } eq $string');
  }

  {
    my $bytes = bytes( \(test_bytes->{string}) );
    isa_ok($bytes, $SSB, 'bytes(\\$string)');
    is($$bytes, test_bytes->{string}, '${ bytes(\\$string) } eq $string');
  }

  {
    my $bytes = bytes( 'literal' );
    isa_ok($bytes, $SSB, 'bytes("literal")');
    is($$bytes, 'literal', '${ bytes("literal") } eq "literal"');
  }

  {
    my $bytes = bytes( \'literal' );
    isa_ok($bytes, $SSB, 'bytes(\\"literal")');
    is($$bytes, 'literal', '${ bytes(\\"literal") } eq $string');
  }

  my $meta = bytes( bytes( test_bytes->{string} ) );
  isa_ok($meta, $SSB, 'bytes($Safe_String_Bytes)');
  is($$meta, test_bytes->{string}, '${ bytes($Safe_String_Bytes) }');

  {
    my $lives = eval { bytes($SST->from_raw_string( test_text->{string} )); 1 };
    my $error = $@;
    ok(! $lives, "trying to bytes() a $SST is fatal");
    like($error, qr/can't build.+from $SST/, "... with expected message");
  }

  {
    my $lives = eval { bytes( [ ] ); 1 };
    my $error = $@;
    ok(! $lives, "trying to bytes() a non-string ref is fatal");
    like($error, qr/can't build.+from ARRAY/, "... with expected message");
  }
};

subtest "various inputs to decode()" => sub {
  {
    my $lives = eval { decode( test_bytes->{string} ); 1 };
    my $error = $@;
    ok(! $lives, "we can't decode without specifying the encoding");
    like($error, qr/no encoding supplied/, "... with expected message");
  }

  {
    my $text = decode( test_bytes->{string}, 'utf-8' );
    isa_ok($text, $SST, 'decode($string, "utf-8")');
    is($$text, test_text->{string}, 'decoded bytes eq test text');
  }

  {
    my $text = decode( \(test_bytes->{string}), 'utf-8' );
    isa_ok($text, $SST, 'decode(\\$string, "utf-8")');
    is($$text, test_text->{string}, 'decoded bytes eq test text');
  }

  {
    my $text = decode( "Queensr\xc3\xbfche", 'utf-8' );
    isa_ok($text, $SST, 'decode("literal", "utf-8")');
    is($$text, test_text->{string}, 'decoded literal is what we want');
  }

  {
    my $text = decode( \"Queensr\xc3\xbfche", 'utf-8' );
    isa_ok($text, $SST, 'decode(\\"literal", "utf-8")');
    is($$text, test_text->{string}, 'decoded literal-ref is what we want');
  }

  my $meta = decode( bytes( test_bytes->{string} ), 'utf-8' );
  isa_ok($meta, $SST, 'decode( $Safe_String_Bytes, "utf-8")');
  is($$meta, test_text->{string}, 'decode($Safe_String_Bytes) eq text');

  {
    my $lives = eval {
      decode($SST->from_raw_string( test_text->{string} ), 'utf-8');
      1;
    };
    my $error = $@;
    ok(! $lives, "trying to decode() a $SST is fatal");
    like($error, qr/can't build.+from $SST/, "... with expected message");
  }

  {
    my $lives = eval { decode( [ ], 'utf-8' ); 1 };
    my $error = $@;
    ok(! $lives, "trying to decode() a non-string ref is fatal");
    like($error, qr/can't build.+from ARRAY/, "... with expected message");
  }
};

subtest "various inputs to encode()" => sub {
  {
    my $bytes = encode( test_text->{string} );
    isa_ok($bytes, $SSB, 'encode( $text_string )');
    is($$bytes, test_bytes->{string}, '... bytes eq expected bytestring');
  }

  {
    my $bytes = encode( test_text->{string}, 'utf-8' );
    isa_ok($bytes, $SSB, 'encode($text_string, "utf-8")');
    is($$bytes, test_bytes->{string}, '... bytes eq expected bytestring');
  }

  {
    my $latin_1 = Encode::encode('Latin-1', test_text->{string});
    my $bytes = encode( test_text->{string}, 'Latin-1' );
    isa_ok($bytes, $SSB, 'encode($text_string, "Latin-1")');
    is($$bytes, $latin_1, '... bytes eq expected bytestring');
  }

  {
    my $bytes = encode( \(test_text->{string}) );
    isa_ok($bytes, $SSB, 'encode(\\$string)');
    is($$bytes, test_bytes->{string}, '... bytes eq expected bytestring');
  }

  {
    my $bytes = encode("Queensrÿche");
    isa_ok($bytes, $SSB, 'encode("literal")');
    is($$bytes, test_bytes->{string}, '... bytes eq expected bytestring');
  }

  {
    my $bytes = encode( \"Queensrÿche" );
    isa_ok($bytes, $SSB, 'encode(\\"literal")');
    is($$bytes, test_bytes->{string}, '... bytes eq expected bytestring');
  }

  {
    my $meta = encode( text( test_text->{string} ) );
    isa_ok($meta, $SSB, 'encode( $Safe_String_Text )');
    is($$meta, test_bytes->{string}, '... bytes eq expected bytestring');
  }

  {
    my $lives = eval {
      encode($SSB->from_raw_string( test_bytes->{string} ) );
      1;
    };
    my $error = $@;
    ok(! $lives, "trying to encode() a $SSB is fatal");
    like($error, qr/can't build.+from $SSB/, "...with expected message");
  }

  {
    my $lives = eval { encode( [ ] ); 1 };
    my $error = $@;
    ok(! $lives, "trying to encode() a non-string ref is fatal");
    like($error, qr/can't build.+from ARRAY/, "...with expected message");
  }
};

# subtest "is_text and assert_text" => sub {
#   fail('unimplemented')
# };
# 
# subtest "is_bytes and assert_bytes" => sub {
#   fail('unimplemented')
# };

done_testing;
