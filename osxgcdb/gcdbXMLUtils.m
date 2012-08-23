//
//  gcdbXMLUtils.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 12-8-12.
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

#import "gcdbXMLUtils.h"


static 	NSDateFormatter * dateFormatter = nil;
static 	NSDateFormatter * dateFormatterMicroseconds = nil;

@implementation gcdbXMLUtils


/*!
 @method     dateFromXML
 @abstract   Returns NSDate object from XML timestamp (without microseconds)
 @discussion Example date format: 2006-09-14T07:00:00Z  2011-01-16T08:00:00Z
 */

+ (NSDate*) dateFromXML:(NSString*)xmlDate {
    
	if (!dateFormatter) {
		dateFormatter = [NSDateFormatter new];
		[dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
	}
	
	// The 'Z' replacement hack is necessary for Apple's date format limitations:
	NSDate* dateObject = [dateFormatter dateFromString:[xmlDate stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"]];
	
	if (dateObject == nil) {
		dateObject = [self dateWithMicrosecondsFromXML:xmlDate];
	}
	
	//NSLog(@"Date from XML: %@ for %@", dateObject, xmlDate);
	
	return dateObject;
	
}


/*!
 @method     dateWithMicrosecondsFromXML
 @abstract   Returns NSDate object from XML timestamp (with microseconds)
 @discussion Example date format: 2011-05-17T18:25:53.5755757Z
 */

+ (NSDate*) dateWithMicrosecondsFromXML:(NSString*)xmlDate {
	
	if (!dateFormatterMicroseconds) {
		dateFormatterMicroseconds = [NSDateFormatter new];
		[dateFormatterMicroseconds setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSSSSSZ"];
	}
	
	//NSDate* dateObject = [dateFormatterMicroseconds dateFromString:[xmlDate stringByReplacingOccurrencesOfString:@"Z" withString:@"-0000"]];
	
	// Do this so that dates without 'Z' at the end are also treated as UTC:
	NSDate* dateObject = [dateFormatterMicroseconds
						  dateFromString:[[xmlDate
										   stringByReplacingOccurrencesOfString:@"Z"
										   withString:@""] stringByAppendingString:@"-000"]];
	
	//NSLog(@"Date from microseconds XML: %@", dateObject);
	
	return dateObject;
	
}

+ (NSDate*) singleDate:(NSString *)name xmlElement:(NSXMLElement *)element {
	
	NSString * stringValue = [self singleValue:name xmlElement:element];
	
	return [self dateFromXML:stringValue];
	
}


+ (NSNumber*) singleNumber:(NSString *)name xmlElement:(NSXMLElement *)element {
	
	NSString * stringValue = [self singleValue:name xmlElement:element];
	
	return [NSNumber numberWithDouble:[stringValue doubleValue]];
}


+ (NSString*) singleValue:(NSString *)name xmlElement:(NSXMLElement *)element {
	
	NSString* value;
	NSArray* elements = [element elementsForName:name];
	
	NSUInteger elementCount = [elements count];
	
	if (elementCount != 0) {
		
		value = [[elements objectAtIndex:0] stringValue];
		
		if (elementCount > 1) {
			NSLog(@"??? Warning: More than one name found for %@.", name);
		}
		
	} else {
		value = nil;
	}
	
	return value;
    
}

+ (NSString*) singleElementAttributeValue:(NSString *)attributeName elementKey:(NSString*)elementName xmlElement:(NSXMLElement *)element {
	
	NSString* value;
	NSArray* elements = [element elementsForName:elementName];
	
	NSUInteger elementCount = [elements count];
	
	if (elementCount != 0) {
		
		value = [self attributeValue:attributeName xmlElement:[elements objectAtIndex:0]];
		
		if (elementCount > 1) {
			NSLog(@"??? Warning: More than one name found for %@.", elementName);
		}
		
	} else {
		value = nil;
	}
	
	return value;
	
}


+ (NSString*) attributeValue:(NSString *)attributeName xmlElement:(NSXMLElement *)element {
	
	return [[element attributeForName:attributeName] stringValue];
	
}

+ (NSNumber*) attributeDouble:(NSString *)attributeName xmlElement:(NSXMLElement *)element {
    
	NSString* attributeValue = [[element attributeForName:attributeName] stringValue];
	
	return [NSNumber numberWithDouble:[attributeValue doubleValue]];
	
}

+ (bool) attributeBoolean:(NSString *)attributeName xmlElement:(NSXMLElement *)element {
	
	NSString* attributeValue = [[element attributeForName:attributeName] stringValue];
	
	if ([attributeValue isEqualToString:@"True"]) {
		return YES;
	} else {
		return NO;
	}
	
}


@end
