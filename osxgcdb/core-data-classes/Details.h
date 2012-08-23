//
//  Details.h
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 9-8-12.
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

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Cache, Cachelog, Groundspeak_attributes, Travelbug, Userattributes;

@interface Details : NSManagedObject

@property (nonatomic, retain) NSString * archived;
@property (nonatomic, retain) NSString * available;
@property (nonatomic, retain) NSString * groundspeak_container;
@property (nonatomic, retain) NSString * groundspeak_country;
@property (nonatomic, retain) NSNumber * groundspeak_difficulty;
@property (nonatomic, retain) NSString * groundspeak_encoded_hints;
@property (nonatomic, retain) NSString * groundspeak_long_description;
@property (nonatomic, retain) NSString * groundspeak_long_description_html;
@property (nonatomic, retain) NSString * groundspeak_name;
@property (nonatomic, retain) NSString * groundspeak_owner;
@property (nonatomic, retain) NSString * groundspeak_owner_id;
@property (nonatomic, retain) NSString * groundspeak_placed_by;
@property (nonatomic, retain) NSString * groundspeak_short_description;
@property (nonatomic, retain) NSString * groundspeak_short_description_html;
@property (nonatomic, retain) NSString * groundspeak_state;
@property (nonatomic, retain) NSNumber * groundspeak_terrain;
@property (nonatomic, retain) NSString * groundspeak_type;
@property (nonatomic, retain) Cache *relCache;
@property (nonatomic, retain) NSSet *relGroundspeakAttributes;
@property (nonatomic, retain) NSSet *relLogs;
@property (nonatomic, retain) NSSet *relTravelBugs;
@property (nonatomic, retain) Userattributes *relUserAttributes;
@end

@interface Details (CoreDataGeneratedAccessors)

- (void)addRelGroundspeakAttributesObject:(Groundspeak_attributes *)value;
- (void)removeRelGroundspeakAttributesObject:(Groundspeak_attributes *)value;
- (void)addRelGroundspeakAttributes:(NSSet *)values;
- (void)removeRelGroundspeakAttributes:(NSSet *)values;

- (void)addRelLogsObject:(Cachelog *)value;
- (void)removeRelLogsObject:(Cachelog *)value;
- (void)addRelLogs:(NSSet *)values;
- (void)removeRelLogs:(NSSet *)values;

- (void)addRelTravelBugsObject:(Travelbug *)value;
- (void)removeRelTravelBugsObject:(Travelbug *)value;
- (void)addRelTravelBugs:(NSSet *)values;
- (void)removeRelTravelBugs:(NSSet *)values;

@end
