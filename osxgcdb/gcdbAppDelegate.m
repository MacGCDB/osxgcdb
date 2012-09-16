//
//  gcdbAppDelegate.m
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

#import "gcdbAppDelegate.h"

#import "SSZipArchive.h"

#import "gcdbCacheFoundImageTransformer.h"
#import "gcdbPQImport.h"
#import "Cache.h"
#import "Cache+categories.h"
#import "Details.h"
#import "Cachelog.h"
#import "gcdbPreferenceController.h"
#import "gcdbStaticCoordinates.h"
#import "gcdbGCVoteImporter.h"
#import "gcdbTemplateExporter.h"
#import "gcdbGeoExporter.h"

#define YOUR_STORE_TYPE NSSQLiteStoreType
#define YOUR_EXTERNAL_RECORD_EXTENSION @"geocacherec"

//static const int ddLogLevel = LOG_LEVEL_INFO; //LOG_LEVEL_VERBOSE

@implementation gcdbAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize cacheTableView;
@synthesize logsTableView;
@synthesize webViewDetails;
@synthesize cachePopover;
@synthesize togglePopoverButton;

@synthesize progressLabel;
@synthesize progressIndicator;

@synthesize window;


static dispatch_queue_t importExportQueue;


gcdbPreferenceController *preferenceController;

- (dispatch_queue_t)importExportQueue {
	
	if (!importExportQueue) {
		importExportQueue = dispatch_queue_create("com.osxgcdb.importexportqueue", 0);
	}
	
	return importExportQueue;
	
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [gcdbStaticCoordinates setDefaultHomeCoordinates];
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
    
    DDLogInfo(@"Initialized logger.");
    
    DDLogInfo(@"log file at: %@", [[fileLogger currentLogFileInfo] filePath]);

    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center setDelegate:self];
    
    NSString *homeDir = NSHomeDirectory();
    
    DDLogVerbose(@"Homedir %@",homeDir);
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
   DDLogVerbose(@"didDeliverNotification."); 
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    DDLogVerbose(@"didActivateNotification.");
}


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    DDLogVerbose(@"shouldPresentNotification");
    return YES;
}



/**
 Returns the external records directory for the application.
 This code uses a directory named "osxgcdb" for the content,
 either in the ~/Library/Caches/Metadata/CoreData location or (if the
 former cannot be found), the system's temporary directory.
 */

- (NSString *)externalRecordsDirectory {
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : NSTemporaryDirectory();
    return [basePath stringByAppendingPathComponent:@"Metadata/CoreData/osxgcdb"];
}

// Returns the directory the application uses to store the Core Data store file. This code uses a directory named "com.dangermankonsumprodukte.osxgcdb" in the user's Application Support directory.
- (NSURL *)applicationFilesDirectory
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *appSupportURL = [[fileManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask] lastObject];
    return [appSupportURL URLByAppendingPathComponent:@"com.dangermankonsumprodukte.osxgcdb"];
}

// Creates if necessary and returns the managed object model for the application.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel) {
        return _managedObjectModel;
    }
	
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"osxgcdb" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. (The directory for the store is created, if necessary.)
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator) {
        return _persistentStoreCoordinator;
    }
    
    NSManagedObjectModel *mom = [self managedObjectModel];
    if (!mom) {
        NSLog(@"%@:%@ No model to generate a store from", [self class], NSStringFromSelector(_cmd));
        return nil;
    }
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSURL *applicationFilesDirectory = [self applicationFilesDirectory];
    NSError *error = nil;
    
    NSDictionary *properties = [applicationFilesDirectory resourceValuesForKeys:@[NSURLIsDirectoryKey] error:&error];
    
    if (!properties) {
        BOOL ok = NO;
        if ([error code] == NSFileReadNoSuchFileError) {
            ok = [fileManager createDirectoryAtPath:[applicationFilesDirectory path] withIntermediateDirectories:YES attributes:nil error:&error];
        }
        if (!ok) {
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    } else {
        if (![properties[NSURLIsDirectoryKey] boolValue]) {
            // Customize and localize this error.
            NSString *failureDescription = [NSString stringWithFormat:@"Expected a folder to store application data, found a file (%@).", [applicationFilesDirectory path]];
            
            NSMutableDictionary *dict = [NSMutableDictionary dictionary];
            [dict setValue:failureDescription forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:101 userInfo:dict];
            
            [[NSApplication sharedApplication] presentError:error];
            return nil;
        }
    }
    
    NSString *externalRecordsDirectory = [self externalRecordsDirectory];
    if ( ![fileManager fileExistsAtPath:externalRecordsDirectory isDirectory:NULL] ) {
        if (![fileManager createDirectoryAtPath:externalRecordsDirectory withIntermediateDirectories:YES attributes:nil error:&error]) {
            DDLogError(@"Error creating external records directory at %@ : %@",externalRecordsDirectory,error);
            NSAssert2(NO, @"Failed to create external records directory %@ : %@", externalRecordsDirectory,error);
            DDLogError(@"Error creating external records directory at %@ : %@",externalRecordsDirectory,error);
            return nil;
        };
    }
    
    NSURL *url = [applicationFilesDirectory URLByAppendingPathComponent:@"geocaches.osxgcdb"];
    
    DDLogInfo(@"Persistent store: %@",  url);
    
    NSMutableDictionary *storeOptions = [NSMutableDictionary dictionary];
    [storeOptions setObject:externalRecordsDirectory forKey:NSExternalRecordsDirectoryOption];
    [storeOptions setObject:YOUR_EXTERNAL_RECORD_EXTENSION forKey:NSExternalRecordExtensionOption];
        
    
    NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:mom];
    if (![coordinator addPersistentStoreWithType:YOUR_STORE_TYPE configuration:nil URL:url options:storeOptions error:&error]) {
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _persistentStoreCoordinator = coordinator;
    
    return _persistentStoreCoordinator;
}

// File open 

- (void)application:(NSApplication *)theApplication openFiles:(NSArray *)files {
    
    NSString *aPath = [files lastObject]; // Just an example to get at one of the paths.
    
    if (aPath && [aPath hasSuffix:YOUR_EXTERNAL_RECORD_EXTENSION]) {
        // Decode URI from path.
        NSURL *objectURI = [[NSPersistentStoreCoordinator elementsDerivedFromExternalRecordURL:[NSURL fileURLWithPath:aPath]] objectForKey:NSObjectURIKey];
        if (objectURI) {
            NSManagedObjectID *moid = [[self persistentStoreCoordinator] managedObjectIDForURIRepresentation:objectURI];
            if (moid) {
                NSManagedObject *mo = [[self managedObjectContext] objectWithID:moid];
                
                // Your code to select the object in your application's UI.
                
                DDLogInfo(@"Received file open commend: %@", aPath);
            }
        }
    }
}

// Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) 
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:@"Failed to initialize the store" forKey:NSLocalizedDescriptionKey];
        [dict setValue:@"There was an error building up the data file." forKey:NSLocalizedFailureReasonErrorKey];
        NSError *error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        [[NSApplication sharedApplication] presentError:error];
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];

    return _managedObjectContext;
}

// Returns the NSUndoManager for the application. In this case, the manager returned is that of the managed object context for the application.
- (NSUndoManager *)windowWillReturnUndoManager:(NSWindow *)window
{
    return [[self managedObjectContext] undoManager];
}

// Performs the save action for the application, which is to send the save: message to the application's managed object context. Any encountered errors are presented to the user.
- (IBAction)saveAction:(id)sender
{
    NSError *error = nil;
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing before saving", [self class], NSStringFromSelector(_cmd));
    }
    
    if (![[self managedObjectContext] save:&error]) {
        [[NSApplication sharedApplication] presentError:error];
    }
}


// Import Pocket Query

- (IBAction)importPocketQueryAction:(id)sender {
    
    NSOpenPanel *op = [NSOpenPanel openPanel];
	NSArray* fileTypes = [[NSArray alloc] initWithObjects:@"zip", @"ZIP", @"gpx", @"GPX", nil];
	
	[op setCanChooseDirectories:NO];
    [op setCanChooseFiles:YES];
    [op setAllowsMultipleSelection:YES];
	
	[op setAllowedFileTypes:fileTypes];
	
    [op setTitle:@"Select Pocket Queries to Import"];
    [op setPrompt:@"Select"];
	
	NSInteger result = [op runModal];
	
	
	if (result == NSOKButton){
		
		NSArray* fileNames = [op URLs];
                
		// Starts a new thread:
		[gcdbPQImport importPqFiles:fileNames appDelegate:self];
		
	}
    
}

- (void) importGPXFile:(NSString *)filePath {
	
	DDLogVerbose(@"In Applescript called method importGPXFile command for %@", filePath);
	
	NSURL *URLPath = [NSURL fileURLWithPath:filePath];
	
	NSArray* fileNames = [NSArray arrayWithObject:URLPath];
	
	// Starts a new thread:
	[gcdbPQImport importPqFiles:fileNames appDelegate:self];
    
}

// Download and process http://gcvote.com/dump/votes.csv.gz

- (IBAction)importGCVoteAction:(id)sender {
    
    [self indicateProgressStart:@"Downloading...."];
    
    NSURL *gcvoteURL = [NSURL URLWithString:@"http://gcvote.com/dump/votes.csv.gz"];
    
    // Create the request.
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:gcvoteURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    // create the connection with the request
    // and start loading the data
    NSURLConnection *theConnection=[[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
    if (theConnection) {
        // Create the NSMutableData to hold the received data.
        // receivedData is an instance variable declared elsewhere.
        receivedData = [NSMutableData data];
    } else {
        // Inform the user that the connection failed.
        
        DDLogError(@"Connection failed.");
        
        [self indicateProgressStop];
    }
    
//    NSData *gcvoteContents = [gcvoteURL resourceDataUsingCache:YES];
//
//    DDLogVerbose(@"Step 1: initializing string.");
//    
//    NSString *csvContents = [NSString stringWithContentsOfURL:(NSURL *)gcvoteURL usedEncoding:nil error:nil ];
//    
//    DDLogVerbose(@"Step 2: Getting array of lines.");
//    
//    NSCharacterSet* csvSeparatorSet = [NSCharacterSet characterSetWithCharactersInString:@",\""];
//    
//    for (NSString *csvLine  in [csvContents componentsSeparatedByCharactersInSet:
//                                [NSCharacterSet newlineCharacterSet]]) {
//        
//        DDLogVerbose(@"%@", csvLine);
//        
//        return;
//        
//    }
    

}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    // This method is called when the server has determined that it
    // has enough information to create the NSURLResponse.
    
    // It can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    
    // receivedData is an instance variable declared elsewhere.
    [receivedData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    // Append the new data to receivedData.
    // receivedData is an instance variable declared elsewhere.
    [receivedData appendData:data];
    [self setProgressText:[NSString stringWithFormat:@"Received %lu bytes", [receivedData length]]];
    DDLogVerbose(@"Received %lu bytes", [receivedData length]);
}


- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self indicateProgressStop];
    // inform the user
    DDLogError(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // do something with the data
    // receivedData is declared as a method instance elsewhere
    NSLog(@"Succeeded! Received %ld bytes of data",[receivedData length]);
    
    [gcdbGCVoteImporter importGCVoteCSV:receivedData delegate:self];

}


- (NSApplicationTerminateReply)applicationShouldTerminate:(NSApplication *)sender
{
    // Save changes in the application's managed object context before the application terminates.
    
    if (!_managedObjectContext) {
        return NSTerminateNow;
    }
    
    if (![[self managedObjectContext] commitEditing]) {
        NSLog(@"%@:%@ unable to commit editing to terminate", [self class], NSStringFromSelector(_cmd));
        return NSTerminateCancel;
    }
    
    if (![[self managedObjectContext] hasChanges]) {
        return NSTerminateNow;
    }
    
    NSError *error = nil;
    if (![[self managedObjectContext] save:&error]) {

        // Customize this code block to include application-specific recovery steps.              
        BOOL result = [sender presentError:error];
        if (result) {
            return NSTerminateCancel;
        }

        NSString *question = NSLocalizedString(@"Could not save changes while quitting. Quit anyway?", @"Quit without saves error question message");
        NSString *info = NSLocalizedString(@"Quitting now will lose any changes you have made since the last successful save", @"Quit without saves error question info");
        NSString *quitButton = NSLocalizedString(@"Quit anyway", @"Quit anyway button title");
        NSString *cancelButton = NSLocalizedString(@"Cancel", @"Cancel button title");
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setMessageText:question];
        [alert setInformativeText:info];
        [alert addButtonWithTitle:quitButton];
        [alert addButtonWithTitle:cancelButton];

        NSInteger answer = [alert runModal];
        
        if (answer == NSAlertAlternateReturn) {
            return NSTerminateCancel;
        }
    }

    return NSTerminateNow;
}

// This will be called once on the initial selection
// twice thereafter.
- (void)tableViewSelectionDidChange:(NSNotification *)aNotification{
	
    DDLogVerbose(@"Table view selection changed called.");
	
    if ([aNotification object] == cacheTableView) {
        
        NSString *htmlString;
        
        NSArray *selectedWaypoints = [Caches selectedObjects];
        
        if ([selectedWaypoints count] < 2) {
            
            if ([selectedWaypoints count] == 0) {
                
                htmlString = @"Select a cache";
                
                [cachePopover close];
                
            } else {
                
                Cache *wpt = [selectedWaypoints objectAtIndex:0];
                
                htmlString = [wpt htmlDescription];
                
                DDLogVerbose(@"Table view %@.", [wpt desc]);
                
                if ([selectedWaypoints count] == 1 && [togglePopoverButton state] == NSOnState) {
                    
                    [cachePopover showRelativeToRect:[cacheTableView rectOfRow:[cacheTableView selectedRow]]
                                              ofView:cacheTableView
                                       preferredEdge:NSMaxXEdge];
                    
                } else {
                    [cachePopover close];
                }
                
            }

            [[webViewDetails mainFrame] loadHTMLString:htmlString baseURL:nil];
            
        }
        
    }
	
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row {
    
    if (tableView == logsTableView) {
        
        NSArray *selectedWaypoints = [Caches selectedObjects];
        
        if ([selectedWaypoints count] == 1) {
            
            // Wrap for log text column:
            NSTableColumn *column = [tableView tableColumnWithIdentifier:@"logtext"];
            
            CGFloat columnWidth = [column width];
            
            NSCell *cell = [[column dataCellForRow:row] copyWithZone:NULL];
            
            [cell setWraps:YES]; // Has to be set to allow word-wrapping calculation
            
            Cachelog *log = [[Cachelogs arrangedObjects] objectAtIndex:row];
            
            [cell setStringValue:[log groundspeak_text]];
            
            CGFloat cellHeight = [cell cellSizeForBounds:NSMakeRect(0.0, 0.0, columnWidth, 10000.0)].height+10.0;
            
            return  MAX(cellHeight * 1.5, 90);
            
        }
    }
    
    return [tableView rowHeight];  // Return default value
    
}

- (IBAction)togglePopoverButtonSelect:(id)sender {

    if ([togglePopoverButton state] == NSOnState) {
        
        [self tableViewSelectionDidChange:[NSNotification notificationWithName:@"togglePopoverButton" object:cacheTableView]];
        
    } else {
        [cachePopover close];
    }

}

- (NSArray *)logsSortDescriptors {
    return [NSArray arrayWithObject:
            [NSSortDescriptor sortDescriptorWithKey:@"groundspeak_date"
                                          ascending:NO]];
}

-(IBAction)showPreferences:(id)sender{
	
	if(!preferenceController)
		preferenceController = [[gcdbPreferenceController alloc] init];
	
	NSWindow* prefWindow = [preferenceController window];
	
	[preferenceController showWindow:self];
	
	[prefWindow makeKeyWindow];
	
}

- (IBAction) setHomeCoordinates:(id)sender {
	
	NSArray *selectedWaypoints = [Caches selectedObjects];
	
	if ([selectedWaypoints count] == 1) {
		
		Waypoint *wpt = [selectedWaypoints objectAtIndex:0];
		
		[gcdbStaticCoordinates setHomeLat:[[wpt lat] doubleValue]];
		[gcdbStaticCoordinates setHomeLon:[[wpt lon] doubleValue]];
		
		[cacheTableView reloadData];
	}
}


- (IBAction)openExportSheet:(id)sender
{
	[NSApp beginSheet:exportSheet
	   modalForWindow:window
		modalDelegate:self
	   didEndSelector:NULL
		  contextInfo:nil];
}

- (IBAction)closeExportSheet:(id)sender
{
	[NSApp endSheet:exportSheet];
	[exportSheet orderOut:sender];
}

- (IBAction)exportTemplate:(id)sender {
	[NSApp endSheet:exportSheet];
	[exportSheet orderOut:sender];
    
    [gcdbTemplateExporter exportDBbyTemplate:self];
    
}

- (IBAction)openFilterEditor:(id)sender
{
	[NSApp beginSheet:filterSheet
	   modalForWindow:window
		modalDelegate:nil
	   didEndSelector:NULL
		  contextInfo:nil];
}

- (IBAction)closeFilterEditor:(id)sender
{
	[NSApp endSheet:filterSheet];
	[filterSheet orderOut:sender];
}

- (void) indicateProgressStart:(NSString*)progressText {
	
	[progressIndicator setUsesThreadedAnimation:YES];
	[progressIndicator setHidden:NO];
	[progressLabel setHidden:NO];
	[progressLabel setStringValue:progressText];
	[progressIndicator startAnimation:self];
    
}

- (void) indicateProgressStop {
	
	[progressLabel setStringValue:@""];
	[progressLabel setHidden:YES];
	[progressIndicator stopAnimation:self];
	[progressIndicator setHidden:YES];
	
}

- (void) setProgressText:(NSString*)progressText {
    [progressLabel setHidden:NO];
	[progressLabel setStringValue:progressText];
}

/**
 Opens a GPX file in Garmin Basecamp.app.
 */

- (IBAction) OpenSelectedInBasecamp:(id)sender {
    
    NSString *homeDir = NSHomeDirectory();
    
    DDLogVerbose(@"Homedir %@",homeDir);
    
	NSURL* url = [gcdbGeoExporter exportGPX:[Caches selectedObjects]
						   outputDirectory:[self applicationFilesDirectory]];
	
	//--------------------------------------++++++++*******************
	
	//[NSWorkspace sharedWorkspace];
	
	NSArray *retID = [NSArray array];
	NSAppleEventDescriptor* targetDesc2 = [NSAppleEventDescriptor nullDescriptor];
    
	
	[[NSWorkspace sharedWorkspace]
	 openURLs:[NSArray arrayWithObjects:url,nil]
	 withAppBundleIdentifier:@"com.garmin.BaseCamp"
	 options:NSWorkspaceLaunchDefault
	 additionalEventParamDescriptor:targetDesc2
	 launchIdentifiers:&retID
	 ];
	
	
	DDLogVerbose(@"Ret ID %@",[retID description]);
	
}

@end
