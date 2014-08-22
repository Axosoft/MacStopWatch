//
//  PostTimeLog.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "PostTimeLog.h"

@implementation PostTimeLog

- (id)init
{
    self = [super init];
    if (self) {
        _user = [UserObject new];
        _work_done = [WorkDone new];
        _item = [PostItemObject new];
    }
    
    return self;
}
@end
