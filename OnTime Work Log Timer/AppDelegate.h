//
//  AppDelegate.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/5/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@class LoginController;
@class AppController;

@interface AppDelegate : NSObject <NSApplicationDelegate>
{
    
}

@property (assign) IBOutlet NSWindow *window;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) LoginController *loginController;
@property (strong, nonatomic) AppController *appController;

- (IBAction)saveAction:(id)sender;

@end
