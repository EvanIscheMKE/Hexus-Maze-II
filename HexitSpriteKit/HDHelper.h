//
//  HDHelper.h
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//


#import <Foundation/Foundation.h>

@interface HDHelper : NSObject
+ (CGPathRef)hexagonPathForBounds:(CGRect)bounds;
+ (CGPathRef)starPathForBounds:(CGRect)bounds;
@end
