//
//  WorkDone.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "WorkDone.h"

@implementation WorkDone

- (id)init
{
    self = [super init];
    
    if (self) {
        _time_unit = [TimeUnitObject new];
    }
    
    return self;
}
@end
