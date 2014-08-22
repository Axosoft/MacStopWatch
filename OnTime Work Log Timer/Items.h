//
//  Items.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/21/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TimeLog;

@interface Items : NSManagedObject

@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSString * itemType;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSSet *timeLog;
@end

@interface Items (CoreDataGeneratedAccessors)

- (void)addTimeLogObject:(TimeLog *)value;
- (void)removeTimeLogObject:(TimeLog *)value;
- (void)addTimeLog:(NSSet *)values;
- (void)removeTimeLog:(NSSet *)values;

@end
