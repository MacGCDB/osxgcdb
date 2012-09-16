//
//  Userattributes+categories.h
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 1-9-12.
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


#import "Userattributes.h"

@interface Userattributes (categories)

@property (nonatomic, retain) NSNumber *redUserFlag;

@property (nonatomic, retain) NSString *redUserFlagString;

@end
