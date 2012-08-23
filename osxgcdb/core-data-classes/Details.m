//
//  Details.m
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

#import "Details.h"
#import "Cache.h"
#import "Cachelog.h"
#import "Groundspeak_attributes.h"
#import "Travelbug.h"
#import "Userattributes.h"


@implementation Details

@dynamic archived;
@dynamic available;
@dynamic groundspeak_container;
@dynamic groundspeak_country;
@dynamic groundspeak_difficulty;
@dynamic groundspeak_encoded_hints;
@dynamic groundspeak_long_description;
@dynamic groundspeak_long_description_html;
@dynamic groundspeak_name;
@dynamic groundspeak_owner;
@dynamic groundspeak_owner_id;
@dynamic groundspeak_placed_by;
@dynamic groundspeak_short_description;
@dynamic groundspeak_short_description_html;
@dynamic groundspeak_state;
@dynamic groundspeak_terrain;
@dynamic groundspeak_type;
@dynamic relCache;
@dynamic relGroundspeakAttributes;
@dynamic relLogs;
@dynamic relTravelBugs;
@dynamic relUserAttributes;

@end
