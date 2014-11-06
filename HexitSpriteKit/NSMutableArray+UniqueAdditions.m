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

- (void)addUniqueObject:(HDHexagon *)hexagon
{
    if (![self containsObject:hexagon]) {
        [self addObject:hexagon];
    } else if ( !hexagon.selected || ( hexagon.type == HDHexagonTypeStarter ) ) {
        [self removeObjectIdenticalTo:hexagon];
        [self addObject:hexagon];
    }
}

@end
