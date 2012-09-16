//
//  gcdbGCVoteImporter.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 9-9-12.
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

#import "gcdbGCVoteImporter.h"
#import "GCVote.h"
#import "gcdbMOCUtils.h"

@implementation gcdbGCVoteImporter

typedef enum {
	importTypeError,
	importTypeAdded,
	importTypeUpdated
} importType;

NSCharacterSet* csvSeparatorSet;
NSEntityDescription* voteEntityDescription;
NSPredicate *predicateTemplate;


+ (void) importGCVoteCSV:(NSData*)voteData delegate:(gcdbAppDelegate*)appDelegate{
    
 	//***************************************************************
	// Thread block begin
	
    NSManagedObjectContext *parentContext = [appDelegate managedObjectContext];
    
    NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
    
    [importContext setParentContext:parentContext];
    
    [importContext setUndoManager:nil];
    [importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
    
    [importContext performBlock:^{
        
        // Start progess indicator in main queue
        dispatch_async(dispatch_get_main_queue(), ^{
            [appDelegate indicateProgressStart:@"Reading GCVote file..."];
        });
        
        
        //			NSManagedObjectContext *importContext = [[NSManagedObjectContext alloc] init];
        //			[importContext setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
        //			[importContext setUndoManager:nil];
        //			[importContext setMergePolicy:NSMergeByPropertyObjectTrumpMergePolicy];
        //
        //			// Register importContext for notifications:
        //			[[NSNotificationCenter defaultCenter] addObserver:[appDelegate managedObjectContext]
        //													 selector:@selector(mergeChangesFromContextDidSaveNotification:)
        //														 name:NSManagedObjectContextDidSaveNotification
        //													   object:importContext];
        
        
        
        
        NSDate *startDate = [NSDate date];
        
        NSUInteger count = 0, totalCount = 0, LOOP_LIMIT = 100;
        
        if (voteEntityDescription == nil) {
			voteEntityDescription = [NSEntityDescription entityForName:@"GCVote" inManagedObjectContext:importContext];
        }
        
        // Predicate template:
        NSString *predicateString = [NSString stringWithFormat:@"guid == $guid"];
        
        if (predicateTemplate == nil) {
			predicateTemplate = [NSPredicate predicateWithFormat:predicateString];
        }
        
        
        DDLogInfo(@"Step 1: initializing string.");
        
        NSString *csvContents = [[NSString alloc] initWithData:voteData encoding:NSASCIIStringEncoding];
        
        DDLogInfo(@"Step 2: Getting array of lines.");
        
        if (csvSeparatorSet == nil) {
            csvSeparatorSet = [NSCharacterSet characterSetWithCharactersInString:@",\""];
        }
        
        
        
        count = 0; totalCount = 0;
        
        NSUInteger numberOfVotesUpdated = 0, numberOfVotesAdded = 0;
        
        
        
        for (NSString *csvLine  in [csvContents componentsSeparatedByCharactersInSet:
                                    [NSCharacterSet newlineCharacterSet]]) {
            
            @autoreleasepool {
                
                //DDLogInfo(@"Step 3: %@", csvLine);
                //
                
                
                if (totalCount == 0) {  // Make sure we skip the header line
                    DDLogInfo(@"At line one. Skipping...");
                } else {
                    // parseVoteLine
                    importType voteImportedType = [gcdbGCVoteImporter parseVoteLine:csvLine MOCContext:importContext];
                    
                    if (voteImportedType == importTypeUpdated) {
                        numberOfVotesUpdated++;
                    } else if (voteImportedType == importTypeAdded) {
                        numberOfVotesAdded++;
                    }
            }
            
            
            
            count++; totalCount++;
            if (count == LOOP_LIMIT) {
                
                DDLogInfo(@"At vote %lu",totalCount);
                
                [appDelegate setProgressText:[NSString stringWithFormat:@"Processed %ld votes", totalCount]];
                
                // Save this child context:
                NSError *error = nil;
                [importContext save:&error];
                
                // Save the main context, after saving the child:
                [parentContext performBlock:^{
                    NSError *parentError = nil;
                    [parentContext save:&parentError];
                }];
                
                [importContext reset];
                
                count = 0;
                
            }
            
        }
        
    }
     
     
     DDLogInfo(@"Step 4: Added votes: %lu added, %lu updated.", numberOfVotesAdded, numberOfVotesUpdated);
     
     
     
     
     
     if (count != 0) {
         
         // Save this child context:
         NSError *error = nil;
         [importContext save:&error];
         
         // Save the main context, after saving the child:
         [parentContext performBlock:^{
             NSError *parentError = nil;
             [parentContext save:&parentError];
         }];
         
         //                    dispatch_group_t main_group_end = dispatch_group_create();
         //
         //                    dispatch_group_async(main_group_end, dispatch_get_main_queue(), ^{
         //
         //                        [[appDelegate persistentStoreCoordinator] lock];
         //
         //                        [importContext processPendingChanges];
         //
         //                        [importContext save:nil];
         //
         //                        [[appDelegate persistentStoreCoordinator] unlock];
         //
         //                    });
         //
         //                    dispatch_group_wait(main_group_end, DISPATCH_TIME_FOREVER);
         //
         [importContext reset];
         
     }
     
     
     
     
     DDLogInfo(@"Added: %lu votes",totalCount);
     DDLogInfo(@"-- time: %f", [startDate timeIntervalSinceNow]);
     
     // Add relations to caches
     
     @autoreleasepool {
         
         
         NSFetchRequest * fetchCaches = [[NSFetchRequest alloc] init];
         [fetchCaches setEntity:[NSEntityDescription entityForName:@"Cache" inManagedObjectContext:importContext]];
         NSArray * allCaches = [importContext executeFetchRequest:fetchCaches error:nil];
         
         NSFetchRequest * fetchVote = [[NSFetchRequest alloc] init];
         [fetchVote setEntity:voteEntityDescription];
         
         
         for (Cache * curCache in allCaches) {
             
             [gcdbMOCUtils linkVote:importContext currentCache:curCache];
             
         }
         
         DDLogInfo(@"Finished scanning caches");
         DDLogInfo(@"Scanned: %lu caches",[allCaches count]);
         DDLogInfo(@"-- time: %f", [startDate timeIntervalSinceNow]);
         
         // Save this child context:
         NSError *error = nil;
         [importContext save:&error];
         
         // Save the main context, after saving the child:
         [parentContext performBlock:^{
             NSError *parentError = nil;
             [parentContext save:&parentError];
         }];
         
         //                dispatch_group_t main_group_caches = dispatch_group_create();
         //
         //                dispatch_group_async(main_group_caches, dispatch_get_main_queue(), ^{
         //
         //
         //                    [[appDelegate persistentStoreCoordinator] lock];
         //
         //                    [importContext processPendingChanges];
         //
         //                    [importContext save:nil];
         //
         //                    [[appDelegate persistentStoreCoordinator] unlock];
         //
         //                });
         //
         //                dispatch_group_wait(main_group_caches, DISPATCH_TIME_FOREVER);
         //
         [importContext reset];
         
         
         NSString* notificationDescription = [NSString stringWithFormat:@"Added: %ld votes. %ld were new.",totalCount, numberOfVotesAdded];
         
         NSUserNotification *notification = [[NSUserNotification alloc] init];
         [notification setTitle:@"GCVote Database Import Finished"];
         [notification setInformativeText:notificationDescription];
         
         NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
         [center deliverNotification:notification];
         
         
         // Stop progess indicator in main queue
         dispatch_async(dispatch_get_main_queue(), ^{
             [appDelegate indicateProgressStop];
         });
         
     }
     
     
     
     }];
	
	//***************************************************************
	// Thread block end
    
}


//----------------------------------------------------

+ (importType) parseVoteLine:(NSString*)voteLine MOCContext:(NSManagedObjectContext*)importContext {
    
    importType returnValue = importTypeError;
    
    NSArray* csvComponents = [voteLine componentsSeparatedByCharactersInSet:csvSeparatorSet];
    
    if ([csvComponents count] > 3) { // Check that line is valid
        
        NSMutableString *voteDistribution = [@"" mutableCopy];
        
        
        // Reconcatenate split distribution files
        for (int i = 4; i < [csvComponents count]; i++) {
            if ([(NSString *)[csvComponents objectAtIndex:i] length] != 0) {
                
                if (i > 5) {
                    [voteDistribution appendString:@","];
                }
                
                [voteDistribution appendString:[csvComponents objectAtIndex:i]];
                
            }
        }
        
        
        GCVote* newVote;
        
        // Fetch if already exists
        
        NSFetchRequest * fetch = [[NSFetchRequest alloc] init];
        [fetch setEntity:voteEntityDescription];
        
        NSDictionary *variables = [NSDictionary dictionaryWithObject:(NSString*)[csvComponents objectAtIndex:0]
                                                              forKey:@"guid"];
        NSPredicate *votePredicate = [predicateTemplate predicateWithSubstitutionVariables:variables];
        
        [fetch setPredicate:votePredicate];
        [fetch setIncludesPropertyValues:NO];
        NSArray * array = [importContext executeFetchRequest:fetch error:nil];
        
        if (array == nil || [array count] == 0)
        {
            
            newVote = [NSEntityDescription
                       insertNewObjectForEntityForName:@"GCVote"
                       inManagedObjectContext:importContext];
            
            returnValue = importTypeAdded;
            
            
            //DDLogInfo(@"New vote %@",[csvComponents objectAtIndex:0]);
            
        } else {
            
            NSUInteger voteCount = [array count];
            
            newVote = [array objectAtIndex:0];
            
            returnValue = importTypeUpdated;
            
            
            if (voteCount > 1) {
                DDLogInfo(@"+++ Warning: double entry: %@",[csvComponents objectAtIndex:0]);
            }
        }
        
        [newVote setGuid:[csvComponents objectAtIndex:0]];
        [newVote setCount:[NSNumber numberWithInt:[[csvComponents objectAtIndex:1] intValue]]];
        [newVote setVoteAverage:[NSNumber numberWithDouble:[[csvComponents objectAtIndex:2] doubleValue]]];
        [newVote setVoteMedian:[NSNumber numberWithDouble:[[csvComponents  objectAtIndex:3] doubleValue]]];
        [newVote setDistribution:voteDistribution];
        
    }
    
    return returnValue;
    
    
}

@end
