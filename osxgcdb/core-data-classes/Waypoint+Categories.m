//
//  Waypoint+Categories.m
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

#import "Waypoint+Categories.h"
#import "gcdbCoordinateUitls.h"
#import "gcdbGeocacheUtils.h"
#import "gcdbStaticCoordinates.h"

@implementation Waypoint (Categories)



- (NSString*) coordinates {
	
	return [gcdbCoordinateUitls LatLonString:[[self lat] doubleValue] Longitude:[[self lon] doubleValue]];
    
}

- (void) setCoordinates:(NSString*)input {
	
}

- (NSString*) symPictogram {
	
	return [gcdbGeocacheUtils pictogramFromSymbol:[self sym] CacheType:[self type] ];
    
}

- (void) setSymPictogram:(NSString*)input {
	
}

- (NSString*) typeShortName {
	
	return [gcdbGeocacheUtils shortNameFromType:[self type] ];
	
}

- (void) setTypeShortName:(NSString*)input {
	
}

- (NSColor*) symColor {
	
	if ([[self sym] isEqualToString:@"Geocache Found"]) {
		return [NSColor lightGrayColor];
	} else {
		return [NSColor blackColor];
	}
    
}

- (void) setSymColor:(NSColor*)input {
	
}



- (NSAttributedString*) symAttStr {
	
    NSMutableAttributedString* string = [[NSMutableAttributedString alloc] initWithString:[self name]];
	
	if ([[self sym] isEqualToString:@"Geocache Found"]) {
        
		NSRange range = NSMakeRange(0, [string length]);
		
		[string beginEditing];
		
		[string addAttribute:NSForegroundColorAttributeName
					   value:[NSColor redColor]
					   range:range];
		
		[string addAttribute:NSStrikethroughStyleAttributeName
					   value:[NSNumber numberWithInt:NSSingleUnderlineStyle]
					   range:range];
		
		
		[string endEditing];
        
	}
    
	return string;
    
}

- (void) setSymAttStr:(NSAttributedString*)input {
	
}


- (NSNumber*) distanceFromHome {
    
	return [NSNumber numberWithDouble:[gcdbCoordinateUitls DistanceBetweenCoords:[gcdbStaticCoordinates homeLat]
                                                                        StartLon:[gcdbStaticCoordinates homeLon]
                                                                         DestLat:[[self lat] doubleValue]
                                                                         DestLon:[[self lon] doubleValue]]];
	
}

- (void) setDistanceFromHome:(NSNumber*)input {
	
}

- (NSString*) bearingFromHome {
	
	return [gcdbCoordinateUitls CompassBearingBetweenCoords:[gcdbStaticCoordinates homeLat]
                                                   StartLon:[gcdbStaticCoordinates homeLon]
                                                    DestLat:[[self lat] doubleValue]
                                                    DestLon:[[self lon] doubleValue]];
	
}

- (void) setBearingFromHome:(NSString*)input {
	
}

@end
