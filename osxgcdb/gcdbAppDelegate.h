//
//  gcdbAppDelegate.h
//  osxgcdb
//
//  Created by Gordon McDorman on 4-8-12.
//  Copyright (c) 2012 Danger Man Konsumprodukte. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface gcdbAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;

@end
