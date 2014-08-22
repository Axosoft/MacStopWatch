//
//  DataClass.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/10/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GTMOAuth2Authentication;

@interface DataClass : NSObject

extern NSString * const kClientId;
extern NSString * const kClientSecret;
extern NSString * const kServiceName;
extern NSString * const kKeychainName;

@property (nonatomic, assign) GTMOAuth2Authentication *auth;
@property (assign) BOOL isSignedIn;
@property (strong) NSString *accessToken;
@property (strong) NSDate *startDateTime;
@property (strong) NSDate *stopDateTime;
@property (nonatomic) NSUInteger uploadedTime;

+ (DataClass *)sharedInstance;

@end
