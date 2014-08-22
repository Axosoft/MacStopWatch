//
//  GTMClasses.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/10/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
@class GTMOAuth2Authentication;

@interface GTMClasses : NSObject

+ (GTMOAuth2Authentication *)authForOnTime;
+ (void)signOut;

@end
