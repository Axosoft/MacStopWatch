//
//  LoginControllerWindowController.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/8/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class AppController;

@interface LoginController : NSWindowController
{
    enum settingsIndices {
        eOnTimeURL
    };
}

@property (weak) IBOutlet NSButton *loginButton;
@property (strong) IBOutlet NSWindow *settingsSheet;
@property (strong) IBOutlet NSForm *apiForm;
@property (nonatomic, strong) AppController *parent;

- (IBAction)login:(id)sender;
- (IBAction)openSettingsSheet:(id)sender;
- (IBAction)closeSettingsSheet:(id)sender;

@end
