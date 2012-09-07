use strict;
use warnings;
use Test::More;
use Geo::Hash qw(:adjacent);

ok my $gh = Geo::Hash->new;
isa_ok $gh, 'Geo::Hash';

# Made these tests by using 
# http://blog.masuidrive.jp/wp-content/uploads/2010/01/geohash.html
is $gh->adjacent('xn76gg', ADJ_RIGHT), 'xn76u5'; # RIGHT
is $gh->adjacent('xn76gg', ADJ_LEFT), 'xn76ge'; # LEFT
is $gh->adjacent('xn76gg', ADJ_TOP), 'xn76gu'; # TOP
is $gh->adjacent('xn76gg', ADJ_BOTTOM), 'xn76gf'; # BOTTOM

is $gh->adjacent('xpst02vt', ADJ_RIGHT), 'xpst02vv'; # RIGHT
is $gh->adjacent('xpst02vt', ADJ_LEFT), 'xpst02vm'; # LEFT
is $gh->adjacent('xpst02vt', ADJ_TOP), 'xpst02vw'; # TOP
is $gh->adjacent('xpst02vt', ADJ_BOTTOM), 'xpst02vs'; # BOTTOM

# Check edge cases
is $gh->adjacent('00', ADJ_BOTTOM), 'bp';
is $gh->adjacent('00', ADJ_LEFT)  , 'pb';
is $gh->adjacent('zz', ADJ_TOP)   , 'pb';
is $gh->adjacent('zz', ADJ_RIGHT) , 'bp';

done_testing;
