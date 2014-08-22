//
//  TaskType.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 4/16/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TaskType : NSManagedObject

@property (nonatomic, retain) NSString * apiKey;
@property (nonatomic, retain) NSString * displayValue;

@end
