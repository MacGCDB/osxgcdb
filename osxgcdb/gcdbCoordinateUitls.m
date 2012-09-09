//
//  gcdbCoordinateUitls.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 4-9-12.
//  Copyright (c) 2012 MacGCDB. All rights reserved.
//
//
//  This file is part of osxgcdb.
//
//  osxgcdb is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  osxgcdb is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with osxgcdb.  If not, see <http://www.gnu.org/licenses/>.
//

#import "gcdbCoordinateUitls.h"
#include <math.h>

@implementation gcdbCoordinateUitls

static double deg2rad(double deg)
{
	return deg * M_PI / 180;
}

static double rad2deg(double rad)
{
	return rad * 180 / M_PI;
}

+ (NSString*) LatLonString:(double)lat Longitude:(double)lon {
	
	NSString *nsText, *ewText;
	
	if (lat >= 0) {
		nsText = @"N";
	} else {
		nsText = @"S";
	}
	
	if (lon >= 0) {
		ewText = @"E";
	} else {
		ewText = @"W";
	}
	
	int latInt = (int) lat;
	int lonInt = (int) lon;
	
	double latMinutes = (lat - latInt) * 60;
	double lonMinutes = (lon - lonInt) * 60;
	
	return [NSString stringWithFormat:@"%@ %d %06.3f %@ %03d %06.3f", nsText, latInt, latMinutes, ewText, lonInt, lonMinutes];
}

+ (double) deg2rad:(double)deg {
	return deg * M_PI / 180;
}

+ (double) DistanceBetweenCoords:(double)lat1 StartLon:(double)lon1 DestLat:(double)lat2 DestLon:(double)lon2 {
	
	double const earthRadius = 6371;
	
	double sphereModel = acos(sin([gcdbCoordinateUitls deg2rad:lat1]) * sin([gcdbCoordinateUitls deg2rad:lat2]) +
                              cos([gcdbCoordinateUitls deg2rad:lat1]) * cos([gcdbCoordinateUitls deg2rad:lat2])
                              * cos([gcdbCoordinateUitls deg2rad:(lon2 - lon1)])) * earthRadius;
	
	return sphereModel;
	
}

+ (int) BearingBetweenCoords:(double)lat1 StartLon:(double)lon1 DestLat:(double)lat2 DestLon:(double)lon2 {
	
	double y = sin(deg2rad(lon2 - lon1)) * cos(deg2rad(lat2));
	double x = cos(deg2rad(lat1)) * sin(deg2rad(lat2))
    - sin(deg2rad(lat1)) * cos(deg2rad(lat2)) * cos(deg2rad(lon2 - lon1));
	
	return (int)(rad2deg(atan2(y, x)) + 360 ) % 360;
	
}

//  Get compass direction (N = 0, NE=45 E = 90, SE = 135, S=180, SW=225 W = 270, NW=315)
//  45 degree increments starting at 23

+ (NSString*) CompassBearingBetweenCoords:(double)lat1 StartLon:(double)lon1 DestLat:(double)lat2 DestLon:(double)lon2 {
	
	int bearing = [self BearingBetweenCoords:lat1 StartLon:lon1 DestLat:lat2 DestLon:lon2];
	
	if (bearing < 23 || bearing > 338) {
		return @"N";
	} else if (bearing < 68) {
		return @"NE";
	} else if (bearing < 113) {
		return @"E";
	} else if (bearing < 158) {
		return @"SE";
	} else if (bearing < 203) {
		return @"S";
	} else if (bearing < 248) {
		return @"SW";
	} else if (bearing < 293) {
		return @"W";
	} else {
		return @"NW";
	}
    
	
}



@end
