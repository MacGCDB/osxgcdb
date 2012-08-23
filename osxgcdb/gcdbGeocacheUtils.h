//
//  gcdbGeocacheUtils.h
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

#import <Foundation/Foundation.h>



typedef enum {
	
	gpxGeocacheTraditionalCache,
	gpxGeocacheUnknownCache,
	gpxGeocacheMulticache,
	gpxGeocacheLetterboxHybrid,
	gpxGeocacheEarthcache,
	gpxGeocacheWherigoCache,
	gpxGeocacheEventCache,
	gpxGeocacheMegaEventCache,
	gpxGeocacheWebcamCache,
	gpxGeocacheVirtualCache,
	gpxGeocacheLocationlessReverseCache,
	gpxGeocacheCacheInTrashOutEvent,
	gpxGeocacheProjectAPECache,
	gpxGeocacheGPSAdventuresExhibit,
	gpxWaypointReferencePoint,
	gpxWaypointStagesofaMulticache,
	gpxWaypointParkingArea,
	gpxWaypointQuestiontoAnswer,
	gpxWaypointTrailhead,
	gpxWaypointFinalLocation
	
} GpxType;

extern NSString * const GCTypeGeocacheTraditionalCache ;
extern NSString * const GCTypeGeocacheUnknownCache     ;
extern NSString * const GCTypeGeocacheMulticache ;
extern NSString * const GCTypeGeocacheLetterboxHybrid ;
extern NSString * const GCTypeGeocacheEarthcache ;
extern NSString * const GCTypeGeocacheWherigoCache ;
extern NSString * const GCTypeGeocacheEventCache       ;
extern NSString * const GCTypeGeocacheMegaEventCache ;
extern NSString * const GCTypeGeocacheWebcamCache ;
extern NSString * const GCTypeGeocacheVirtualCache ;
extern NSString * const GCTypeGeocacheLocationlessReverseCache ;
extern NSString * const GCTypeGeocacheCacheInTrashOutEvent ;
extern NSString * const GCTypeGeocacheProjectAPECache ;
extern NSString * const GCTypeGeocacheGPSAdventuresExhibit ;
extern NSString * const GCTypeWaypointReferencePoint ;
extern NSString * const GCTypeWaypointStagesofaMulticache ;
extern NSString * const GCTypeWaypointParkingArea ;
extern NSString * const GCTypeWaypointQuestiontoAnswer ;
extern NSString * const GCTypeWaypointTrailhead ;
extern NSString * const GCTypeWaypointFinalLocation ;

@interface gcdbGeocacheUtils : NSObject {
    
}

+ (NSString*) shortNameFromType:(NSString*)type;

+ (NSString*) pictogramFromSymbol:(NSString*)sym CacheType:(NSString*)type;

+ (NSString*) getGcId:(NSString*)gcName;

+ (NSString*) getGcGuidFromUrl:(NSString*)gcUrl;



@end
