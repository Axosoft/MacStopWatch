//
//  TimeValueTransformer.m
//  OnTime Work Log Timer
//
//  Created by Brian Jost on 3/19/13.
//  Copyright (c) 2013 Brian Jost. All rights reserved.
//

#import "ItemIdValueTransformer.h"

@implementation ItemIdValueTransformer

+(Class)transformedValueClass
{
    return [NSString class];
}

+ (BOOL)allowsReverseTransformation
{
    return NO;
}

- (id)transformedValue:(id)value
{
    // Remove the ,'s from Mountain Lion and up
    NSString *string = [NSString stringWithFormat:@"%li",(long)[value integerValue]];
//    NSLog(@"Value: %@", string);
    return string;
}

@end
