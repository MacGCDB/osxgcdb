//
//  Waypoint.h
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


@interface Waypoint : NSManagedObject

@property (nonatomic, retain) NSString * coordinates;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * id;
@property (nonatomic, retain) NSNumber * lat;
@property (nonatomic, retain) NSNumber * latlonUserModified;
@property (nonatomic, retain) NSNumber * latOrg;
@property (nonatomic, retain) NSNumber * lon;
@property (nonatomic, retain) NSNumber * lonOrg;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * sym;
@property (nonatomic, retain) NSString * symPictogram;
@property (nonatomic, retain) NSDate * time;
@property (nonatomic, retain) NSString * type;
@property (nonatomic, retain) NSDate * updated;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * urlname;

@end
