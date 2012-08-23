//
//  gcdbGeocacheUtils.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 4-8-12.
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

#import "gcdbGeocacheUtils.h"

@implementation gcdbGeocacheUtils


NSString * const GCTypeGeocacheTraditionalCache				= @"Geocache|Traditional Cache";
NSString * const GCTypeGeocacheUnknownCache					= @"Geocache|Unknown Cache";
NSString * const GCTypeGeocacheMulticache					= @"Geocache|Multi-cache";
NSString * const GCTypeGeocacheLetterboxHybrid				= @"Geocache|Letterbox Hybrid";
NSString * const GCTypeGeocacheEarthcache					= @"Geocache|Earthcache";
NSString * const GCTypeGeocacheWherigoCache					= @"Geocache|Wherigo Cache";
NSString * const GCTypeGeocacheEventCache					= @"Geocache|Event Cache";
NSString * const GCTypeGeocacheMegaEventCache				= @"Geocache|Mega-Event Cache";
NSString * const GCTypeGeocacheWebcamCache					= @"Geocache|Webcam Cache";
NSString * const GCTypeGeocacheVirtualCache					= @"Geocache|Virtual Cache";
NSString * const GCTypeGeocacheLocationlessReverseCache		= @"Geocache|Locationless (Reverse) Cache";
NSString * const GCTypeGeocacheCacheInTrashOutEvent			= @"Geocache|Cache In Trash Out Event";
NSString * const GCTypeGeocacheProjectAPECache				= @"Geocache|Project APE Cache";
NSString * const GCTypeGeocacheGPSAdventuresExhibit			= @"Geocache|GPS Adventures Exhibit";
NSString * const GCTypeWaypointReferencePoint				= @"Waypoint|Reference Point";
NSString * const GCTypeWaypointStagesofaMulticache			= @"Waypoint|Stages of a Multicache";
NSString * const GCTypeWaypointParkingArea					= @"Waypoint|Parking Area";
NSString * const GCTypeWaypointQuestiontoAnswer				= @"Waypoint|Question to Answer";
NSString * const GCTypeWaypointTrailhead					= @"Waypoint|Trailhead";
NSString * const GCTypeWaypointFinalLocation				= @"Waypoint|Final Location";

NSString* GCTypes[] = {
	@"Geocache|Traditional Cache",
	@"Geocache|Unknown Cache",
	@"Geocache|Multi-cache",
	@"Geocache|Letterbox Hybrid",
	@"Geocache|Earthcache",
	@"Geocache|Wherigo Cache",
	@"Geocache|Event Cache",
	@"Geocache|Mega-Event Cache",
	@"Geocache|Webcam Cache",
	@"Geocache|Virtual Cache",
	@"Geocache|Locationless (Reverse) Cache",
	@"Geocache|Cache In Trash Out Event",
	@"Geocache|Project APE Cache",
	@"Geocache|GPS Adventures Exhibit",
	@"Waypoint|Reference Point",
	@"Waypoint|Stages of a Multicache",
	@"Waypoint|Parking Area",
	@"Waypoint|Question to Answer",
	@"Waypoint|Trailhead",
	@"Waypoint|Final Location"
};

static NSDictionary * GCCacheTypesAsStrings = nil;

+ (void)initialize {
    
    if (GCCacheTypesAsStrings == nil) {
        
        GCCacheTypesAsStrings = [NSDictionary dictionaryWithObjectsAndKeys:
                                 
                                 [NSArray arrayWithObjects:@"T", @"Traditional", nil ], GCTypeGeocacheTraditionalCache ,
                                 [NSArray arrayWithObjects:@"?", @"Mystery", nil ], GCTypeGeocacheUnknownCache     ,
                                 [NSArray arrayWithObjects:@"M", @"Multi", nil ], GCTypeGeocacheMulticache ,
                                 [NSArray arrayWithObjects:@"L", @"Letterbox", nil ], GCTypeGeocacheLetterboxHybrid ,
                                 [NSArray arrayWithObjects:@"E", @"Earth", nil ], GCTypeGeocacheEarthcache ,
                                 [NSArray arrayWithObjects:@"W", @"Wherigo", nil ], GCTypeGeocacheWherigoCache ,
                                 [NSArray arrayWithObjects:@"Ev", @"Event", nil ], GCTypeGeocacheEventCache       ,
                                 [NSArray arrayWithObjects:@"Mv", @"Mega", nil ], GCTypeGeocacheMegaEventCache ,
                                 [NSArray arrayWithObjects:@"C", @"Webcam", nil ], GCTypeGeocacheWebcamCache ,
                                 [NSArray arrayWithObjects:@"V", @"Virtual", nil ], GCTypeGeocacheVirtualCache ,
                                 [NSArray arrayWithObjects:@"R", @"Reverse", nil ], GCTypeGeocacheLocationlessReverseCache ,
                                 [NSArray arrayWithObjects:@"O", @"CITO", nil ], GCTypeGeocacheCacheInTrashOutEvent ,
                                 [NSArray arrayWithObjects:@"A", @"Ape", nil ], GCTypeGeocacheProjectAPECache ,
                                 [NSArray arrayWithObjects:@"X", @"Exhibit", nil ], GCTypeGeocacheGPSAdventuresExhibit ,
                                 
                                 // Waypoints
                                 [NSArray arrayWithObjects:@"R", @"Reference", nil ], GCTypeWaypointReferencePoint ,
                                 [NSArray arrayWithObjects:@"S", @"Stage", nil ], GCTypeWaypointStagesofaMulticache ,
                                 [NSArray arrayWithObjects:@"P", @"Park", nil ], GCTypeWaypointParkingArea ,
                                 [NSArray arrayWithObjects:@"Q", @"Question", nil ], GCTypeWaypointQuestiontoAnswer ,
                                 [NSArray arrayWithObjects:@"T", @"Trailhead", nil ], GCTypeWaypointTrailhead ,
                                 [NSArray arrayWithObjects:@"F", @"Final", nil ], GCTypeWaypointFinalLocation ,
                                 
                                 nil];
        
        
    }
	
}

+ (NSString*) pictogramFromSymbol:(NSString*)sym CacheType:(NSString*)type {
	if ([sym isEqualToString:@"Geocache Found"]) {
		return @":)";
	} else {
        
		if ([GCCacheTypesAsStrings objectForKey:type] != nil) {
            return [[GCCacheTypesAsStrings objectForKey:type] objectAtIndex:0];
        } else {
            return @"";
        }
		
	}
}

+ (NSString*) shortNameFromType:(NSString*)type {
	return [[GCCacheTypesAsStrings objectForKey:type] objectAtIndex:1];
}


+ (NSString*) getGcId:(NSString*)gcName {
    
    
	if ([gcName length] > 2) {
		return [gcName substringFromIndex:2];
	} else {
		return gcName;
	}
    
	
}

+ (NSString*) getGcGuidFromUrl:(NSString*)gcUrl {
	
	
	if ([gcUrl length] > 55) {
		return [gcUrl substringFromIndex:55];
	} else {
		return nil;
	}
	
	
}



@end
