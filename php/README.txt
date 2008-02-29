============================================================
GeoHash PHP Class

Provides a class for generating and decoding geohashes as
documented at http://en.wikipedia.org/wiki/Geohash

Developed by Paul Dixon and licenced for reuse via the
GNU General Public Licence - see LICENCE.txt for details
============================================================


UPDATES
-------------------------------------------------------
The latest version of this class is available from
http://blog.dixo.net/downloads/


HISTORY
-------------------------------------------------------
0.10 - 27th Feb 2008 - First release




EXAMPLES
-------------------------------------------------------

$geohash=new Geohash();

#decode a hash
$coords=$geohash->decode("mh7w");
echo "Lat {$coords[0]} Long {$coords[1]}<br>";

#encode a hash
$hash=$geohash->encode(-62.5, 23.4);
echo "Hash is $hash<br>";


