//
//  GTMClasses.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/10/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "GTMClasses.h"
#import "GTMOAuth2Authentication.h"
#import "GTMOAuth2WindowController.h"

@implementation GTMClasses

+ (GTMOAuth2Authentication *)authForOnTime
{
    NSString *urlString = [NSString stringWithFormat:@"%@/api/oauth2/token", [[NSUserDefaults standardUserDefaults] objectForKey:@"onTimeURL" ]];
    NSURL *tokenURL = [NSURL URLWithString:urlString];
    
    // We'll make up an arbitrary redirectURI.  The controller will watch for
    // the server to redirect the web view to this URI, but this URI will not be
    // loaded, so it need not be for any actual web page.
    NSString *redirectURI = [NSString stringWithFormat:@"%@/iphone/iphonehandler.ashx", [[NSUserDefaults standardUserDefaults] objectForKey:@"onTimeURL" ]];
    GTMOAuth2Authentication *auth = [GTMOAuth2Authentication authenticationWithServiceProvider:kServiceName
                                                                                      tokenURL:tokenURL
                                                                                   redirectURI:redirectURI
                                                                                      clientID:kClientId
                                                                                  clientSecret:kClientSecret];
    return auth;
}

+ (void)signOut
{
    [GTMOAuth2WindowController removeAuthFromKeychainForName:kKeychainName];
}

//+ (void)setRKAuthorizationToken:(NSString *)authorizationToken
//{
//    NSLog(@"Setting auth token");
//    RKObjectManager* objectManager = [RKObjectManager sharedManager];
//    NSLog(@"Object Manager: %@", objectManager);
//    [objectManager.HTTPClient setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", authorizationToken]];
//    NSLog(@"New manager: %@", objectManager.HTTPClient);
//}
@end
