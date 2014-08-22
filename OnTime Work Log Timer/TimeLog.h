//
//  TimeLog.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Items;

@interface TimeLog : NSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * time;
@property (nonatomic, retain) Items *item;

@end
