//
//  AppController.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/5/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "AppController.h"
#import "GeneralPreferencesController.h"
#import "AdvancedPreferencesController.h"
#import "LoginController.h"
#import "GTMOAuth2WindowController.h"
#import "GTMClasses.h"
#import "OnTimeClasses.h"
#import "Items.h"
#import "TimeLog.h"
#import "MASPreferencesWindowController.h"
#import "TaskType.h"

@implementation AppController
{
//    PreferencesController *prefsController;
    NSDate *startTime;
    NSDate *stopTime;
}

- (id)init
{
    self = [super init];
    if (self) {        
        [self setManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
        [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Defaults" ofType:@"plist"]]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadFinished) name:@"TimeUploadFinished" object:nil];
        BOOL didAuth = NO;
        GTMOAuth2Authentication *auth = [GTMClasses authForOnTime];
        [[DataClass sharedInstance] setAuth:auth];
        if (auth) {
            didAuth = [GTMOAuth2WindowController authorizeFromKeychainForName:kKeychainName authentication:auth];
        }
        
        if (didAuth) {
            [[DataClass sharedInstance] setIsSignedIn:YES];
             NSLog(@"Already signed in");
#ifdef DEBUG
            NSLog(@"Auth: %@", auth.parameters);
            NSLog(@"API: %@", [[NSUserDefaults standardUserDefaults] objectForKey:@"apiURL"]);
#endif
            [[DataClass sharedInstance] setAccessToken:[auth.parameters objectForKey:@"access_token"]];
            
            [NSApp activateIgnoringOtherApps:YES];
        } else {
            NSLog(@"Not signed in");
            _loginController = [[LoginController alloc] initWithWindowNibName:@"Login"];
            _loginController.parent = self;
            [[_loginController window] makeKeyAndOrderFront:self];
        }
    }
    
    return self;
}


- (void)awakeFromNib
{
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusMenu setDelegate:self];
    [statusItem setMenu:statusMenu];
    [statusItem setTitle:@"00:00:00"];
    [statusItem setHighlightMode:YES];
    [statusItem setImage:[NSImage imageNamed:@"status_bar_icon_18x18"]];
    //    [statusItem setImage:[NSImage imageNamed:@"image"]];
    _managedObjectContext = [[CoreDataHelper sharedInstance] managedObjectContext];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(coreDataChange)
                                                 name:NSManagedObjectContextObjectsDidChangeNotification
                                               object:[[CoreDataHelper sharedInstance] managedObjectContext]];
    if ([[DataClass sharedInstance] isSignedIn]) {
        [self.mainWindow makeKeyAndOrderFront:self];
//        [self.mainWindow setOrderedIndex:0];
        [self loadProjectsAndSettings];
    }
}

- (void)menuWillOpen:(NSMenu *)menu
{
    [self populateStartMenuItems];
}

- (NSWindowController *)preferencesWindowController
{
    if (_preferencesWindowController == nil)
    {
        NSViewController *generalViewController = [[GeneralPreferencesController alloc] init];
        NSViewController *advancedViewController = [[AdvancedPreferencesController alloc] init];
        NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, advancedViewController, nil];
        
        // To add a flexible space between General and Advanced preference panes insert [NSNull null]:
        //     NSArray *controllers = [[NSArray alloc] initWithObjects:generalViewController, [NSNull null], advancedViewController, nil];
        
        
        
        NSString *title = @"Preferences";
        _preferencesWindowController = [[MASPreferencesWindowController alloc] initWithViewControllers:controllers title:title];
    }
    return _preferencesWindowController;
}

- (void)coreDataChange
{
//    NSLog(@"Core Data Changed");
    [[CoreDataHelper sharedInstance] saveContext];
}

- (IBAction)showWindow:(id)sender
{
    [NSApp activateIgnoringOtherApps:YES];
    if (_loginController) {
        [[_loginController window] makeKeyAndOrderFront:self];
    } else {
        [self.mainWindow makeKeyAndOrderFront:self];
    }
}

- (IBAction)quit:(id)sender
{
    [NSApp terminate:self];
}

- (IBAction)signOut:(id)sender
{
    [GTMClasses signOut];
    [[DataClass sharedInstance] setIsSignedIn:NO];
    [self quit:self];
}

- (IBAction)showPreferences:(id)sender
{
//    prefsController = [[PreferencesController alloc] initWithWindowNibName:@"PreferencesController"];
//    [[prefsController window] makeKeyAndOrderFront:self];
    [self.preferencesWindowController showWindow:nil];
}

- (void)userSignedIn
{
    NSLog(@"User signed in");
    [_loginController.window close];
    _loginController = nil;
    [self.mainWindow makeKeyAndOrderFront:self];
    [self loadProjectsAndSettings];
}

- (IBAction)searchForId:(id)sender
{

    NSString *searchId = [sender stringValue];
    
    NSString *selectedItemType = [[self itemType] titleOfSelectedItem];
    NSString *itemType = nil;
    NSError *error;
    NSFetchRequest *itemTypeFetch = [[[CoreDataHelper sharedInstance] managedObjectModel] fetchRequestFromTemplateWithName:@"fetchItemTypeByTitle" substitutionVariables:[NSDictionary dictionaryWithObjects:@[selectedItemType] forKeys:@[@"selectedItemTitle"]]];
    NSArray *itemTypes = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:itemTypeFetch error:&error];
    if ([itemTypes count] == 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Unable to find selected item type in Core Data. Maybe try reinstalling?"];
        [alert runModal];
        return;
    }
    itemType = [[itemTypes objectAtIndex:0] apiKey];
    NSFetchRequest *fetchRequest = [[[CoreDataHelper sharedInstance] managedObjectModel]
                                    fetchRequestFromTemplateWithName:@"fetchItemsByTypeAndId"
                                    substitutionVariables:[NSDictionary
                                                           dictionaryWithObjectsAndKeys:itemType, @"itemType",searchId,@"itemId",nil]];
    
    NSArray *appts = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if ([appts count] > 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Item has already exists below."];
        [alert runModal];
    } else if ([searchId isEqualToString:@""]) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Please Enter a Value to Search"];
        [alert runModal];
            } else {
        [OnTimeClasses searchForItemByType:itemType andId:searchId andTable:[self itemsTable]];
    }
    
}

- (void)loadProjectsAndSettings
{
    [OnTimeClasses getTimeUnits];
    [self populateStartMenuItems];
    [self populateDropDownTypes];
}

- (void)populateDropDownTypes
{
    NSArray *initialValues = @[@{@"defects": @"Defects"}, @{@"features": @"Work Items"}, @{@"incidents": @"Tickets"}, @{@"tasks": @"Custom"}];
    NSFetchRequest *fetchRequest = [[[CoreDataHelper sharedInstance] managedObjectModel] fetchRequestFromTemplateWithName:@"fetchAllTaskTypes" substitutionVariables:nil];
    
    NSError *error;
    
    NSArray *taskTypes = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    if ([taskTypes count] == 0) {
        // Import taskTypes for dropdown
        [initialValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            id dictKey = [[obj allKeys] objectAtIndex:0];
            TaskType *newTaskType = [NSEntityDescription insertNewObjectForEntityForName:@"TaskType" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
            newTaskType.apiKey = dictKey;
            newTaskType.displayValue = [obj objectForKey:dictKey];
        }];
        [[CoreDataHelper sharedInstance] saveContext];
    }
}

- (IBAction)startTimer:(id)sender
{
    [[DataClass sharedInstance] setStartDateTime:[NSDate date]];
    startTime = [[DataClass sharedInstance] startDateTime];
    [self setTimer:[NSTimer scheduledTimerWithTimeInterval:0.1
                                                    target:self
                                                  selector:@selector(updateTimer)
                                                  userInfo:nil
                                                   repeats:YES]];
    [[self itemsTable] setEnabled:NO];
    [self setStartButtonsEnabled:NO];
    [statusItem setImage:[NSImage imageNamed:@"status_bar_icon_18x18_color"]];
}

- (IBAction)stopTimer:(id)sender
{
    stopTime = [NSDate date];
    [[DataClass sharedInstance] setStopDateTime:stopTime];
    
    Items *selected = [(Items *)[self.itemArrayController selection] valueForKey:@"self"];
    TimeLog *timeLog = [NSEntityDescription insertNewObjectForEntityForName:@"TimeLog" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
    NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];   
    
    timeLog.time = [NSString stringWithFormat:@"%i", abs(elapsedTime)];
    timeLog.date = stopTime;
    [selected addTimeLogObject:timeLog];
    [[CoreDataHelper sharedInstance] saveContext];
    
    [self.timer invalidate];
    [[self itemsTable] setEnabled:YES];
    [self setStartButtonsEnabled:YES];
    [self setTimeLabels:@"00:00:00"];
    [statusItem setImage:[NSImage imageNamed:@"status_bar_icon_18x18"]];
    
}

- (void)setStartButtonsEnabled:(BOOL)status
{
    [[self startButton] setEnabled:status];
    [[self startMenuItem] setEnabled:status];
    
    [[self stopButton] setEnabled:!status];
    [[self stopMenuItem] setEnabled:!status];
}

- (IBAction)uploadTime:(id)sender
{
    [self.uploadButton setEnabled:NO];
    [self.timeTable abortEditing];
    [OnTimeClasses uploadTime:self.timeLogArrayController];
}

- (void)uploadFinished
{
    [self.uploadButton setEnabled:YES];
}

- (void)updateTimer
{
    NSTimeInterval elapsedTime = [startTime timeIntervalSinceNow];

    NSInteger seconds = (NSInteger)fabs(elapsedTime);
    NSString *string = [NSString stringWithFormat:@"%02li:%02li:%02li",
                        (NSInteger)seconds / 3600, (NSInteger)(seconds / 60) % 60, (NSInteger)seconds % 60];
    
    [self setTimeLabels:string];
}

- (void)removeItem:(id)sender
{
    Items *selectedItem = [[self.itemArrayController selection] valueForKey:@"self"];
    if ([[selectedItem timeLog] count] > 0) {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You currently have time entries for the selected item. Please remove all time entries before removing the item."];
        [alert runModal];
        
        return;
    }
    
    
    [self.itemArrayController removeObject:selectedItem];
    [[CoreDataHelper sharedInstance] saveContext];
    [self populateStartMenuItems];
}

- (void)setTimeLabels:(NSString *)time
{
    [[self timeLabel] setStringValue:time];
    [statusItem setTitle:time];
}

- (void)populateStartMenuItems
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Items"];
    [fetchRequest setPredicate:nil];
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"itemId" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    NSError *error;
    NSArray *items = [[[CoreDataHelper sharedInstance] managedObjectContext] executeFetchRequest:fetchRequest error:&error];
    [[self.startMenuItem submenu] removeAllItems];
    for (Items *item in items) {
        NSMenuItem *subMenuItem = [[NSMenuItem alloc] initWithTitle:[NSString stringWithFormat:@"%@ - %@", [item itemId], [item title]]
                                                             action:@selector(startMenuItemPressed:)
                                                      keyEquivalent:@""];
        [subMenuItem setRepresentedObject:item];
        [subMenuItem setTarget:self];
        [[self.startMenuItem submenu] addItem:subMenuItem];
    }
}

- (void)startMenuItemPressed:(id)sender
{
    [self.itemArrayController setSelectedObjects:@[[sender representedObject]]];
    if ([self respondsToSelector:@selector(startTimer:)]) {
        [self startTimer:self];
    }
}


@end
