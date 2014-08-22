//
//  WorkDone.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TimeUnitObject.h"
#import "KVCBaseObject.h"

@interface WorkDone : KVCBaseObject

@property float duration;
@property (nonatomic, strong) TimeUnitObject *time_unit;
@end
