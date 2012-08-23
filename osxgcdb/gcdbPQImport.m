//
//  gcdbPQImport.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 11-8-12.
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

#import "gcdbPQImport.h"

#import "SSZipArchive.h"
#import "gcdbXMLUtils.h"
#import "gcdbMOCUtils.h"
#import "gcdbGeocacheUtils.h"

#import "Waypoint.h"
#import "Cache.h"
#import "Details.h"
#import "Pocketqueries.h"
#import "Groundspeak_attributes.h"
#import "Cachelog.h"
#import "PQassignment.h"
#import "Childwaypoint.h"


NSString* const wayPointGPXName = @"Waypoints for Cache Listings Generated from Geocaching.com";


@implementation gcdbPQImport

+ (void) importPqFiles:(NSArray*)fileNames appDelegate:(gcdbAppDelegate*)delegate{

    //***************************************************************
	// Thread block begin
		
    NSManagedObjectContext *parentContext = [delegate managedObjectContext];
    
    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [importContext setParentContext:parentContext];
    
    [importContext setUndoManager:nil];
    [importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    [importContext performBlock:^{
        
        for (NSURL *aFile in fileNames) {
            
            NSLog(@"Filename is %@",aFile);
            
            if ([aFile pathExtension] && [[aFile pathExtension] caseInsensitiveCompare:@"zip"] == NSOrderedSame) {
                
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSURL *applicationSupportDirectory = [delegate applicationFilesDirectory];
                
                NSString* guid = [[NSProcessInfo processInfo] globallyUniqueString];
                
                NSURL *url = [applicationSupportDirectory URLByAppendingPathComponent:guid];
                
                
                [fileManager createDirectoryAtPath:[url path] withIntermediateDirectories:YES attributes:nil error:nil];
                
                NSString* filePath = [aFile path];
                
                [SSZipArchive unzipFileAtPath:filePath toDestination:[url path]];
                
                NSArray* unzippedFiles = [fileManager contentsOfDirectoryAtURL:url
                                                    includingPropertiesForKeys:[NSArray arrayWithObject:NSURLNameKey]
                                                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                                                         error:nil];
                
                
                NSSortDescriptor *pathDescriptor =
                [[NSSortDescriptor alloc] initWithKey:@"path"
                                            ascending:NO
                                             selector:@selector(localizedCaseInsensitiveCompare:)];
                
                
                NSArray* sortedUnzippedFiles = [unzippedFiles sortedArrayUsingDescriptors:[NSArray arrayWithObjects:pathDescriptor, nil]];
                
                
                for (NSURL* decompressedFile in sortedUnzippedFiles) {
                    
                    NSLog(@"Unzipped file: %@", decompressedFile);
                    
                    [gcdbPQImport pqProcess:decompressedFile
                               managedModel:[delegate managedObjectModel]
                                appDelegate:delegate
                              importContext:importContext];
                    
                    // Save this child context:
                    NSError *error = nil;
                    [importContext save:&error];
                    
                    DDLogInfo(@"In child performBlock");
                    
                    // Save the main context, after saving the child:
                    [parentContext performBlock:^{
                        NSError *parentError = nil;
                        [parentContext save:&parentError];
                        DDLogInfo(@"In parent performBlock");
                    }];
                    
                    [fileManager removeItemAtURL:decompressedFile error:nil];
                    
                }
                
                
                [fileManager removeItemAtURL:url error:nil];
                
                
                
                
            } else {
                
                [gcdbPQImport pqProcess:aFile
                           managedModel:[delegate managedObjectModel]
                            appDelegate:delegate
                          importContext:importContext];
                
                
                // Save this child context:
                NSError *error = nil;
                [importContext save:&error];
                
                DDLogInfo(@"In child performBlock");
                
                // Save the main context, after saving the child:
                [parentContext performBlock:^{
                    NSError *parentError = nil;
                    [parentContext save:&parentError];
                    DDLogInfo(@"In parent performBlock");
                }];
                
            }
            
            

            
        }
        
    }];
	
	//***************************************************************
	// Thread block end
    
}

//------------------------------------------------------------------------------------


+ (void) pqProcess:(NSURL*)fileURL
      managedModel:(NSManagedObjectModel*)managedObjectModel
       appDelegate:(gcdbAppDelegate*)delegate
     importContext:(NSManagedObjectContext*)importContext
{
    
    @autoreleasepool {

        id xmlDoc = [[NSXMLDocument alloc] initWithContentsOfURL:fileURL options:0 error:nil];
        
        NSXMLElement* pqRoot = [xmlDoc rootElement];
        
        NSString* pqName = [gcdbXMLUtils singleValue:@"name" xmlElement:pqRoot];
        NSString* pqTime = [gcdbXMLUtils singleValue:@"time" xmlElement:pqRoot];
        NSString* pqFileName = [fileURL lastPathComponent];
        NSString* pqFileBaseName = [pqFileName stringByDeletingPathExtension];
        
        NSScanner* pqScanner = [NSScanner scannerWithString:pqFileBaseName];
        NSString* pqID = nil;
        
        BOOL foundNumbers = [pqScanner scanCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:&pqID];
        
        if (!foundNumbers || [pqID isEmpty] || [pqID length] < 7) {
            pqID = pqFileBaseName;
        }
        
        BOOL isAdditionalWaypointsFile = [pqFileBaseName hasSuffix:@"-wpts"];
        
        
        NSDate* pqTimestamp = [gcdbXMLUtils dateWithMicrosecondsFromXML:pqTime];
        
        
        NSLog(@"Processing PQ: %@ ID: %@ Time: %@",pqName, pqID, pqTime);
        
        // Message to UI:
        //[appDelegate setProgressText:[NSString stringWithFormat:@"Processing PQ: %@", pqName]];
        
        // Get object for pocket query
        
        Pocketqueries* pqEntity = nil;
        
        
        if (!isAdditionalWaypointsFile) {
            
            pqEntity = (Pocketqueries*)[gcdbMOCUtils managedObjectFromDB:importContext
                                                            entityName:@"Pocketqueries"
                                                       predicateFormat:@"(id == %@)"
                                                        predicateValue:pqID];
            
            [pqEntity setId:pqID];
            [pqEntity setPqname:pqName];
            
            if ([pqEntity updated] == nil || [[pqEntity updated] compare:pqTimestamp] == NSOrderedAscending ) {
                
                NSLog(@"Updating pocket query. Timestamp is newer. DB: %@ PQ: %@", [pqEntity updated], pqTimestamp);
                [pqEntity setUpdated:pqTimestamp];
                
            } else {
                NSLog(@"-- Not updating pocket query. Timestamp is older. DB: %@ PQ: %@", [pqEntity updated], pqTimestamp);
            }
            
            
        }
        
        
        
        // Add caches/child waypoints
        
        NSArray* childWPT = [pqRoot elementsForName:@"wpt"];
        
        NSUInteger wptCount = [childWPT count];
        
        for (int i=0; i<wptCount; i++) {
            
            
            NSXMLElement *xmlWpt = [childWPT objectAtIndex:i];
            Waypoint *newWaypoint;
            NSString *waypointType = [gcdbXMLUtils singleValue:@"type" xmlElement:xmlWpt];
            NSString *entityName;
            NSString *waypointName = [gcdbXMLUtils singleValue:@"name" xmlElement:xmlWpt];
            
            BOOL isCache;
            
            // Is this a child waypoint or a main Cache?
            if ([waypointType hasPrefix:@"Waypoint"]) {
                entityName = @"Childwaypoint";
                isCache = NO;
                
            } else {
                entityName  = @"Cache";
                isCache = YES;
            }
            
            // See if the Cache is already stored in the DB:
            NSArray *array = [gcdbMOCUtils executeStoredFetch:importContext
                                                 templateName:@"fetchWaypoint"
                                                 variableName:@"WAYPOINTNAME"
                                                variableValue:waypointName];
            
            
            if (array == nil || [array count] == 0)
            {
                // Create a new waypoint, if it is not already in the DB:
                newWaypoint = [NSEntityDescription
                               insertNewObjectForEntityForName:entityName
                               inManagedObjectContext:importContext];
                
                DDLogVerbose(@"New %@: %@",entityName,waypointName);
                
            } else {
                
                NSUInteger cacheCount = [array count];
                
                for (int i=0; i<cacheCount; i++) {
                    
                    if (i==0) {
                        // There should only be one entry in the DB for the Waypoint:
                        newWaypoint = [array objectAtIndex:i];
                        
                        DDLogVerbose(@"Updating %@: %@",entityName,waypointName);
                        
                    } else {
                        DDLogError(@"+++ Warning: double %@ entry: %@",entityName,waypointName);
                    }
                    
                    
                }
            }
            
            
            // Check if waypoint needs to be updated (ignore imports of older pocket queries:
            
            BOOL needsUpdate;
            
            if ([(Waypoint*)newWaypoint updated] == nil ||
                [[(Waypoint*)newWaypoint updated] compare:pqTimestamp] == NSOrderedAscending) {
                
                DDLogVerbose(@"To update: Waypoint: %@  Query %@:", [(Waypoint*)newWaypoint updated], pqTimestamp);
                
                needsUpdate = YES;
                
                NSString *waypointURL = [gcdbXMLUtils singleValue:@"url" xmlElement:xmlWpt];
                
                [newWaypoint setValue:[gcdbGeocacheUtils getGcId:waypointName] forKey:@"id"];
                [newWaypoint setValue:waypointName forKey:@"name"];
                [newWaypoint setValue:[gcdbXMLUtils attributeDouble:@"lat" xmlElement:xmlWpt] forKey:@"lat"];
                [newWaypoint setValue:[gcdbXMLUtils attributeDouble:@"lat" xmlElement:xmlWpt] forKey:@"latOrg"];
                [newWaypoint setValue:[gcdbXMLUtils attributeDouble:@"lon" xmlElement:xmlWpt] forKey:@"lon"];
                [newWaypoint setValue:[gcdbXMLUtils attributeDouble:@"lon" xmlElement:xmlWpt] forKey:@"lonOrg"];
                [newWaypoint setValue:[gcdbXMLUtils singleDate:@"time" xmlElement:xmlWpt] forKey:@"time"];
                [newWaypoint setValue:[gcdbXMLUtils singleValue:@"desc" xmlElement:xmlWpt] forKey:@"desc"];
                [newWaypoint setValue:waypointURL forKey:@"url"];
                [newWaypoint setValue:[gcdbXMLUtils singleValue:@"urlname" xmlElement:xmlWpt] forKey:@"urlname"];
                [newWaypoint setValue:[gcdbXMLUtils singleValue:@"sym" xmlElement:xmlWpt] forKey:@"sym"];
                [newWaypoint setValue:[gcdbXMLUtils singleValue:@"type" xmlElement:xmlWpt] forKey:@"type"];
                
                [newWaypoint setValue:pqTimestamp forKey:@"updated"];
                
                
                if (isCache) {
                    
                    // **** Begin cache specific code
                    
                    [newWaypoint setValue:[gcdbGeocacheUtils getGcGuidFromUrl:waypointURL] forKey:@"guid"];
                    
                    Details *newDetails = nil;
                    
                    if ([(Cache*)newWaypoint relDetails] != nil) {
                        newDetails = [(Cache*)newWaypoint relDetails];
                    } else {
                        
                        newDetails = [NSEntityDescription
                                      insertNewObjectForEntityForName:@"Details"
                                      inManagedObjectContext:importContext];
                        
                    }
                    
                    NSArray* groundspeakExt = [xmlWpt elementsForName:@"groundspeak:cache"];
                    
                    NSUInteger gsCount = [groundspeakExt count];
                    
                    if (gsCount == 1) {
                        
                        NSXMLElement* gsWpt = [groundspeakExt objectAtIndex:0];
                    
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:container" xmlElement:gsWpt] forKey:@"groundspeak_container"];
                        [newDetails setValue:[NSNumber numberWithFloat:[[gcdbXMLUtils singleValue:@"groundspeak:difficulty" xmlElement:gsWpt] floatValue]] forKey:@"groundspeak_difficulty"];
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:name" xmlElement:gsWpt] forKey:@"groundspeak_name"];
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:type" xmlElement:gsWpt] forKey:@"groundspeak_type"];
                        [newDetails setGroundspeak_terrain:[NSNumber numberWithFloat:[[gcdbXMLUtils singleValue:@"groundspeak:terrain" xmlElement:gsWpt] floatValue]]];
                        
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:country" xmlElement:gsWpt] forKey:@"groundspeak_country"];
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:state" xmlElement:gsWpt] forKey:@"groundspeak_state"];
                        [newDetails setValue:[gcdbXMLUtils attributeValue:@"available" xmlElement:gsWpt] forKey:@"available"];
                        [newDetails setValue:[gcdbXMLUtils attributeValue:@"archived" xmlElement:gsWpt] forKey:@"archived"];
                        
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:placed_by" xmlElement:gsWpt] forKey:@"groundspeak_placed_by"];
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:owner" xmlElement:gsWpt] forKey:@"groundspeak_owner"];
                        [newDetails setValue:[gcdbXMLUtils singleElementAttributeValue:@"id" elementKey:@"groundspeak:owner" xmlElement:gsWpt] forKey:@"groundspeak_owner_id"];
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:short_description" xmlElement:gsWpt] forKey:@"groundspeak_short_description"];
                         [newDetails setValue:[gcdbXMLUtils singleElementAttributeValue:@"html"
                                                                            elementKey:@"groundspeak:short_description"
                                                                            xmlElement:gsWpt] forKey:@"groundspeak_short_description_html"];
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:long_description" xmlElement:gsWpt] forKey:@"groundspeak_long_description"];
                         [newDetails setValue:[gcdbXMLUtils singleElementAttributeValue:@"html"
																			elementKey:@"groundspeak:long_description"
																			xmlElement:gsWpt] forKey:@"groundspeak_long_description_html"];
                        [newDetails setValue:[gcdbXMLUtils singleValue:@"groundspeak:encoded_hints" xmlElement:gsWpt] forKey:@"groundspeak_encoded_hints"];
                        
                        
                        
                        // Add groundspeak:attributes
                        
                        BOOL firstAttribute = YES;
                        firstAttribute = YES;
                        
                        for (NSXMLElement* xmlGSAttributes in [gsWpt elementsForName:@"groundspeak:attributes"]) {
                            
                            // There should only be one set of attributes per cache
                            
                            // Delete existing attributes to ensure that obsolete attributes are removed:
                            if (firstAttribute == YES) {
                                firstAttribute = NO;
                                
                                for (Groundspeak_attributes* oldAttribute in [newDetails relGroundspeakAttributes]) {
                                    [importContext deleteObject:oldAttribute];
                                }
                                
                                
                            }
                            
                            for (NSXMLElement* xmlGSAttribute in [xmlGSAttributes elementsForName:@"groundspeak:attribute"]) {
                                
                                DDLogVerbose(@"Attribute: %@, %@: %@", [gcdbXMLUtils attributeValue:@"id" xmlElement:xmlGSAttribute],
                                             [gcdbXMLUtils attributeValue:@"inc" xmlElement:xmlGSAttribute],
                                             [xmlGSAttribute stringValue]);
                                
                                Groundspeak_attributes* newAttribute = nil;
                                
                                newAttribute = [NSEntityDescription
                                                insertNewObjectForEntityForName:@"Groundspeak_attributes"
                                                inManagedObjectContext:importContext];
                                
                                
                                [newAttribute setGroundspeak_attribute_id:[gcdbXMLUtils attributeValue:@"id" xmlElement:xmlGSAttribute]];
                                [newAttribute setGroundspeak_attribute_inc:[NSNumber numberWithLong:[[gcdbXMLUtils attributeValue:@"inc" xmlElement:xmlGSAttribute] longLongValue]]];
                                [newAttribute setGroundspeak_attribute:[xmlGSAttribute stringValue]];
                                
                                [newDetails addRelGroundspeakAttributesObject:newAttribute];
                                
                            }
                        }
                        
                        for (NSXMLElement* xmlLogs in [gsWpt elementsForName:@"groundspeak:logs"]) {
                            
                            for (NSXMLElement* xmlLogEntry in [xmlLogs elementsForName:@"groundspeak:log"]) {
                                
                                
                                NSString* logId = [gcdbXMLUtils attributeValue:@"id" xmlElement:xmlLogEntry];
                                
                                Cachelog* newLog = nil;
                                
                                // Look for existing log:
                                NSArray *logArray = [gcdbMOCUtils executeStoredFetch:importContext
                                                                      templateName:@"fetchLogById"
                                                                      variableName:@"LOG_ID"
                                                                     variableValue:logId];
                                
                                
                                if (logArray == nil || [logArray count] == 0)
                                {
                                    
                                    newLog = [NSEntityDescription
                                              insertNewObjectForEntityForName:@"Cachelog"
                                              inManagedObjectContext:importContext];
                                    
                                    DDLogVerbose(@"New log %@", logId);
                                    
                                    [newLog setGroundspeak_log_id:logId];
                                    [newLog setGroundspeak_date:[gcdbXMLUtils singleDate:@"groundspeak:date" xmlElement:xmlLogEntry]];
                                    
                                    [newLog setGroundspeak_type:[gcdbXMLUtils singleValue:@"groundspeak:type" xmlElement:xmlLogEntry]];
                                    [newLog setGroundspeak_finder:[gcdbXMLUtils singleValue:@"groundspeak:finder" xmlElement:xmlLogEntry]];
                                    [newLog setGroundspeak_finder_id:[gcdbXMLUtils singleElementAttributeValue:@"id" elementKey:@"groundspeak:finder" xmlElement:xmlLogEntry]];
                                    [newLog setGroundspeak_text:[gcdbXMLUtils singleValue:@"groundspeak:text" xmlElement:xmlLogEntry]];
                                    [newLog setGroundspeak_text_encoded:[gcdbXMLUtils singleElementAttributeValue:@"encoded" elementKey:@"groundspeak:text" xmlElement:xmlLogEntry]];
                                    
                                    [newLog setRelDetails:newDetails];		
                                    
                                } else {
                                    
                                    NSUInteger logCount = [logArray count];
                                    
                                    for (int i=0; i<logCount; i++) {
                                        
                                        if (i==0) {
                                            
                                            newLog = [logArray objectAtIndex:i];
                                            
                                            DDLogVerbose(@"Found existing log %@: %@",[newLog groundspeak_log_id],[newLog groundspeak_finder]);
                                            
                                        } else {
                                            DDLogWarn(@"+++ Warning: double log entry: %@ %@",[[logArray objectAtIndex:i]  groundspeak_log_id],
                                                  [[logArray objectAtIndex:i] groundspeak_finder]);
                                        }
                                        
                                        
                                    }
                                }				
                                
                            }
                            
                            
                        }
                        
                        
                        
                    }
                    
                    
                    // Add gcvote information
                    
                    if ([(Cache*)newWaypoint relVote] != nil) {
                        DDLogVerbose(@"Vote relation exists. Skipping");
                    } else {
                        
                        DDLogVerbose(@"Finding Vote relation...");
                        [gcdbMOCUtils linkVote:importContext currentCache:(Cache*)newWaypoint];
                        
                    }
                    
                    // Maintain details relation
                    
                    if ([(Cache*)newWaypoint relDetails] == nil) {
                        [(Cache*)newWaypoint setRelDetails:newDetails];
                    }
                    
                    
                    // Find or add user attributes
                    
                    if ((Details*)[[(Cache*)newWaypoint relDetails] relUserAttributes] != nil) {
                        DDLogVerbose(@"User attributes relation exists. Skipping");
                    } else {
                        
                        // See if a disembodied user attributes entity exists in DB
                        
                        Userattributes* newUserAttributes = nil;
                        
                        NSArray *userAttributesArray = [gcdbMOCUtils executeStoredFetch:importContext
                                                                         templateName:@"fetchUserAttributesForName"
                                                                         variableName:@"WAYPOINT_NAME"
                                                                        variableValue:waypointName];
                        
                        if (userAttributesArray == nil || [userAttributesArray count] == 0)
                        {
                            
                            newUserAttributes = [NSEntityDescription
                                                 insertNewObjectForEntityForName:@"Userattributes"
                                                 inManagedObjectContext:importContext];
                            
                        } else {
                            newUserAttributes = [userAttributesArray objectAtIndex:1];
                        }
                        
                        [[(Cache*)newWaypoint relDetails] setRelUserAttributes:newUserAttributes];
                        
                    }
                    
                    // Maintain Pocket Query relationship
                    
                    BOOL foundPqRelation = NO;
                    
                    for (PQassignment* assignedPQ in [(Cache*)newWaypoint relPQ]) {
                        
                        if ([[assignedPQ id] isEqualToString:[pqEntity id]]) {
                            foundPqRelation = YES;
                            DDLogVerbose(@"Pocket query relationship exists, not updating: %@ %@", [[assignedPQ relCache] name], [[assignedPQ relPocketquery] pqname] );
                        }
                        
                    }
                    
                    if (!foundPqRelation) {
                        
                        PQassignment* pqRelation = [NSEntityDescription
                                                    insertNewObjectForEntityForName:@"PQassignment"
                                                    inManagedObjectContext:importContext];
                        
                        [pqRelation setId:[pqEntity id]];
                        [pqRelation setName:[(Cache*)newWaypoint name]];
                        [pqRelation setRelCache:(Cache*)newWaypoint];
                        [pqRelation setRelPocketquery:pqEntity];
                        
                        DDLogVerbose(@"Added pocket query relationship: %@ %@", [[pqRelation relCache] name], [[pqRelation relPocketquery] pqname] );
                        
                    }
                    

                    
                    // **** End of cache specific code
                    
                } else {
                    // **** Begin child waypoint specific code
                    
                    [newWaypoint setValue:[gcdbXMLUtils singleValue:@"cmt" xmlElement:xmlWpt] forKey:@"cmt"];
                    
                    if ([(Childwaypoint*)newWaypoint relParent] != nil) {
                        DDLogVerbose(@"Parent relation exists. Not updating");
                    } else {
                        
                        
                        NSEntityDescription *entityDescription = [NSEntityDescription
                                                                  entityForName:@"Cache" inManagedObjectContext:importContext];
                        
                        NSFetchRequest *request = [[NSFetchRequest alloc] init];
                        [request setEntity:entityDescription];
                        
                        
                        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"(id == %@)",[newWaypoint id]];
                        [request setPredicate:predicate];
                        
                        
                        NSError *error = nil;
                        NSArray *array = [importContext executeFetchRequest:request error:&error];
                        if (array == nil  || [array count] == 0)
                        {
                            // No parent found.
                            // Todo: keep list of orphans?
                            
                            DDLogWarn(@"+++ Warning: orphan child: %@",[newWaypoint name]);
                            
                        } else {
                            
                            NSUInteger cacheCount = [array count];
                            
                            for (int i=0; i<cacheCount; i++) {
                                
                                Cache *parentCache = [array objectAtIndex:i];
                                
                                [parentCache addRelChildObject:(Childwaypoint*)newWaypoint];
                                
                                DDLogVerbose(@"Parent  %@ child: %@",[[(Childwaypoint*)newWaypoint relParent] name], [newWaypoint name]);
                                
                                if (i!=0) {
                                    DDLogWarn(@"+++ Warning: double cache: %@",[parentCache name]);
                                }
                                
                                
                            }
                        }
                        
                        
                    }
                    
                    // **** End of child waypoint specific code
                }

                
                
            } else {
                DDLogVerbose(@"Already updated. Waypoint: %@ Query: %@", [(Waypoint*)newWaypoint updated], pqTimestamp);
                needsUpdate = NO;
            }
            
            

// ???? Check if needed:
//            [newWaypoint setUpdated:updated];
            
            
            
            
//            [appDelegate setProgressText:[NSString stringWithFormat:@"Processing PQ: %@  %d of %d wayponts.", pqName, i + 1, wptCount]];
            
        }
        
        
        NSString* pqTextDescription;
        
        if ([pqName isEqualToString:wayPointGPXName]) {
            pqTextDescription = @"Additional waypoints file";
        } else {
            pqTextDescription = pqName;   
        }
        
        
        
        NSString* pqDateString = [pqTimestamp description];
        
        NSString* notificationTitle = [NSString stringWithFormat:@"%@ Imported", pqFileName];
        
        NSString* notificationDescription = [NSString stringWithFormat:@"%@\n%ld waypoints processed.\nPocket query timestamp: %@",pqTextDescription, wptCount, pqDateString];
        
        
        NSUserNotification *notification = [[NSUserNotification alloc] init];
        [notification setTitle:notificationTitle];
        //                [notification setActionButtonTitle:@"Yes"];
        //                [notification setHasActionButton:YES];
        [notification setInformativeText:notificationDescription];
        
        NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
        //                [center setDelegate:delegate];
        [center deliverNotification:notification];

        
// ???? Check if needed:        
//        [importContext reset];
        
        
    }
    
}

@end
