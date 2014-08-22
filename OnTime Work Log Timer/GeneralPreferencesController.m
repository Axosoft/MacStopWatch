//
//  PreferencesController.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/5/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "GeneralPreferencesController.h"
#import <Sparkle/Sparkle.h>
#import <ServiceManagement/ServiceManagement.h>

@interface GeneralPreferencesController ()
{
    NSUserDefaults *userDefaults;
    BOOL startupEnabled;
    NSString *helperIdentifier;
}

@end

@implementation GeneralPreferencesController

- (id)init
{
    self = [super initWithNibName:@"GeneralPreferencesController" bundle:nil];
    if (self) {
        helperIdentifier = [[NSBundle bundleWithPath:[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Contents/Library/LoginItems/HelperApp.app"]] bundleIdentifier];
    }
    
    return self;
}

#pragma mark -
#pragma mark MASPreferencesViewController

- (NSString *)identifier
{
    return @"GeneralPreferences";
}

- (NSImage *)toolbarItemImage
{
    return [NSImage imageNamed:NSImageNamePreferencesGeneral];
}

- (NSString *)toolbarItemLabel
{
    return NSLocalizedString(@"General", @"Toolbar item name for the General preference pane");
}


//- (void)enableLoginItemWithLoginItemsReference:(LSSharedFileListRef)loginItemsRef ForPath:(CFURLRef)path
//{
//    LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(loginItemsRef, kLSSharedFileListItemLast, nil, nil, path, nil, nil);
//    if (item)
//        CFRelease(item);
//}
//
//- (void)disableLoginItemWithLoginItemsReference:(LSSharedFileListRef)loginItemsRef ForPath:(CFURLRef)path
//{
//    UInt32 seedValue;
//    NSArray *loginItemsArray = (__bridge NSArray *)LSSharedFileListCopySnapshot(loginItemsRef, &seedValue);
//    for (id item in loginItemsArray) {
//        LSSharedFileListItemRef itemRef = (__bridge LSSharedFileListItemRef)item;
//        if (LSSharedFileListItemResolve(itemRef, 0, (CFURLRef *)&path, nil) == noErr) {
//            if ([[(__bridge NSURL *)path path] hasPrefix:[NSString stringWithFormat:@"%@",[[NSBundle mainBundle] bundleURL]]])
//                LSSharedFileListItemRemove(loginItemsRef, itemRef);
//        }
//    }
//}

- (void)addLoginItem:(BOOL)status
{
	NSURL *url = [[[NSBundle mainBundle] bundleURL] URLByAppendingPathComponent:
                  @"Contents/Library/LoginItems/HelperApp.app"];
    
	// Registering helper app
	if (LSRegisterURL((__bridge CFURLRef)url, true) != noErr) {
#ifdef DEBUG
		NSLog(@"LSRegisterURL failed!");
#endif
	} else {
#ifdef DEBUG
        NSLog(@"LSRegisterURL success!");
#endif
    }
    
    if (!SMLoginItemSetEnabled((__bridge CFStringRef)helperIdentifier, (status) ? true : false)) {
        NSLog(@"SMLoginItemSetEnabled failed!");
        [self willChangeValueForKey:@"startAtLogin"];
        [self.startAtLogin setValue:[NSNumber numberWithBool:[self automaticStartup]] forKey:@"state"];
        [self didChangeValueForKey:@"startAtLogin"];
    }
}

- (void)setAutomaticStartup:(BOOL)state
{
#ifdef DEBUG
    NSLog(@"Set automatic startup: %d", state);
#endif
    if ([self respondsToSelector:@selector(addLoginItem:)]) {
        [self addLoginItem:state];
    }
}

- (BOOL)automaticStartup
{
    
    BOOL isEnabled  = NO;
    
    // the easy and sane method (SMJobCopyDictionary) can pose problems when sandboxed. -_-
    CFArrayRef cfJobDicts = SMCopyAllJobDictionaries(kSMDomainUserLaunchd);
    NSArray* jobDicts = CFBridgingRelease(cfJobDicts);
    
    if (jobDicts && [jobDicts count] > 0) {
        for (NSDictionary* job in jobDicts) {
            if ([helperIdentifier isEqualToString:[job objectForKey:@"Label"]]) {
                isEnabled = [[job objectForKey:@"OnDemand"] boolValue];
                break;
            }
        }
    }
//    if (isEnabled != _enabled) {
    [self willChangeValueForKey:@"startupEnabled"];
        startupEnabled = isEnabled;
    [self didChangeValueForKey:@"startupEnabled"];
//    }
    
    return isEnabled;
}


- (IBAction)setupCheckForUpdates:(id)sender
{
    [[SUUpdater sharedUpdater] setAutomaticallyChecksForUpdates:([sender state] == 1) ? YES : NO];
}

@end
