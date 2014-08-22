//
//  TimeValueTransformer.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "TimeValueTransformer.h"

@implementation TimeValueTransformer

+(Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return YES;
}

- (id)transformedValue:(id)value
{
    
    NSInteger seconds = (NSInteger)fabs([value integerValue]);
    NSString *string = [NSString stringWithFormat:@"%02li:%02li:%02li",
                        (NSInteger)seconds / 3600, (NSInteger)(seconds / 60) % 60, (NSInteger)seconds % 60];
//    NSLog(@"Value: %@", string);
    return string;
}

- (id)reverseTransformedValue:(id)value
{
//    NSLog(@"Reverse Transform: %@", value);
    NSArray *timeArray = [value componentsSeparatedByString:@":"];
    long hours = [[timeArray objectAtIndex:0] integerValue] * 3600;
    long minutes = [[timeArray objectAtIndex:1] integerValue] * 60;
    long seconds = [[timeArray objectAtIndex:2] integerValue];
    
    long total = hours + minutes + seconds;
//    NSLog(@"Reverse Transform Value: %li", total);
    [[CoreDataHelper sharedInstance] saveContext];
    return [NSString stringWithFormat:@"%li", total];
}

@end
