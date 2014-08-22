//
//  UserInfo.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/9/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface UserInfo : NSManagedObject

@property (nonatomic, retain) NSNumber * userId;
@property (nonatomic, retain) NSString * firstName;
@property (nonatomic, retain) NSString * lastName;
@property (nonatomic, retain) NSString * email;

@end
