//
//  AppController.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/5/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LoginController, UserInfo, Items, TimeLog;

@interface AppController : NSObject <NSMenuDelegate>
{
    NSStatusItem *statusItem;
    IBOutlet NSMenu *statusMenu;
    NSWindowController *_preferencesWindowController;
}

- (IBAction)searchForId:(id)sender;
- (IBAction)signOut:(id)sender;
- (IBAction)startTimer:(id)sender;
- (IBAction)stopTimer:(id)sender;
- (IBAction)uploadTime:(id)sender;
- (IBAction)quit:(id)sender;
- (IBAction)showWindow:(id)sender;
- (IBAction)removeItem:(id)sender;
- (IBAction)Redo:(id)sender;
- (IBAction)showPreferences:(id)sender;

- (void)userSignedIn;

@property (weak) IBOutlet NSMenuItem *startMenuItem;
@property (weak) IBOutlet NSMenuItem *stopMenuItem;
@property (nonatomic, strong) IBOutlet NSPopUpButton *itemType;
@property (nonatomic, strong) IBOutlet NSTableView *itemsTable;
@property (nonatomic, strong) IBOutlet NSTableView *timeTable;
@property (nonatomic, strong) IBOutlet NSTextField *timeLabel;
@property (nonatomic, strong) IBOutlet NSArrayController *itemArrayController;
@property (nonatomic, strong) IBOutlet NSArrayController *timeLogArrayController;
@property (weak) IBOutlet NSButton *startButton;
@property (weak) IBOutlet NSButton *stopButton;
@property (weak) IBOutlet NSButton *uploadButton;
@property (nonatomic, readonly) NSWindowController *preferencesWindowController;
@property (nonatomic, strong) NSTimer *timer;

@property (strong) IBOutlet NSWindow *mainWindow;
@property (nonatomic, strong) LoginController *loginController;
@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (copy) Items *items;
@property (copy) TimeLog *timeLog;

@end
