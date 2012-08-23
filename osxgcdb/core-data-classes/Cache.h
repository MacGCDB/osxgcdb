//
//  Cache.h
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
#import "Waypoint.h"

@class Childwaypoint, Details, GCVote, PQassignment;

@interface Cache : Waypoint

@property (nonatomic, retain) NSString * guid;
@property (nonatomic, retain) NSSet *relChild;
@property (nonatomic, retain) Details *relDetails;
@property (nonatomic, retain) NSSet *relPQ;
@property (nonatomic, retain) GCVote *relVote;
@end

@interface Cache (CoreDataGeneratedAccessors)

- (void)addRelChildObject:(Childwaypoint *)value;
- (void)removeRelChildObject:(Childwaypoint *)value;
- (void)addRelChild:(NSSet *)values;
- (void)removeRelChild:(NSSet *)values;

- (void)addRelPQObject:(PQassignment *)value;
- (void)removeRelPQObject:(PQassignment *)value;
- (void)addRelPQ:(NSSet *)values;
- (void)removeRelPQ:(NSSet *)values;

@end
