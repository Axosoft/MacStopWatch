//
//  LoginControllerWindowController.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/8/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "LoginController.h"
#import "AuthToken.h"
#import "UserInfo.h"
#import "GTMOAuth2WindowController.h"
#import "GTMClasses.h"
#import "AppController.h"
#import "AppDelegate.h"


@interface LoginController ()

@end

@implementation LoginController
@synthesize settingsSheet, apiForm, parent;


- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
}

- (void)awakeFromNib
{
    [self checkLoginButton];
    
}

- (IBAction)login:(id)sender
{
    GTMOAuth2Authentication *auth = [GTMClasses authForOnTime];
    
    // Specify the appropriate scope string, if any, according to the service's API documentation
    auth.scope = @"read write";
    NSString *urlString = [NSString stringWithFormat:@"%@/auth", [[NSUserDefaults standardUserDefaults] objectForKey:@"onTimeURL" ]];
    GTMOAuth2WindowController *windowController = [GTMOAuth2WindowController controllerWithAuthentication:auth
                                                                                     authorizationURL:[NSURL URLWithString:urlString]
                                                                                     keychainItemName:kKeychainName
                                                                                       resourceBundle:nil];
    
        

    NSString *html = @"<html><body><div align=center>Loading sign-in page...</div></body></html>";
    [windowController setInitialHTMLString:html];
//    [windowController signInSheetModalForWindow:self.window
//                                 delegate:self
//                         finishedSelector:@selector(windowController:finishedWithAuth:error:)];
    
    [windowController signInSheetModalForWindow:self.window
                              completionHandler:^(GTMOAuth2Authentication *auth, NSError *error) {
                                  [self windowController:windowController finishedWithAuth:auth error:error];
                              }];
}



- (void)windowController:(GTMOAuth2WindowController *)windowController
        finishedWithAuth:(GTMOAuth2Authentication *)auth
                   error:(NSError *)error {
    if (error != nil) {
        // Authentication failed
        NSLog(@"Error: %@", error);
        NSAlert *alert = [NSAlert alertWithMessageText:@"Error" defaultButton:@"OK" alternateButton:nil otherButton:nil informativeTextWithFormat:@"%@", [error localizedDescription]];
        [alert runModal];
    } else {
        // Authentication succeeded
//        [[RKObjectManager sharedManager] setHTTPClient:[AFHTTPClient clientWithBaseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"apiURL"]]]];
        [[DataClass sharedInstance] setAccessToken:[auth.parameters objectForKey:@"access_token"]];
        [[CoreDataHelper sharedInstance] clearEntity:@"UserInfo"];
        NSManagedObject *userInfo = [NSEntityDescription insertNewObjectForEntityForName:@"UserInfo" inManagedObjectContext:[[CoreDataHelper sharedInstance] managedObjectContext]];
        NSDictionary *authParams = [auth.parameters valueForKeyPath:@"data"];
        [userInfo setValue:[authParams objectForKey:@"email"] forKey:@"email"];
        [userInfo setValue:[authParams objectForKey:@"first_name"] forKey:@"firstName"];
        [userInfo setValue:[authParams objectForKey:@"last_name"] forKey:@"lastName"];
        [userInfo setValue:[authParams objectForKey:@"id"] forKey:@"userId"];
        [[CoreDataHelper sharedInstance] saveContext];

        [[DataClass sharedInstance] setIsSignedIn:YES];
                
        [parent userSignedIn];
    }
}

- (IBAction)openSettingsSheet:(id)sender
{
    if (!settingsSheet) {
        [NSBundle loadNibNamed:@"APISettings" owner:self];
        [[apiForm cellAtIndex:eOnTimeURL] setStringValue:[[NSUserDefaults standardUserDefaults] objectForKey:@"onTimeURL"]];
        [NSApp beginSheet:settingsSheet modalForWindow:self.window modalDelegate:self didEndSelector:NULL contextInfo:NULL];
//        [NSApp runModalForWindow:settingsSheet];
    }
}

- (IBAction)closeSettingsSheet:(id)sender
{
    NSString *sOnTimeURL = [self cleanURL:[[apiForm cellAtIndex:eOnTimeURL] stringValue]];
    NSString *sApi = @"";
    if ([[[apiForm cellAtIndex:eOnTimeURL] stringValue] length] > 0) {
        
        sApi = [NSString stringWithFormat:@"%@/api/v4",[self cleanURL:[[apiForm cellAtIndex:eOnTimeURL] stringValue]]];
    }
    [[NSUserDefaults standardUserDefaults] setObject:sOnTimeURL forKey:@"onTimeURL"];
    [[NSUserDefaults standardUserDefaults] setObject:sApi forKey:@"apiURL"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [NSApp endSheet:settingsSheet];
    [settingsSheet close];
    settingsSheet = nil;
    [self checkLoginButton];
    
}

- (void)checkLoginButton
{
    NSURL* url = [NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"onTimeURL"]];
    if (url && url.scheme && url.host) {
#ifdef DEBUG
        NSLog(@"Valid URL");
#endif
        [self.loginButton setEnabled:YES];
    } else {
#ifdef DEBUG
        NSLog(@"INvalid URL");
#endif
        [self.loginButton setEnabled:NO];
    }
}

- (NSString *)cleanURL:(NSString *)url
{
    NSString *newURL = url;
    if ([newURL length] > 0) {
        while([[newURL substringFromIndex: [newURL length] - 1] isEqualToString:@"/"]) {
            newURL = [url substringToIndex:[newURL length] - 1];
        }
    }
    return newURL;
}

@end
