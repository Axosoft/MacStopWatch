//
//  PostWorkDoneItem.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 4/12/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "PostWorkDoneItem.h"
#import "WorkDoneItemObject.h"

@implementation PostWorkDoneItem
- (id)init
{
    self = [super init];
    if (self) {
        _item = [WorkDoneItemObject new];
    }
    
    return self;
}
@end
