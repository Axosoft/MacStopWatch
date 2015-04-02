//
//  DataClass.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/10/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "DataClass.h"

@implementation DataClass

NSString * const kClientId = @"586a301a-d401-492d-b8b9-45a8309d811a";
NSString * const kClientSecret = @"69745eea-9e4c-4faa-8faa-28fc02fafd0f";
NSString * const kServiceName = @"Axosoft TimeTracker";
NSString * const kKeychainName = @"Axosoft Stopwatch";

static DataClass *instance = nil;


+(DataClass *)sharedInstance
{
    @synchronized(self)
    {
        if (instance == nil)
        {
            instance = [DataClass new];
        }
    }
    
    return instance;
}

@end
