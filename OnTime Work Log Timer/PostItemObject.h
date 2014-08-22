//
//  PostItemObject.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "KVCBaseObject.h"

@interface PostItemObject : KVCBaseObject

@property (nonatomic) NSNumber *id;
@property (nonatomic, weak) NSString *item_type;

@end
