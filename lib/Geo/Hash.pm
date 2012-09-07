package Geo::Hash;

use warnings;
use strict;
use Carp;

use Exporter 'import';
our @EXPORT_OK   = qw( ADJ_TOP ADJ_RIGHT ADJ_LEFT ADJ_BOTTOM );
our %EXPORT_TAGS = (adjacent => \@EXPORT_OK);

use constant ADJ_RIGHT  => 0;
use constant ADJ_LEFT   => 1;
use constant ADJ_TOP    => 2;
use constant ADJ_BOTTOM => 3;

=head1 NAME

Geo::Hash - Encode / decode geohash.org locations.

=head1 VERSION

This document describes Geo::Hash version 0.03

=cut

our $VERSION = '0.03';

=head1 SYNOPSIS

    use Geo::Hash;

    my $gh = Geo::Hash->new;
    my $hash = $gh->encode( $lat, $lon );
    my ( $lat, $lon ) = $gh->decode( $hash );
  
=head1 DESCRIPTION

Geohash is a latitude/longitude geocode system invented by Gustavo
Niemeyer when writing the web service at geohash.org, and put into the
public domain.

This module encodes and decodes geohash locations.

See L<http://en.wikipedia.org/wiki/Geohash> and L<http://geohash.org>
for more information.

=head1 INTERFACE 

=head2 C<< new >>

Create a new Geo::Hash object.

    my $gh = Geo::Hash->new;

=cut

sub new { bless {}, shift }

my @ENC = qw(
  0 1 2 3 4 5 6 7 8 9 b c d e f g h j k m n p q r s t u v w x y z
);

my %DEC = map { $ENC[$_] => $_ } 0 .. $#ENC;

sub _mid {
    my ( $ar, $wh ) = @_;
    return ( $ar->[$wh][0] + $ar->[$wh][1] ) / 2;
}

# The number of bits necessary to represent the specified number of
# decimal digits
sub _d2b { int( shift() * 3.32192809488736 + 1 ) }

sub _bits_for_number {
    my $n = shift;
    return 0 unless $n =~ s/.*\.//;
    return _d2b( length $n );
}

=head2 C<< precision >>

Infer a suitable precision (number of characters in hash) for a given
lat, lon pair.

    my $prec = $gh->precision( $lat, $lon );

=cut

sub precision {
    my ( $self, $lat, $lon ) = @_;
    my $lab = _bits_for_number( $lat ) + 8;
    my $lob = _bits_for_number( $lon ) + 9;
    return int( ( ( $lab > $lob ? $lab : $lob ) + 1 ) / 2.5 );
}

=head2 C<< encode >>

Encode a lat, long pair into a geohash.

    my $hash = $gh->encode( $lat, $lon );

You may optionally supply the length of the desired geohash:

    # Very precise
    my $hash = $gh->encode( $lat, $lon, 10 );

If the precision argument is omitted C<precision> will be used to
provide a default.

=cut

sub encode {
    croak "encode needs two or three arguments"
      unless @_ >= 3 && @_ <= 4;
    my ( $self, @pos ) = splice @_, 0, 3;
    my $prec = shift || $self->precision( @pos );
    my $int  = [ [ 90, -90 ], [ 180, -180 ] ];
    my $flip = 1;
    my @enc  = ();
    while ( @enc < $prec ) {
        my $bits = 0;
        for ( 0 .. 4 ) {
            my $mid = _mid( $int, $flip );
            my $bit = $pos[$flip] >= $mid ? 1 : 0;
            $bits = ( ( $bits << 1 ) | $bit );
            $int->[$flip][$bit] = $mid;
            $flip ^= 1;
        }
        push @enc, $ENC[$bits];
    }
    return join '', @enc;
}

=head2 C<< decode_to_interval >>

Like C<decode> but instead of returning a pair of coordinates returns
the interval for each coordinate. This gives some indication of how
precisely the original hash specified the location.

The return value is a pair of array refs. Each referred to array
contains the upper and lower bounds for each coordinate.

    my ( $lat_range, $lon_range ) = $gh->decode_to_interval( $hash );
    # $lat_range and $lon_range are references to two element arrays

=cut

sub decode_to_interval {
    croak "Needs one argument"
      unless @_ == 2;
    my ( $self, $hash ) = @_;

    my $int = [ [ 90, -90 ], [ 180, -180 ] ];
    my $flip = 1;

    for my $ch ( split //, $hash ) {
        if ( defined( my $bits = $DEC{$ch} ) ) {
            for ( 0 .. 4 ) {
                $int->[$flip][ ( $bits & 16 ) >> 4 ]
                  = _mid( $int, $flip );
                $flip ^= 1;
                $bits <<= 1;
            }
        }
        else {
            croak "Bad character '$ch' in hash '$hash'";
        }
    }

    return @$int;
}

=head2 C<< decode >>

Decode a geohash into a lat, long pair.

    my ( $lat, $lon ) = $gh->decode( $hash );

=cut

sub decode {
    my @int = shift->decode_to_interval( @_ );
    return map { _mid( \@int, $_ ) } 0 .. 1;
}

=head2 C<< adjacent >>

Returns the adjacent geohash. C<$where> denotes the direction, so if you
want the block to the right of C<$hash>, you say:

    use Geo::Hash qw(ADJ_RIGHT);

    my $adjacent = $gh->adjacent( $hash, ADJ_RIGHT );

=cut

my @NEIGHBORS = (
    [ "bc01fg45238967deuvhjyznpkmstqrwx", "p0r21436x8zb9dcf5h7kjnmqesgutwvy" ],
    [ "238967debc01fg45kmstqrwxuvhjyznp", "14365h7k9dcfesgujnmqp0r2twvyx8zb" ],
    [ "p0r21436x8zb9dcf5h7kjnmqesgutwvy", "bc01fg45238967deuvhjyznpkmstqrwx" ],
    [ "14365h7k9dcfesgujnmqp0r2twvyx8zb", "238967debc01fg45kmstqrwxuvhjyznp" ]
);

my @BORDERS = (
    [ "bcfguvyz", "prxz" ],
    [ "0145hjnp", "028b" ],
    [ "prxz", "bcfguvyz" ],
    [ "028b", "0145hjnp" ]
);

sub adjacent {
    my ( $self, $hash, $where ) = @_;
    my $hash_len = length $hash;

    croak "PANIC: hash too short!"
        unless $hash_len >= 1;

    my $base;
    my $last_char;
    my $type = $hash_len % 2;

    if ( $hash_len == 1 ) {
        $base      = '';
        $last_char = $hash;
    }
    else {
        ( $base, $last_char ) = $hash =~ /^(.+)(.)$/;
        if ($BORDERS[$where][$type] =~ /$last_char/) {
            my $tmp = $self->adjacent($base, $where);
            substr($base, 0, length($tmp)) = $tmp;
        }
    }
    return $base . $ENC[ index($NEIGHBORS[$where][$type], $last_char) ];
}

=head2 C<< neighbors >>

Returns the list of neighbors (the blocks surrounding $hash)

    my @list_of_geohashes = $gh->neighbors( $hash, $around, $offset )

=cut

sub neighbors {
    my ( $self, $hash, $around, $offset ) = @_;
    $around ||= 1;
    $offset ||= 0;

    my $last_hash = $hash;
    my $i = 1;
    while ( $offset-- > 0 ) {
        my $top  = $self->adjacent( $last_hash, ADJ_TOP );
        my $left = $self->adjacent( $top, ADJ_LEFT );
        $last_hash = $left;
        $i++;
    }

    my @list;
    while ( $around-- > 0 ) {
        my $max = 2 * $i - 1;
        $last_hash = $self->adjacent( $last_hash, ADJ_TOP );
        push @list, $last_hash;

        for ( 0..( $max - 1 ) ) {
            $last_hash = $self->adjacent( $last_hash, ADJ_RIGHT );
            push @list, $last_hash;
        }

        for ( 0..$max ) {
            $last_hash = $self->adjacent( $last_hash, ADJ_BOTTOM );
            push @list, $last_hash;
        }

        for ( 0..$max ) {
            $last_hash = $self->adjacent( $last_hash, ADJ_LEFT );
            push @list, $last_hash;
        }

        for ( 0..$max ) {
            $last_hash = $self->adjacent( $last_hash, ADJ_TOP );
            push @list, $last_hash;
        }
        $i++;
    }

    return @list;
}

=head1 CONSTANTS

=head2 ADJ_LEFT, ADJ_RIGHT, ADJ_TOP, ADJ_BOTTOM

Used to specify the direction in C<adjacent()>

=cut

1;
__END__

=head1 CONFIGURATION AND ENVIRONMENT
  
Geo::Hash requires no configuration files or environment variables.

=head1 DEPENDENCIES

None.

=head1 INCOMPATIBILITIES

None reported.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<bug-geo-hash@rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org>.

=head1 AUTHOR

Andy Armstrong  C<< <andy@hexten.net> >>

L<http://geohash.org/gcwrdtsvrfgr>

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Andy Armstrong C<< <andy@hexten.net> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
