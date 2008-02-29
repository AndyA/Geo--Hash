use strict;
use warnings;
use Test::More;
use Geo::Hash;

my @tests = (
    {
        hash => 'ezs42',
        pos  => [ 42.6, -5.6 ],
        eps  => 0.01,
    },
    {
        hash => 'mh7w',
        pos  => [ -20, 50 ],
        eps  => 0.1,
    },
    {
        hash => 't3b9m',
        pos  => [ 10.1, 57.2 ],
        eps  => 0.1,
    },
    {
        hash => 'c2b25ps',
        pos  => [ 49.26, -123.26 ],
        eps  => 0.001,
    },
    {
        hash => '80021bgm',
        pos  => [ 0.005, -179.567 ],
        eps  => 0.001,
    },
    {
        hash => 'k484ht99h2',
        pos  => [ -30.55555, 0.2 ],
        eps  => 0.00001,
    },
    {
        hash => '8buh2w4pnt',
        pos  => [ 5.00001, -140.6 ],
        eps  => 0.00001,
    },
);

plan tests => 5 * @tests;

for my $test ( @tests ) {
    my ( $hash, $pos, $eps ) = @{$test}{qw(hash pos eps)};
    ok my $gh = Geo::Hash->new, "$hash: new";
    isa_ok $gh, 'Geo::Hash';
    is $gh->encode( @$pos, length $hash ), $hash, "$hash: encode";
    my @got = $gh->decode( $hash );
    ok abs( $got[$_] - $pos->[$_] ) < $eps, "$hash: decode $_"
      for 0 .. 1;
}
