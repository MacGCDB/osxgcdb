//
//  gcdbPreferenceController.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 8-9-12.
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

#import "gcdbPreferenceController.h"
#import "gcdbStaticCoordinates.h"

@interface gcdbPreferenceController ()

@end

@implementation gcdbPreferenceController

-(id)init{
    if (![super initWithWindowNibName:@"gcdbPreferenceController"])
        return nil;
	
    return self;
}

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        
        locationManager = [[CLLocationManager alloc] init];
        [locationManager setDelegate:self];
        [locationManager startUpdatingLocation];
        
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    [localLat setStringValue:[NSString stringWithFormat:@"%g", newLocation.coordinate.latitude]];
    [localLon setStringValue:[NSString stringWithFormat:@"%g", newLocation.coordinate.longitude]];
    [locationManager stopUpdatingLocation];
    
}

- (IBAction)getLocalCoordinatesPressed:(id)sender {
    
    NSLog(@"Pressed");
    [[NSUserDefaults standardUserDefaults] setDouble:[localLat doubleValue] forKey:@"homeLat"];
	[[NSUserDefaults standardUserDefaults] setDouble:[localLon doubleValue] forKey:@"homeLon"];
    
    [gcdbStaticCoordinates setDefaultHomeCoordinates];
	
}

@end
