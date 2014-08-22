//
//  OnTimeAPIClient.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/20/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "OnTimeAPIClient.h"
#import "AFJSONRequestOperation.h"

@implementation OnTimeAPIClient

 
+ (OnTimeAPIClient *)sharedClient
{
    static OnTimeAPIClient *sharedClient = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedClient = [[OnTimeAPIClient alloc] initWithBaseURL:[NSURL URLWithString:[[NSUserDefaults standardUserDefaults] objectForKey:@"apiURL"]]];
    });
    return sharedClient;
}

- (id)initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    
    if (self) {
        [self registerHTTPOperationClass:[AFJSONRequestOperation class]];
        [self setParameterEncoding:AFJSONParameterEncoding];
        [self setDefaultHeader:@"Accept" value:@"application/json"];
        [self setDefaultHeader:@"Authorization" value:[NSString stringWithFormat:@"Bearer %@", [[DataClass sharedInstance] accessToken]]];
        
    }
    
    return self;
}

@end
