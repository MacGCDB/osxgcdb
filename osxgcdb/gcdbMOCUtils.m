//
//  gcdbMOCUtils.m
//  osxgcdb
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
//

#import "gcdbMOCUtils.h"

#import "GCVote.h"

@implementation gcdbMOCUtils

/*!
 @method     managedObjectFromDB
 @abstract   Gets Managed Object from Core Data, if exists, otherwise initializes new object
 @discussion <#(comprehensive description)#>
 */


+ (NSManagedObject*) managedObjectFromDB:(NSManagedObjectContext*)managedObjectContext
							  entityName:(NSString*)entityName
                         predicateFormat:(NSString*)formatString
						  predicateValue:(NSString*)value {
    
	
	NSManagedObject *newObject = nil;
	
	// Fetch if already exists
	
	NSEntityDescription *entityDescription = [NSEntityDescription
											  entityForName:entityName
											  inManagedObjectContext:managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	[request setEntity:entityDescription];
	
	
	NSPredicate *predicate = [NSPredicate predicateWithFormat:formatString, value];
	[request setPredicate:predicate];
    
	
	NSError *error = nil;
	NSArray *array = [managedObjectContext executeFetchRequest:request error:&error];
    
    
	
	if (array == nil || [array count] == 0)
	{
		
		newObject = [NSEntityDescription
					 insertNewObjectForEntityForName:entityName
					 inManagedObjectContext:managedObjectContext];
		
		//NSLog(@"New %@ object %@: %@",entityName, formatString, value);
		
	} else {
		
		NSUInteger cacheCount = [array count];
		
		for (int i=0; i<cacheCount; i++) {
			
			if (i==0) {
				
				newObject = [array objectAtIndex:i];
				
				//NSLog(@"Updating %@ object with %@ %@",entityName,formatString,value);
				
			} else {
				NSLog(@"+++ Warning: double %@ object entry: %@ %@",entityName,formatString,value);
			}
			
			
		}
	}
	
	return newObject;
	
    
}


/*!
 @method     GDBCDUtils executeStoredFetch
 @abstract   Executes a fetch request which is stored in the data model. Uses a single variable substitution.
 @discussion <#(comprehensive description)#>
 */

+ (NSArray*) executeStoredFetch:(NSManagedObjectContext*)managedObjectContext
				   templateName:(NSString*)templateName
				   variableName:(NSString*)variableName
				  variableValue:(NSString*)variableValue {
    
	NSDictionary *substitutionDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
											variableValue, variableName, nil];
	
	NSFetchRequest *fetchRequest = [[[managedObjectContext persistentStoreCoordinator] managedObjectModel]
									fetchRequestFromTemplateWithName:templateName
									substitutionVariables:substitutionDictionary];
	
	return [managedObjectContext executeFetchRequest:fetchRequest error:nil];
	
}


/*!
 @method     linkVote
 @abstract   Links the provided cache with a GCVote entry
 @discussion <#(comprehensive description)#>
 */


+ (void) linkVote:(NSManagedObjectContext*)managedObjectContext currentCache:(Cache*)curCache {
    
	NSFetchRequest * fetchVote = [[NSFetchRequest alloc] init];
	[fetchVote setEntity:[NSEntityDescription entityForName:@"GCVote" inManagedObjectContext:managedObjectContext]];
	
	NSPredicate *votePredicate = [NSPredicate predicateWithFormat:@"(guid == %@)",[curCache guid]];
	[fetchVote setPredicate:votePredicate];
	
	NSArray *array = [managedObjectContext executeFetchRequest:fetchVote error:nil];
	
	
	if (array == nil  || [array count] == 0)
	{
		
        //		NSLog(@"+++ Warning: no GCVote information for: %@ >%@<",[curCache name], [curCache guid]);
		
	} else {
		
		NSUInteger cacheCount = [array count];
		
		for (int i=0; i<cacheCount; i++) {
			
			GCVote * relVote  = [array objectAtIndex:i];
			
			[curCache setRelVote:relVote];
			
			//NSLog(@"Vote cache %@ avg: %@",[[relVote relCache] name], [relVote VoteAverage]);
			
			if (i!=0) {
				
				NSLog(@"+++ Vote Warning: double cache: %@",[curCache name]);
			}
			
			
		}
	}
	
	
    
}




@end
