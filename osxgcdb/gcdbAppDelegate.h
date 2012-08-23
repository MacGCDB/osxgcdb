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
	
	NSTableView * cacheTableView;
	
	IBOutlet NSArrayController *Caches;
    
    IBOutlet WebView *webViewDetails;

}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (strong) IBOutlet NSTableView * cacheTableView;
@property (strong) IBOutlet WebView * webViewDetails;


- (IBAction)saveAction:(id)sender;

- (IBAction)importPocketQueryAction:(id)sender;

- (NSURL *)applicationFilesDirectory;

@end
