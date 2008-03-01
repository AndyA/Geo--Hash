#!/usr/bin/perl

use strict;
use warnings;
# use lib qw(lib);
# use Geo::Hash;

sub log10 {
    my $n = shift;
    return log( $n ) / log( 10 );
}

sub log2 {
    my $n = shift;
    return log( $n ) / log( 2 );
}

sub digits_to_bits {
    my $digits = shift;

    for ( 0 .. 53 ) {
        return $_ if length( 1 << $_ ) > $digits;
    }

    return;
}

sub d2b {
    my $digits = shift;
    return int( $digits * 3.32192809488736 + 1 );
}

print log2( 10 ), "\n";

for ( 2 .. 9 ) {
    print join( ', ',
        $_, d2b( $_ ),
        digits_to_bits( $_ ),
        log10( $_ ),
        log2( $_ ) ),
      "\n";
}

