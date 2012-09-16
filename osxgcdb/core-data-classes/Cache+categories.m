//
//  Cache+categories.m
//  osxgcdb
//
//  Created by MacGCDB (macgcdb@googlemail.com) on 25-8-12.
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

#import "Cache+categories.h"
#import "Details.h"
#import "GCVote.h"
#import "gcdbXMLUtils.h"

@implementation Cache (categories)



- (NSAttributedString*) nameLinkAttStr {
	
	NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:[self name]];
	NSURL* url = [NSURL URLWithString:[self url]];
	
	
	NSRange range = NSMakeRange(0, [attrString length]);
 	
    
	[attrString beginEditing];
	[attrString addAttribute:NSLinkAttributeName value:[url absoluteString] range:range];
 	
    
	if ([[[self relDetails] valueForKey:@"available"] isEqualToString:@"False"]) {
		
		[attrString addAttribute:NSForegroundColorAttributeName
                           value:[NSColor redColor]
                           range:range];
		
		[attrString addAttribute:NSStrikethroughStyleAttributeName
                           value:[NSNumber numberWithInt:NSSingleUnderlineStyle]
                           range:range];
        
	} else {
		// make the text appear in blue
		[attrString addAttribute:NSForegroundColorAttributeName
						   value:[NSColor blueColor]
						   range:range];
	}
	
	// next make the text appear with an underline
	[attrString addAttribute:NSUnderlineStyleAttributeName
					   value:[NSNumber numberWithInt:NSSingleUnderlineStyle]
					   range:range];
	
    // Doesn't work:
    	[attrString addAttribute:NSCursorAttributeName
    					   value:[NSCursor pointingHandCursor]
    					   range:range];
	
	NSMutableParagraphStyle *aMutableParagraphStyle = [[NSParagraphStyle defaultParagraphStyle]mutableCopy];
	
	[aMutableParagraphStyle setAlignment:NSRightTextAlignment];
    
 	[attrString addAttribute:NSParagraphStyleAttributeName
					   value:aMutableParagraphStyle
					   range:range];
	
	
	[attrString endEditing];
	
 	
	return attrString;
    
}

- (void) setNameLinkAttStr:(NSAttributedString*)input {
	
}


- (NSAttributedString*) descriptionAttStr {
	
	
	
	if ([[[self relDetails] valueForKey:@"groundspeak_long_description_html"] isEqualToString:@"False"]) {
        
        NSString *contents = [NSString stringWithFormat:@"%@\n\n%@", [[self relDetails] valueForKey:@"groundspeak_short_description"],[[self relDetails] valueForKey:@"groundspeak_long_description"]];
        
        DDLogVerbose(@"Before initWithString");
        
		
		NSMutableAttributedString* string = [[NSMutableAttributedString alloc]
											 initWithString:contents];
        
        DDLogVerbose(@"After initWithString");
		
		return string;
        
	} else {
        
        NSMutableString *body = [NSMutableString stringWithFormat:@"<html><head><style>body {font-family:Arial;}</style></head><body>%@<br><br>%@</body></html>", [[self relDetails] valueForKey:@"groundspeak_short_description"],[[self relDetails] valueForKey:@"groundspeak_long_description"]];
        
        // Filter out images: initWithHTML is too slow otherwise
        NSError *error = NULL;
        NSRegularExpression *regexIMG = [NSRegularExpression regularExpressionWithPattern:@"<img[^>]*>" options:0 error:&error];
        
        [regexIMG replaceMatchesInString:body
                                 options:0
                                   range:NSMakeRange(0,[body length])
                            withTemplate:@"&nbsp;"];
        
//        NSDictionary *docOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithFloat:0.5] forKey:NSTimeoutDocumentOption];
		
        DDLogVerbose(@"Before initWithHTML");
        
		NSAttributedString *htmlString = [[NSAttributedString alloc]
                                          initWithHTML:[body dataUsingEncoding:[body fastestEncoding]]
                                          options:nil
                                          documentAttributes:NULL];
        
        
        
//        NSString *body = [NSString stringWithFormat:@"%@\n\n%@", [[self relDetails] valueForKey:@"groundspeak_short_description"],[[self relDetails] valueForKey:@"groundspeak_long_description"]];
//        
//        NSAttributedString *htmlString = [[NSMutableAttributedString alloc]
//         initWithString:[gcdbXMLUtils HTML2Text:body]];
        
        DDLogVerbose(@"After initWithHTML");

        
		return htmlString;
	}
	
	
	
}


- (void) setDescriptionAttStr:(NSAttributedString*)input {
	
}

- (NSString*) htmlDescription {
	
	NSMutableString *contents = [@"" mutableCopy];
	
	if ([[self relDetails] valueForKey:@"groundspeak_short_description"] != nil) {
        
        [contents appendString:@"<html><head><title>Cache Details</title><style>body {font-family:Arial;}</style></head><body>"];
		
		[contents appendString:[[self relDetails] valueForKey:@"groundspeak_short_description"]];
		
		if ([contents length] != 0) {
			[contents appendString:@"<br><br>"];
		}
		
	}
	
	if ([[self relDetails] valueForKey:@"groundspeak_long_description"] != nil) {
		
		[contents appendString:[[self relDetails] valueForKey:@"groundspeak_long_description"]];
		
		if ([[[self relDetails] valueForKey:@"groundspeak_long_description_html"] isEqualToString:@"False"]) {
			
			[contents replaceOccurrencesOfString:@"\n" withString:@"<br>" options:0 range:NSMakeRange(0, [contents length])];
		}
		
	}
    
    [contents appendString:@"</body></html>"];
    
	return contents;
	
	
}

- (void) setHtmlDescription:(NSString*)input {
	
}


- (BOOL) isNotFound {
    
	if ([[self sym] isEqualToString:@"Geocache Found"]) {
		return NO;
	} else {
		return YES;
	}
	
}

- (void) setIsNotFound:(BOOL)input {
	
}

- (BOOL) isAvailable {
	
	if ([[[self relDetails] valueForKey:@"available"] isEqualToString:@"False"]) {
		return NO;
	} else {
		return YES;
	}
	
}

- (void) setIsAvailable:(BOOL)input {
	
}

- (NSString*) smartName {
	
	return [NSString stringWithFormat:@"%@ %@ %@/%@ %@ %@ - %.1f/%@",
			[self id],
			[self symPictogram],
			[[self relDetails] groundspeak_difficulty],
			[[self relDetails] groundspeak_terrain],
			[[[self relDetails] groundspeak_container] substringToIndex:1],
			[[self relDetails] groundspeak_name],
			[[[self relVote] voteAverage] floatValue],
			[[self relVote] count]
			];
    
}

- (void) setSmartName:(NSString*)input {
    
	
}

@end
