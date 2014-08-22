//
//  PreferencesController.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/5/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MASPreferencesViewController.h"

@interface GeneralPreferencesController : NSViewController <MASPreferencesViewController>

@property (weak, nonatomic) IBOutlet NSButton *startAtLogin;
@property (weak) IBOutlet NSButton *autoCheckForUpdates;

- (void)addLoginItem:(BOOL)status;
- (IBAction)setupCheckForUpdates:(id)sender;


@end
