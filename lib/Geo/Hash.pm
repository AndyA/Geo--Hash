package Geo::Hash;

use warnings;
use strict;
use Carp;

=head1 NAME

Geo::Hash - Encode / decode geohash.org locations.

=head1 VERSION

This document describes Geo::Hash version 0.02

=cut

our $VERSION = '0.02';

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

=head2 C<< encode >>

Encode a lat, long pair into a geohash.

    my $hash = $gh->encode( $lat, $lon );

You may optionally supply the length of the desired geohash:

    # Very precise
    my $hash = $gh->encode( $lat, $lon, 10 );

If the precision argument is omitted an eight character geohash will
be created.

=cut

sub encode {
    croak "encode needs two or three arguments"
      unless @_ >= 3 && @_ <= 4;
    my ( $self, @pos ) = splice @_, 0, 3;
    my $prec = shift || 8;
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
            $flip = 1 - $flip;
        }
        push @enc, $ENC[$bits];
    }
    return join '', @enc;
}

=head2 C<< decode >>

Decode a geohash into a lat, long pair.

    my ( $lat, $lon ) = $gh->decode( $hash );

=cut

sub decode {
    croak "decode needs one argument"
      unless @_ == 2;
    my ( $self, $hash ) = @_;

    my $int = [ [ 90, -90 ], [ 180, -180 ] ];
    my $flip = 1;

    for my $ch ( split //, $hash ) {
        if ( defined( my $bits = $DEC{$ch} ) ) {
            for ( 0 .. 4 ) {
                $int->[$flip][ ( $bits & 16 ) >> 4 ]
                  = _mid( $int, $flip );
                $flip = 1 - $flip;
                $bits <<= 1;
            }
        }
        else {
            croak "Bad character '$ch' in hash '$hash'";
        }
    }

    return map { _mid( $int, $_ ) } 0 .. 1;
}

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

=head1 LICENCE AND COPYRIGHT

Copyright (c) 2008, Andy Armstrong C<< <andy@hexten.net> >>.

This module is free software; you can redistribute it and/or
modify it under the same terms as Perl itself. See L<perlartistic>.
