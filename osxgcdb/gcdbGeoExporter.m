//
//  gcdbGeoExporter.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 15-9-12.
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

#import "gcdbGeoExporter.h"

#import "Cache.h"
#import "Cache+categories.h"
#import "Childwaypoint.h"

#import "GRMustache.h"

@implementation gcdbGeoExporter

+ (NSURL*)exportGPX:(NSArray*)selectedCaches outputDirectory:(NSURL*)outDir {
	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSError *error = nil;
	
    NSURL *url = [outDir URLByAppendingPathComponent:@"GeoCacheLibrary-export.gpx"];
    
//	NSURL *url = [NSURL fileURLWithPath:[outDir stringByAppendingPathComponent: @"GeoCacheLibrary-export.gpx"]];
	
	//	<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	//  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
	// version="1.0"
	// creator="Groundspeak, Inc. All Rights Reserved. http://www.groundspeak.com"
	// xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0/1 http://www.groundspeak.com/cache/1/0/1/cache.xsd"
	// xmlns="http://www.topografix.com/GPX/1/0">
	
	
	NSXMLElement* pqRoot = [[NSXMLElement alloc] initWithName:@"gpx"];
	
	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsd" stringValue:@"http://www.w3.org/2001/XMLSchema"]];
	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1.0"]];
	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"creator" stringValue:@"Mac GCDB"]];
	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0/1 http://www.groundspeak.com/cache/1/0/1/cache.xsd"]];
	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.topografix.com/GPX/1/0"]];
	
	NSXMLElement* element = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"Mac GCDB GPX file"];
	[pqRoot addChild:element];
	
	element = [[NSXMLElement alloc] initWithName:@"desc" stringValue:@"GPX export file produced by Mac GCDB"];
	[pqRoot addChild:element];
	
	
	NSDate *currentDate = [NSDate date];
	NSString *currentDateString = [currentDate descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ"
																	timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]
																	  locale:nil];
	
	element = [[NSXMLElement alloc] initWithName:@"time" stringValue:currentDateString];
	[pqRoot addChild:element];
	
	
	// Loop over selected caches
	
	
	//NSArray *selectedWaypoints = [Caches selectedObjects];
	
	for (Cache *cacheWpt in selectedCaches) {
		
		NSXMLElement* wptXML = [[NSXMLElement alloc] initWithName:@"wpt"];
		[wptXML addAttribute:[NSXMLNode attributeWithName:@"lat" stringValue:[[cacheWpt lat] stringValue]]];
		[wptXML addAttribute:[NSXMLNode attributeWithName:@"lon" stringValue:[[cacheWpt lon] stringValue]]];
		
		element = [[NSXMLElement alloc] initWithName:@"time" stringValue:currentDateString];
		[wptXML addChild:element];
		
		element = [[NSXMLElement alloc] initWithName:@"name" stringValue:[cacheWpt smartName]];
		[wptXML addChild:element];
		
		// use description as cmt for older devices:
		element = [[NSXMLElement alloc] initWithName:@"cmt" stringValue:[cacheWpt desc]];
		[wptXML addChild:element];
		
		element = [[NSXMLElement alloc] initWithName:@"desc" stringValue:[cacheWpt desc]];
		[wptXML addChild:element];
		
		element = [[NSXMLElement alloc] initWithName:@"sym" stringValue:[cacheWpt sym]];
		[wptXML addChild:element];
		
		[pqRoot addChild:wptXML];
		
		
		for (Childwaypoint * childWpt in [cacheWpt relChild]) {
			
			wptXML = [[NSXMLElement alloc] initWithName:@"wpt"];
			[wptXML addAttribute:[NSXMLNode attributeWithName:@"lat" stringValue:[[childWpt lat] stringValue]]];
			[wptXML addAttribute:[NSXMLNode attributeWithName:@"lon" stringValue:[[childWpt lon] stringValue]]];
			
			element = [[NSXMLElement alloc] initWithName:@"time" stringValue:currentDateString];
			[wptXML addChild:element];
			
			element = [[NSXMLElement alloc] initWithName:@"name" stringValue:[NSString stringWithFormat:@"%@ %@", [childWpt name], [childWpt desc]]];
			[wptXML addChild:element];
			
			element = [[NSXMLElement alloc] initWithName:@"cmt" stringValue:[childWpt desc]];
			[wptXML addChild:element];
			
			element = [[NSXMLElement alloc] initWithName:@"desc" stringValue:[childWpt desc]];
			[wptXML addChild:element];
			
			element = [[NSXMLElement alloc] initWithName:@"sym" stringValue:[childWpt sym]];
			[wptXML addChild:element];
			
			
			
			[pqRoot addChild:wptXML];
			
		}
		
	}
	
	// Create document object with XML tree:
	
	id xmlDoc = [[NSXMLDocument alloc] initWithRootElement:pqRoot];
	
	[xmlDoc setVersion:@"1.0"];
	[xmlDoc setCharacterEncoding:@"utf-8"];
	
	
	NSData* xmlData = [xmlDoc XMLData];
	
	[fileManager createFileAtPath:[url path] contents:xmlData attributes:nil];
	
	//[xmlData release];
	
	NSLog(@"Finished file writing phase of export.");
	
	
	return url;
	
}

/*!
 @method
 @abstract   <#(brief description)#>
 @discussion <#(comprehensive description)#>
 */

+ (NSURL*)exportKML:(NSArray*)selectedCaches outputDirectory:(NSURL*)outDir {
	
	
	NSFileManager *fileManager = [NSFileManager defaultManager];
    //NSError *error = nil;
    
    
    NSString* rootPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* cachePath = [rootPath stringByAppendingPathComponent:@"Geocaches"];
    NSString* templatePath = [cachePath stringByAppendingPathComponent:@"Templates"];
    //NSString* outputPath = [cachePath stringByAppendingPathComponent:@"Output"];
    //NSString* gpxTourGuideoutputPath = [outputPath stringByAppendingPathComponent:@"TourGuide"];
    NSString* templateFile = [templatePath stringByAppendingPathComponent:@"KMLTemplate.mustache"];
    
    
    //NSString* gpxTourGuideoutputFile = nil;
    
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:templateFile]) {
        templateFile = [[NSBundle mainBundle] pathForResource:@"KMLTemplate" ofType:@"mustache"];
    }
    
    GRMustacheTemplate* template = [GRMustacheTemplate templateFromContentsOfFile:templateFile error:nil];
    
	
	NSURL *url = [outDir URLByAppendingPathComponent: @"GeoCacheLibrary-export.kml"];
    
    
    NSDictionary* cacheDict = [NSDictionary dictionaryWithObject:selectedCaches
                                                          forKey:@"Caches"];
    
    NSString* kml = [template renderObject:cacheDict];
    
    NSData* kmlOutputData = [kml dataUsingEncoding:NSUTF8StringEncoding];
    
    [fileManager createFileAtPath:[url path] contents:kmlOutputData attributes:nil];
    
    //
    //	//	<gpx xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    //	//  xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    //	// version="1.0"
    //	// creator="Groundspeak, Inc. All Rights Reserved. http://www.groundspeak.com"
    //	// xsi:schemaLocation="http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0/1 http://www.groundspeak.com/cache/1/0/1/cache.xsd"
    //	// xmlns="http://www.topografix.com/GPX/1/0">
    //
    //
    //	NSXMLElement* pqRoot = [[NSXMLElement alloc] initWithName:@"kml"];
    //
    ////	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsi" stringValue:@"http://www.w3.org/2001/XMLSchema-instance"]];
    ////	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xmlns:xsd" stringValue:@"http://www.w3.org/2001/XMLSchema"]];
    ////	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"version" stringValue:@"1.0"]];
    ////	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"creator" stringValue:@"Mac GCDB"]];
    ////	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xsi:schemaLocation" stringValue:@"http://www.topografix.com/GPX/1/0 http://www.topografix.com/GPX/1/0/gpx.xsd http://www.groundspeak.com/cache/1/0/1 http://www.groundspeak.com/cache/1/0/1/cache.xsd"]];
    //	[pqRoot addAttribute:[NSXMLNode attributeWithName:@"xmlns" stringValue:@"http://www.opengis.net/kml/2.2"]];
    //
    //	NSXMLElement* element = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"Mac GCDB KML file"];
    //	[pqRoot addChild:element];
    //	[element release];
    //
    //	element = [[NSXMLElement alloc] initWithName:@"desc" stringValue:@"KML export file produced by Mac GCDB"];
    //	[pqRoot addChild:element];
    //	[element release];
    //
    //
    //	NSDate *currentDate = [NSDate date];
    //	NSString *currentDateString = [currentDate descriptionWithCalendarFormat:@"%Y-%m-%dT%H:%M:%SZ"
    //																	timeZone:[NSTimeZone timeZoneWithAbbreviation:@"UTC"]
    //																	  locale:nil];
    //
    //	element = [[NSXMLElement alloc] initWithName:@"time" stringValue:currentDateString];
    //	[pqRoot addChild:element];
    //	[element release];
    //
    //
    //    NSXMLElement* kmlFolder = [[NSXMLElement alloc] initWithName:@"Folder"];
    //
    //    element = [[NSXMLElement alloc] initWithName:@"name" stringValue:@"Mac GCDB Waypoints"];
    //	[kmlFolder addChild:element];
    //	[element release];
    //
    //	element = [[NSXMLElement alloc] initWithName:@"desc" stringValue:@"Waypoints produced by Mac GCDB"];
    //	[kmlFolder addChild:element];
    //	[element release];
    //
    //
    //
    //	// Loop over selected caches
    //
    //
    //	//NSArray *selectedWaypoints = [Caches selectedObjects];
    //
    //	for (cache *cacheWpt in selectedCaches) {
    //
    //		NSXMLElement* wptXML = [[NSXMLElement alloc] initWithName:@"Placemark"];
    //
    //
    //        element = [[NSXMLElement alloc] initWithName:@"name" stringValue:[cacheWpt smartName]];
    //        [wptXML addChild:element];
    //        [element release];
    //
    ////		[wptXML addAttribute:[NSXMLNode attributeWithName:@"lat" stringValue:[[cacheWpt lat] stringValue]]];
    ////		[wptXML addAttribute:[NSXMLNode attributeWithName:@"lon" stringValue:[[cacheWpt lon] stringValue]]];
    //
    //		NSXMLElement* point = [[NSXMLElement alloc] initWithName:@"Point"];
    //
    //
    //
    //
    //
    //		NSXMLElement* coordinates = [[NSXMLElement alloc] initWithName:@"coordinates"
    //											 stringValue:[NSString stringWithFormat:@"%@,%@,0",[cacheWpt lon],[cacheWpt lat]]];
    //		[point addChild:coordinates];
    //		[coordinates release];
    //
    //		[wptXML addChild:point];
    //		[point release];
    //
    //
    //
    //
    ////		element = [[NSXMLElement alloc] initWithName:@"time" stringValue:currentDateString];
    ////		[wptXML addChild:element];
    ////		[element release];
    ////
    ////		element = [[NSXMLElement alloc] initWithName:@"name" stringValue:[cacheWpt smartName]];
    ////		[wptXML addChild:element];
    ////		[element release];
    ////
    ////		// use description as cmt for older devices:
    ////		element = [[NSXMLElement alloc] initWithName:@"cmt" stringValue:[cacheWpt desc]];
    ////		[wptXML addChild:element];
    ////		[element release];
    ////
    ////		element = [[NSXMLElement alloc] initWithName:@"desc" stringValue:[cacheWpt desc]];
    ////		[wptXML addChild:element];
    ////		[element release];
    ////
    ////		element = [[NSXMLElement alloc] initWithName:@"sym" stringValue:[cacheWpt sym]];
    ////		[wptXML addChild:element];
    ////		[element release];
    //
    //		[kmlFolder addChild:wptXML];
    //
    //		[wptXML release];
    //
    ////		for (childwaypoint * childWpt in [cacheWpt relChild]) {
    ////
    ////			wptXML = [[NSXMLElement alloc] initWithName:@"wpt"];
    ////			[wptXML addAttribute:[NSXMLNode attributeWithName:@"lat" stringValue:[[childWpt lat] stringValue]]];
    ////			[wptXML addAttribute:[NSXMLNode attributeWithName:@"lon" stringValue:[[childWpt lon] stringValue]]];
    ////
    ////			element = [[NSXMLElement alloc] initWithName:@"time" stringValue:currentDateString];
    ////			[wptXML addChild:element];
    ////			[element release];
    ////
    ////			element = [[NSXMLElement alloc] initWithName:@"name" stringValue:[NSString stringWithFormat:@"%@ %@", [childWpt name], [childWpt desc]]];
    ////			[wptXML addChild:element];
    ////			[element release];
    ////
    ////			element = [[NSXMLElement alloc] initWithName:@"cmt" stringValue:[childWpt desc]];
    ////			[wptXML addChild:element];
    ////			[element release];
    ////
    ////			element = [[NSXMLElement alloc] initWithName:@"desc" stringValue:[childWpt desc]];
    ////			[wptXML addChild:element];
    ////			[element release];
    ////
    ////			element = [[NSXMLElement alloc] initWithName:@"sym" stringValue:[childWpt sym]];
    ////			[wptXML addChild:element];
    ////			[element release];
    ////
    ////
    ////
    ////			[pqRoot addChild:wptXML];
    ////
    ////			[wptXML release];
    ////		}
    //
    //	}
    //    
    //    
    //    [pqRoot addChild:kmlFolder];
    //    [kmlFolder release];
    //	
    //	// Create document object with XML tree:
    //	
    //	id xmlDoc = [[NSXMLDocument alloc] initWithRootElement:pqRoot];
    //	
    //	[xmlDoc setVersion:@"1.0"];
    //	[xmlDoc setCharacterEncoding:@"utf-8"];
    //	
    //	
    //	NSData* xmlData = [xmlDoc XMLData];
    //	
    //	//[fileManager createFileAtPath:[url path] contents:xmlData attributes:nil];
    //	
    //	[pqRoot release];
    //	[xmlDoc release];
	//[xmlData release];
	
	NSLog(@"Finished file writing phase of export.");
	
	
	return url;
	
}

@end
