<?php
/**
 * Geohash generation class test harness
 * http://blog.dixo.net/downloads/
 *
 * This file copyright (C) 2008 Paul Dixon (paul@elphin.com)
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License
 * as published by the Free Software Foundation; either version 3
 * of the License, or (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 */


require_once('geohash.class.php');

$geohash=new Geohash;

//these test hashes were made on geohash.org
//and test various combinations of precision
//and range
$tests=array(
	"ezs42"=>array(42.6,-5.6),
	"mh7w"=>array(-20, 50),
	"t3b9m"=>array(10.1, 57.2),
	"c2b25ps"=>array(49.26, -123.26),
	"80021bgm"=>array(0.005, -179.567),
	"k484ht99h2"=>array(-30.55555, 0.2),
	"8buh2w4pnt"=>array(5.00001, -140.6),
);


foreach($tests as $actualhash=>$coords)
{
	$computed_hash=$geohash->encode($coords[0], $coords[1]);
	
	echo "Encode {$coords[0]}, {$coords[1]} as $actualhash : ";
	if ($computed_hash==$actualhash)
	{
		echo "OK<br>";
	}
	else
	{
		echo "FAIL (got $computed_hash)<br>";
	}
	
	
	echo "<hr>";
	
	$computed_coords=$geohash->decode($actualhash);
	
	echo "Decode $actualhash as {$coords[0]}, {$coords[1]} : ";
	if (($computed_coords[0]==$coords[0]) && ($computed_coords[1]==$coords[1]))
	{
		echo "OK<br>";
	}
	else
	{
		echo "FAIL (got {$computed_coords[0]}, {$computed_coords[1]})<br>";
	}

	echo "<hr>";
}



?>