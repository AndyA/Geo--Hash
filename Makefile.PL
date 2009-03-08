use 5.006001;

use strict;
use ExtUtils::MakeMaker;

eval 'use ExtUtils::MakeMaker::Coverage';

WriteMakefile(
  ( MM->can( 'signature_target' ) ? ( SIGN => 1 ) : () ),
  license( 'perl' ),
  NAME          => 'Geo::Hash',
  AUTHOR        => 'Andy Armstrong <andy@hexten.net>',
  VERSION_FROM  => 'lib/Geo/Hash.pm',
  ABSTRACT_FROM => 'lib/Geo/Hash.pm',
  PL_FILES      => {},
  PREREQ_PM     => { 'Test::More' => 0, },
  dist          => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
  clean => { FILES => 'Geo-Hash-*' },
);

sub license {
  my $lic = shift;
  local $^W = 0;    # Silence warning about non-numeric version
  return
   unless $ExtUtils::MakeMaker::VERSION >= '6.31';
  return ( LICENSE => $lic );
}
