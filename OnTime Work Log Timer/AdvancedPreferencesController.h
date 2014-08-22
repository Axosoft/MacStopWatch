//
//  AdvancedPreferencesController.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 4/16/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface AdvancedPreferencesController : NSViewController <MASPreferencesViewController>

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;
@property (strong) IBOutlet NSArrayController *taskTypeController;
@property (weak) IBOutlet NSTableView *taskTableView;

@end
