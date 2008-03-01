/* geohash.c */

#include <string.h>
#include <stdio.h>
#include <math.h>

#define AVERAGE(d1, d2) (((d1) + (d2)) / 2)
#define BAD_CODE 0xFF

static const char *_enc = "0123456789bcdefghjkmnpqrstuvwxyz";
static unsigned char _dec[256];
static int _dec_inited = 0;

/* The buffer must be at least len + 1 bytes long */

char *
encode_with_len( double lat, double lon, char *hash, size_t len ) {
    double interval[2][2] = { {90, -90}, {180, -180} };
    double pos[2];
    int hp, flip = 1;
    pos[0] = lat;
    pos[1] = lon;

    for ( hp = 0; hp < len; hp++ ) {
        unsigned b, bits = 0;
        for ( b = 0; b < 5; b++ ) {
            double mid = AVERAGE( interval[flip][0], interval[flip][1] );
            unsigned bit = pos[flip] >= mid ? 1 : 0;
            bits = ( bits << 1 ) | bit;
            interval[flip][bit] = mid;
            flip ^= 1;
        }
        hash[hp] = _enc[bits];
    }

    hash[hp] = '\0';
    return hash;
}

unsigned
_bits_for_number( double n ) {
    char buf[40];
    int bp;
    const char *dot;
    sprintf( buf, "%32.8f", n );

    if ( ( dot = strchr( buf, '.' ) ) == NULL ) {
        return 0;
    }

    for ( bp = strlen( buf ) - 1; bp >= 0; bp-- ) {
        if ( buf[bp] != '0' ) {
            return ( int ) ( ( double ) ( bp - ( dot - buf ) ) *
                             3.32192809488736 + 1 );
        }
    }

    return 0;
}

int
precision( double lat, double lon ) {
    int lab = _bits_for_number( lab ) + 8;
    int lob = _bits_for_number( lon ) + 9;
    return ( int ) ( ( ( lab > lob ? lab : lob ) + 1 ) / 2.5 );
}

char *
encode( double lat, double lon, char *hash, size_t len ) {
    int prec = precision( lat, lon );
    if ( len > prec ) {
        len = prec;
    }
    return encode_with_len( lat, lon, hash, lon );
}

static void
_init_hash_to_bits( void ) {
    if ( !_dec_inited ) {
        int ep;
        memset( _dec, BAD_CODE, sizeof( _dec ) );
        for ( ep = 0; _enc[ep]; ep++ ) {
            _dec[( int ) _enc[ep]] = ep;
        }
    }
}

int
decode_to_interval( const char *hash, double *lat_lo, double *lon_lo,
                    double *lat_hi, double *lon_hi ) {
    double interval[2][2] = { {90, -90}, {180, -180} };
    unsigned flip = 1;
    const unsigned char *hp;

    _init_hash_to_bits(  );

    for ( hp = ( const unsigned char * ) hash; *hp; hp++ ) {
        unsigned b, bits = _dec[*hp];
        if ( bits == BAD_CODE ) {
            return -1;
        }
        for ( b = 0; b < 5; b++ ) {
            interval[flip][( bits & 0x10 ) >> 4] =
                AVERAGE( interval[flip][0], interval[flip][1] );
            flip ^= 1;
            bits <<= 1;
        }
    }

    *lat_lo = interval[0][1];
    *lat_hi = interval[0][0];
    *lon_lo = interval[1][1];
    *lon_hi = interval[1][0];

    return 0;
}

int
decode( const char *hash, double *lat, double *lon ) {
    double lat_lo, lon_lo, lat_hi, lon_hi;
    int rc;

    if ( ( rc =
           decode_to_interval( hash, &lat_lo, &lon_lo, &lat_hi,
                               &lon_hi ) ) != 0 ) {
        return rc;
    }

    *lat = AVERAGE( lat_lo, lat_hi );
    *lon = AVERAGE( lon_lo, lon_hi );

    return rc;
}

static int _test_num = 0;

void
ok( int pass, const char *msg ) {
    printf( "%sok %d %s\n", pass ? "" : "not ", ++_test_num, msg );
}

void
plan( int count ) {
    printf( "1..%d\n", count );
}

#define COUNT(ar) (sizeof(ar) / sizeof(ar[0]))

int
main( void ) {
    /* *INDENT-OFF* */
    static struct {
        const char *hash;
        double lat, lon;
        double eps;
    } tests[] = {
        { "ezs42",        42.6,       -5.6,    0.01     }, 
        { "mh7w",        -20,         50,      0.1      }, 
        { "t3b9m",        10.1,       57.2,    0.1      },
        { "c2b25ps",      49.26,    -123.26,   0.01     }, 
        { "80021bgm",      0.005,   -179.567,  0.001    },
        { "k484ht99h2",  -30.55555,    0.2,    0.00001  }, 
        { "8buh2w4pnt",    5.00001, -140.6,    0.00001  }
    };
    int tn;
    
    /* *INDENT-ON* */
    plan( COUNT( tests ) * 4 );

    for ( tn = 0; tn < COUNT( tests ); tn++ ) {
        char buf[100];
        double lat, lon;
        char *hash = encode_with_len( tests[tn].lat, tests[tn].lon, buf,
                                      strlen( tests[tn].hash ) );
        ok( strcmp( hash, tests[tn].hash ) == 0, "encode_with_len" );
        // fprintf( stderr, "# %s %s\n", tests[tn].hash, hash );
        ok( 0 == decode( hash, &lat, &lon ), "decode" );
        // fprintf( stderr, "# %g %g | %g %g\n", lat, tests[tn].lat, lon,
        //          tests[tn].lon );
        ok( fabs( lat - tests[tn].lat ) < tests[tn].eps, "lat" );
        ok( fabs( lon - tests[tn].lon ) < tests[tn].eps, "lon" );
    }

    return 0;
}
