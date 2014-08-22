//
//  TimeUnit.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/22/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TimeUnit : NSManagedObject

@property (nonatomic, retain) NSNumber * id;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * abbreviation;
@property (nonatomic, retain) NSNumber * conversion_factor;
@property (nonatomic, retain) NSNumber * order;

@end
