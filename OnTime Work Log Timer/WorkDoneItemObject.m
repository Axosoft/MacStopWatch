//
//  WorkDoneItemObject.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 4/12/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "WorkDoneItemObject.h"
#import "WorkDone.h"

@implementation WorkDoneItemObject
- (id)init
{
    self = [super init];
    if (self) {
        _remaining_duration = [WorkDone new];
    }
    
    return self;
}
@end
