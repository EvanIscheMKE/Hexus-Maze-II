//
//  NSMutableArray+UniqueAdditions.m
//  Hexagon
//
//  Created by Evan Ische on 10/6/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHexagon.h"
#import "NSMutableArray+UniqueAdditions.h"

@implementation NSMutableArray (UniqueAdditions)

- (NSMutableArray *)shuffle
{
    for (int i = 0; i < [self count]; ++i) {
        [self exchangeObjectAtIndex:i withObjectAtIndex:arc4random_uniform(i + 1)];
    }
    return self;
}

@end
