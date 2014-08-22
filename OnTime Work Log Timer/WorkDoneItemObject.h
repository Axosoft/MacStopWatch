//
//  WorkDoneItemObject.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 4/12/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "KVCBaseObject.h"
#import "WorkDone.h"

@interface WorkDoneItemObject : KVCBaseObject
@property (nonatomic, strong) WorkDone *remaining_duration;
@end
