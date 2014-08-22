//
//  PostTimeLog.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserObject.h"
#import "WorkDone.h"
#import "PostItemObject.h"
#import "KVCBaseObject.h"

@interface PostTimeLog : KVCBaseObject

@property (nonatomic, retain) UserObject * user;
@property (nonatomic, retain) WorkDone * work_done;
@property (nonatomic, retain) PostItemObject * item;
@property (nonatomic, retain) NSString *date_time;
@property (nonatomic, retain) NSString *timeLogId;

@end
