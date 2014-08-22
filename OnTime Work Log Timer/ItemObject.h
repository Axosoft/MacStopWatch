//
//  Items.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/11/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ItemObject : NSObject

@property (nonatomic, retain) NSNumber * itemId;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * itemType;

@end
