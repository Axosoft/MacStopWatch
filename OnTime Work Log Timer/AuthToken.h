//
//  AuthToken.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/9/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface AuthToken : NSManagedObject

@property (nonatomic, retain) NSString * accessToken;
@property (nonatomic, retain) NSString * tokenType;

@end
