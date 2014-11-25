//
//  NSMutableArray+UniqueAdditions.h
//  Hexagon
//
//  Created by Evan Ische on 10/6/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HDHexagon;
@interface NSMutableArray (UniqueAdditions)

- (void)addUniqueObject:(HDHexagon *)hexagon;
- (void)shuffle;
@end
