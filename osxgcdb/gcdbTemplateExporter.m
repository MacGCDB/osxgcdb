//
//  gcdbTemplateExporter.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 11-9-12.
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

#import "gcdbTemplateExporter.h"
#import "GRMustache.h"

@implementation gcdbTemplateExporter


+ (void) generateFromTemplate:(NSFetchRequest*)request
					  context:(NSManagedObjectContext*)managedObjectContext
				 waypointType:(NSString*)waypointTypeName
					 delegate:(gcdbAppDelegate*)appDelegate
				   outputPath:(NSString*)gpxOutputPath
				dictionaryKey:(NSString*)keyName
			 compiledTemplate:(GRMustacheTemplate*)template
{
	
	NSArray *fetchedWaypoints = [managedObjectContext executeFetchRequest:request error:nil];
	
	CFIndex hitCount = [fetchedWaypoints count];
	
	if (hitCount != 0) {
        
        //		NSLog(@"Waypoint Type: %@ Count %lu", waypointTypeName, [fetchedWaypoints count]);
		[appDelegate setProgressText:[NSString stringWithFormat:@"Exporting %ld waypoints of type %@...", [fetchedWaypoints count], waypointTypeName]];
		
		NSString* wayFileName = [waypointTypeName stringByAppendingString:@".gpx"];
		
		NSString* gpxTourGuideoutputFile = [gpxOutputPath stringByAppendingPathComponent:wayFileName];
		
		NSDictionary* wayContext = [NSDictionary dictionaryWithObject:fetchedWaypoints
															   forKey:keyName];
		
		NSString* wayMus = [template renderObject:wayContext];
		
		NSData* wayOutputData = [wayMus dataUsingEncoding:NSUTF8StringEncoding];
		
		[[NSFileManager defaultManager] createFileAtPath:gpxTourGuideoutputFile contents:wayOutputData attributes:nil];
		
	}
	
}


/*!
 @method     exportDBbyTemplate
 @abstract   <#(brief description)#>
 @discussion <#(comprehensive description)#>
 */


+ (void) exportDBbyTemplate:(gcdbAppDelegate*)appDelegate {
	
	//***************************************************************
	// Thread block begin
	
	dispatch_async([appDelegate importExportQueue],^{
        
		
		// Start progess indicator in main queue
		dispatch_async(dispatch_get_main_queue(), ^{
			[appDelegate indicateProgressStart:@"Preparing export..."];
		});
		
		
		NSManagedObjectContext *exportContext = [[NSManagedObjectContext alloc] init];
		[exportContext setPersistentStoreCoordinator:[appDelegate persistentStoreCoordinator]];
		
		
		NSString* rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
		NSString* cachePath = [rootPath stringByAppendingPathComponent:@"Geocaches"];
		NSString* templatePath = [cachePath stringByAppendingPathComponent:@"Templates"];
		NSString* outputPath = [cachePath stringByAppendingPathComponent:@"Output"];
		NSString* gpxTourGuideoutputPath = [outputPath stringByAppendingPathComponent:@"TourGuide"];
		NSString* templateFile = [templatePath stringByAppendingPathComponent:@"TourGuideTemplate.mustache"];
		
		
		//NSString* gpxTourGuideoutputFile = nil;
		
		
		if (![[NSFileManager defaultManager] fileExistsAtPath:templateFile]) {
			templateFile = [[NSBundle mainBundle] pathForResource:@"TourGuideTemplate" ofType:@"mustache"];
		}
		
		GRMustacheTemplate* template = [GRMustacheTemplate templateFromContentsOfFile:templateFile error:nil];
		
		
		// Read all cache types in DB:
		
		NSFetchRequest * req = [[NSFetchRequest alloc] init];
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"Details" inManagedObjectContext:exportContext];
		[req setEntity:entity];
		[req setPropertiesToFetch:[NSArray arrayWithObjects:@"groundspeak_type", nil]];
		[req setReturnsDistinctResults:YES];
		[req setResultType:NSDictionaryResultType];
		[req setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"groundspeak_type" ascending:YES]]];
		NSArray* cacheTypes = [exportContext executeFetchRequest:req error:nil];
		
		// Create a file per cache type
		
		NSEntityDescription *cacheEntity = [NSEntityDescription entityForName:@"Cache" inManagedObjectContext:exportContext];
		NSFetchRequest * cachesReq = [[NSFetchRequest alloc] init];
		
		[cachesReq setEntity:cacheEntity];
		
		for (NSDictionary* cacheType in cacheTypes) {
			
			NSString* cacheTypeName = [cacheType objectForKey:@"groundspeak_type"];
			
			NSPredicate *cachePredicate = [NSPredicate predicateWithFormat:@"(relDetails.groundspeak_type == %@ AND sym != 'Geocache Found' AND relDetails.available == 'True')",cacheTypeName];
			[cachesReq setPredicate:cachePredicate];
			
			[self generateFromTemplate:cachesReq
							   context:exportContext
						  waypointType:cacheTypeName
							  delegate:appDelegate
							outputPath:gpxTourGuideoutputPath
						 dictionaryKey:@"Caches"
					  compiledTemplate:template];
			
		}
        
		
		// Add extra request for found caches:
		
		NSPredicate *cachePredicate = [NSPredicate predicateWithFormat:@"(sym = 'Geocache Found')"];
		[cachesReq setPredicate:cachePredicate];
		
		[self generateFromTemplate:cachesReq
						   context:exportContext
					  waypointType:@"Geocache Found"
						  delegate:appDelegate
						outputPath:gpxTourGuideoutputPath
					 dictionaryKey:@"Caches"
				  compiledTemplate:template];
		
		
		[appDelegate setProgressText:[NSString stringWithFormat:@"Exporting waypoints..."]];
		
		
		NSEntityDescription *childEntity = [NSEntityDescription entityForName:@"Childwaypoint" inManagedObjectContext:exportContext];
		[req setEntity:childEntity];
		[req setPropertiesToFetch:[NSArray arrayWithObjects:@"sym", nil]];
		[req setReturnsDistinctResults:YES];
		[req setResultType:NSDictionaryResultType];
		[req setSortDescriptors:[NSArray arrayWithObject:[[NSSortDescriptor alloc] initWithKey:@"sym" ascending:YES]]];
		NSArray * waypointTypes = [exportContext executeFetchRequest:req error:nil];
		
		
		NSFetchRequest * waypointReq = [[NSFetchRequest alloc] init];
		
		[waypointReq setEntity:childEntity];
		
		for (NSDictionary* waypointType in waypointTypes) {
			
			NSString* waypointTypeName = [waypointType objectForKey:@"sym"];
			
			NSPredicate *waypointPredicate = [NSPredicate predicateWithFormat:@"(sym == %@ AND relParent.relDetails.available == 'True')", waypointTypeName];
			[waypointReq setPredicate:waypointPredicate];
			
			
			[self generateFromTemplate:waypointReq
							   context:exportContext
						  waypointType:waypointTypeName
							  delegate:appDelegate
							outputPath:gpxTourGuideoutputPath
						 dictionaryKey:@"Waypoints"
					  compiledTemplate:template];
			
		}
		
		// Stop progess indicator in main queue
		dispatch_async(dispatch_get_main_queue(), ^{
			[appDelegate indicateProgressStop];
		});
        
		
		
	});
	
	//***************************************************************
	// Thread block end
}


@end
