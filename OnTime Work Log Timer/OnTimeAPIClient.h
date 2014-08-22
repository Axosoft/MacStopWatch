//
//  OnTimeAPIClient.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/20/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "AFHTTPClient.h"

@interface OnTimeAPIClient : AFHTTPClient

+ (OnTimeAPIClient *)sharedClient;

@end
