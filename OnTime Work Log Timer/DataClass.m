//
//  DataClass.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/10/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "DataClass.h"

@implementation DataClass

NSString * const kClientId = @"clientIDPlaceholder";
NSString * const kClientSecret = @"clientSecretPlaceholder";
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
