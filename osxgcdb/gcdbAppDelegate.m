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



#import "GRMustache.h"

#import "SSZipArchive.h"

#import "gcdbPQImport.h"

#define YOUR_STORE_TYPE NSSQLiteStoreType
#define YOUR_EXTERNAL_RECORD_EXTENSION @"geocacherec"

//static const int ddLogLevel = LOG_LEVEL_INFO; //LOG_LEVEL_VERBOSE

@implementation gcdbAppDelegate

@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize managedObjectContext = _managedObjectContext;

@synthesize cacheTableView;
@synthesize webViewDetails;


- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];
    
    DDFileLogger *fileLogger = [[DDFileLogger alloc] init];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;
    
    [DDLog addLogger:fileLogger];
    
    DDLogInfo(@"Initialized logger.");
    
    DDLogInfo(@"log file at: %@", [[fileLogger currentLogFileInfo] filePath]);
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:2] forKey:@"count"];
    NSString *templateString = @"I have {{count}} arms.";
    NSString *rendering = [GRMustacheTemplate renderObject:dictionary fromString:templateString error:NULL];
    
    DDLogInfo(@"Rendered template: %@", rendering);
    
//    NSUserNotification *notification = [[NSUserNotification alloc] init];
//    [notification setTitle:@"Hello World"];
    //[notification setSubtitle:@"Hi there"];
//    [notification setActionButtonTitle:@"Yes"];
//    [notification setHasActionButton:YES];
//    [notification setInformativeText:@"Hello world message. A very long line with a lot of text. Blah blah."];
    NSUserNotificationCenter *center = [NSUserNotificationCenter defaultUserNotificationCenter];
    [center setDelegate:self];
//    [center deliverNotification:notification];
    
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didDeliverNotification:(NSUserNotification *)notification {
   NSLog(@"didDeliverNotification."); 
}

- (void)userNotificationCenter:(NSUserNotificationCenter *)center didActivateNotification:(NSUserNotification *)notification
{
    NSLog(@"didActivateNotification.");
}


- (BOOL)userNotificationCenter:(NSUserNotificationCenter *)center shouldPresentNotification:(NSUserNotification *)notification
{
    NSLog(@"shouldPresentNotification");
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

@end
