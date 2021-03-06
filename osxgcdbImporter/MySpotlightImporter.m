//
//  MySpotlightImporter.m
//  osxgcdbImporter
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


#import "MySpotlightImporter.h"

#import "Cache.h"
#import "Details.h"

#define YOUR_STORE_TYPE NSSQLiteStoreType

@interface MySpotlightImporter ()
@property (nonatomic, strong) NSURL *modelURL;
@property (nonatomic, strong) NSURL *storeURL;
@end

@implementation MySpotlightImporter

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

- (BOOL)importFileAtPath:(NSString *)filePath attributes:(NSMutableDictionary *)spotlightData error:(NSError **)error
{

    NSLog(@"importFileAtPath");
    
    NSDictionary *pathInfo = [NSPersistentStoreCoordinator elementsDerivedFromExternalRecordURL:[NSURL fileURLWithPath:filePath]];
            
    self.modelURL = [NSURL fileURLWithPath:[pathInfo valueForKey:NSModelPathKey]];
    self.storeURL = [NSURL fileURLWithPath:[pathInfo valueForKey:NSStorePathKey]];


    NSURL *objectURI = [pathInfo valueForKey:NSObjectURIKey];
    NSManagedObjectID *oid = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];

    if (!oid) {
        NSLog(@"%@:%@ to find object id from path %@", [self class], NSStringFromSelector(_cmd), filePath);
        return NO;
    }

    NSManagedObject *instance = [[self managedObjectContext] objectWithID:oid];

    // how you process each instance will depend on the entity that the instance belongs to

    if ([[[instance entity] name] isEqualToString:@"Cache"]) {
        
        
        
        

        // set the display name for Spotlight search result

        //NSString *yourDisplayString =  [NSString stringWithFormat:@"YOUR_DISPLAY_STRING %@", [instance valueForKey:@"SOME_KEY"]];
        
        Details *cacheDetails = [instance valueForKey:@"relDetails"];
        
        NSString *cacheName = [cacheDetails groundspeak_name];
        
        NSString *yourDisplayString =  [NSString stringWithFormat:@"GC%@ %@",[instance valueForKey:@"id"], cacheName];
        
        NSLog(@"Cache display name 2 %@", yourDisplayString);
        
        
        spotlightData[(NSString *)kMDItemDisplayName] = yourDisplayString;
        
         /*
            Determine how you want to store the instance information in 'spotlightData' dictionary.
            For each property, pick the key kMDItem... from MDItem.h that best fits its content.  
            If appropriate, aggregate the values of multiple properties before setting them in the dictionary.
            For relationships, you may want to flatten values. 

            id YOUR_FIELD_VALUE = [instance valueForKey:ATTRIBUTE_NAME];
            spotlightData[(NSString *) kMDItem...] = YOUR_FIELD_VALUE;
            ... more property values;
            To determine if a property should be indexed, call isIndexedBySpotlight
         */
        
        
        NSString *longDescription =  [cacheDetails groundspeak_long_description];
        
        [spotlightData setObject:longDescription forKey:(NSString *)kMDItemTextContent];
        
        NSLog(@"Finished.");
        
    }

    return YES;
}

static NSURL				*cachedModelURL = nil;
static NSManagedObjectModel *cachedModel = nil;
static NSDate				*cachedModelModificationDate =nil;

// Returns the managed object model. The last read model is cached in a global variable and reused if the URL and modification date are identical
- (NSManagedObjectModel *)managedObjectModel
{
    NSLog(@"NSManagedObjectModel");

    
    if (_managedObjectModel != nil)
        return _managedObjectModel;
	
	NSDictionary *modelFileAttributes = [[NSFileManager defaultManager] attributesOfItemAtPath:[self.modelURL path] error:nil];
	NSDate *modelModificationDate =  modelFileAttributes[NSFileModificationDate];
	
	if ([cachedModelURL isEqual:self.modelURL] && [modelModificationDate isEqualToDate:cachedModelModificationDate]) {
		_managedObjectModel = cachedModel;
	} 	
	
	if (!_managedObjectModel) {
		_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:self.modelURL];

		if (!_managedObjectModel) {
			NSLog(@"%@:%@ unable to load model at URL %@", [self class], NSStringFromSelector(_cmd), self.modelURL);
			return nil;
		}

		// Clear out all custom classes used by the model to avoid having to link them
		// with the importer. Remove this code if you need to access your custom logic.
		NSString *managedObjectClassName = [NSManagedObject className];
		for (NSEntityDescription *entity in _managedObjectModel) {
			[entity setManagedObjectClassName:managedObjectClassName];
		}
		
		// cache last loaded model

		cachedModelURL = self.modelURL;
		cachedModel = _managedObjectModel;
		cachedModelModificationDate = modelModificationDate;
	}
	
	return _managedObjectModel;
}

// Returns the persistent store coordinator for the importer.  
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator)
        return _persistentStoreCoordinator;

    NSError *error = nil;
        
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:YOUR_STORE_TYPE configuration:nil URL:self.storeURL options:nil error:&error]) {
        NSLog(@"%@:%@ unable to add persistent store coordinator - %@", [self class], NSStringFromSelector(_cmd), error);
    }    

    return _persistentStoreCoordinator;
}

// Returns the managed object context for the importer; already bound to the persistent store coordinator. 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext)
        return _managedObjectContext;

    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
	if (!coordinator) {
        NSLog(@"%@:%@ unable to get persistent store coordinator", [self class], NSStringFromSelector(_cmd));
		return nil;
	}

	_managedObjectContext = [[NSManagedObjectContext alloc] init];
	[_managedObjectContext setPersistentStoreCoordinator:coordinator];
    
    return _managedObjectContext;
}

@end
