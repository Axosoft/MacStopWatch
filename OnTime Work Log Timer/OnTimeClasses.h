//
//  OnTimeClasses.h
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/11/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnTimeClasses : NSObject

+ (void)searchForItemByType:(NSString *)itemType andId:(NSString *)searchId andTable:(NSTableView *)table;
+ (void)uploadTime:(NSArrayController *)arrayController;
+ (void)getTimeUnits;

@end
