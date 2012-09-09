//
//  gcdbStaticCoordinates.m
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

#import "gcdbStaticCoordinates.h"

@implementation gcdbStaticCoordinates

static double homeLat = 0;
static double homeLon = 0;

+ (double) homeLat{
	return homeLat;
}

+ (void) setHomeLat:(double) newLat{
	homeLat = newLat;
}

+ (double) homeLon{
	return homeLon;
}

+ (void) setHomeLon:(double) newLon{
	homeLon = newLon;
}


+ (void) setDefaultHomeCoordinates{
	[self setHomeLat:[[NSUserDefaults standardUserDefaults] doubleForKey:@"homeLat"]];
	[self setHomeLon:[[NSUserDefaults standardUserDefaults] doubleForKey:@"homeLon"]];
}

@end
