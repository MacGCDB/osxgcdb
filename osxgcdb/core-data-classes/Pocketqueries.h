//
//  Pocketqueries.h
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

@class PQassignment;

@interface Pocketqueries : NSManagedObject

@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSString * pqname;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSSet *relPQassignment;
@end

@interface Pocketqueries (CoreDataGeneratedAccessors)

- (void)addRelPQassignmentObject:(PQassignment *)value;
- (void)removeRelPQassignmentObject:(PQassignment *)value;
- (void)addRelPQassignment:(NSSet *)values;
- (void)removeRelPQassignment:(NSSet *)values;

@end
