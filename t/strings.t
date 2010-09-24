use strict;
use warnings;
use utf8;

use Test::More;

use String::Safe::Utils qw(text_string byte_string);

my $SSB = 'String::Safe::Byte';
my $SST = 'String::Safe::Text';

subtest "starting with text" => sub {
  my $text  = text_string("Queensrÿche");

  isa_ok($text, $SST, "result of text_string");

  is(length($$text), 11, "we've put the 11 text character string into a $SST");

  my $bytes = $text->encode;

  isa_ok($bytes, $SSB, "encoded $SST");

  is(length($$text), 11, "...making an encoded copy of the $SST is safe");

  cmp_ok(length $$bytes, '>', length $$text, "encoded string is longer");

  cmp_ok($$text, 'ne', $$bytes, 'the two "strings" are not string-equal');

  my $text_2 = $bytes->decode;

  is($$text, $$text_2, "round-tripping text via bytes is safe");
};

subtest "starting with bytes" => sub {
  my @bytes = qw(51 75 65 65 6e 73 72 c3 bf 63 68 65);
  my $byte_raw = join q{}, map { chr hex } @bytes;

  my $bytes = byte_string($byte_raw);

  isa_ok($bytes, $SSB, "result of byte_string");

  is(length($$bytes), @bytes, "we have as many bytes as we expected");

  my $text  = $bytes->decode;

  isa_ok($text, $SST, "decoded $SSB");

  is($$text, 'Queensrÿche', "we can decode to the expected string");
};

done_testing;
