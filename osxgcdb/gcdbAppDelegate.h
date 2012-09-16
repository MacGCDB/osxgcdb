//
//  gcdbAppDelegate.h
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

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

@interface gcdbAppDelegate : NSObject <NSApplicationDelegate, NSUserNotificationCenterDelegate> {

    NSPersistentStoreCoordinator *persistentStoreCoordinator;
    NSManagedObjectModel *managedObjectModel;
    NSManagedObjectContext *managedObjectContext;
	
	NSTableView *cacheTableView;
    NSTableView *logsTableView;
	
	IBOutlet NSArrayController *Caches;
    IBOutlet NSArrayController *Cachelogs;
    
    IBOutlet WebView *webViewDetails;
    
    NSPopover *cachePopover;
    NSButton *togglePopoverButton;
    
    NSMutableData *receivedData;
    
    IBOutlet NSWindow *exportSheet;
    
    IBOutlet NSWindow *filterSheet;
    
    
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong) IBOutlet NSTableView *cacheTableView;
@property (strong) IBOutlet NSTableView *logsTableView;
@property (strong) IBOutlet WebView *webViewDetails;

@property (strong) IBOutlet NSPopover *cachePopover;
@property (strong) IBOutlet NSButton *togglePopoverButton;

@property (strong) IBOutlet NSTextField *progressLabel;
@property (strong) IBOutlet NSProgressIndicator *progressIndicator;

- (dispatch_queue_t)importExportQueue;

- (IBAction)saveAction:(id)sender;

- (IBAction)importPocketQueryAction:(id)sender;

- (IBAction)importGCVoteAction:(id)sender;

- (IBAction)togglePopoverButtonSelect:(id)sender;

- (IBAction)showPreferences:(id)sender;

- (IBAction)exportTemplate:(id)sender;
- (IBAction) OpenSelectedInBasecamp:(id)sender;

- (NSURL *)applicationFilesDirectory;

- (NSArray *)logsSortDescriptors;

- (IBAction) setHomeCoordinates:(id)sender;

- (IBAction) openExportSheet:(id)sender;
- (IBAction) closeExportSheet:(id)sender;

- (IBAction) openFilterEditor:(id)sender;
- (IBAction) closeFilterEditor:(id)sender;

- (void) importGPXFile:(NSString *)filePath;

- (void) indicateProgressStart:(NSString*)progressText;
- (void) indicateProgressStop;
- (void) setProgressText:(NSString*)progressText;

@end
