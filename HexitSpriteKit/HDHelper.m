//
//  HDHelper.m
//  Hexagon
//
//  Created by Evan Ische on 10/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "UIColor+FlatColors.h"

@implementation HDHelper

+ (CGPathRef)hexagonPathForBounds:(CGRect)bounds
{
    const CGFloat kPadding = CGRectGetWidth(bounds) / 8 / 2;
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(CGRectGetWidth(bounds) / 2, 0)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) * .25f)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(bounds) * .75)];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) / 2, CGRectGetHeight(bounds))];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) * .75f)];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(bounds) * .25f)];
    [_path closePath];
    
    return [_path CGPath];
}

+ (CGPathRef)starPathForBounds:(CGRect)bounds
{
    UIBezierPath *starPath = [UIBezierPath bezierPath];
   
    const CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    
    const NSUInteger numberOfPoints = 5;
    const CGFloat innerRadius = CGRectGetWidth(bounds) / 3.8f;
    const CGFloat outerRadius = CGRectGetMidX(bounds);
    
    CGFloat arcPerPoint = 2.0f * M_PI / 5;
    CGFloat theta = M_PI / 2.0f;
    
    // Move to starting point (tip at 90 degrees on outside of star)
    CGPoint pt = CGPointMake(center.x + (outerRadius * cosf(theta)), center.y + (outerRadius * sinf(theta)));
    
    [starPath moveToPoint:CGPointMake(pt.x, pt.y)];
    
    for (int i = 0; i < numberOfPoints; i++) {
        // Calculate next inner point (moving clockwise), accounting for crossing of 0 degrees
        theta = theta - (arcPerPoint / 2.0f);
        if (theta < 0.0f) {
            theta = theta + (2 * M_PI);
        }
        pt = CGPointMake(center.x + (innerRadius * cosf(theta)), center.y + (innerRadius * sinf(theta)));
        [starPath addLineToPoint:CGPointMake(pt.x, pt.y)];
        
        // Calculate next outer point (moving clockwise), accounting for crossing of 0 degrees
        theta = theta - (arcPerPoint / 2.0f);
        if (theta < 0.0f) {
            theta = theta + (2 * M_PI);
        }
        pt = CGPointMake(center.x + (outerRadius * cosf(theta)), center.y + (outerRadius * sinf(theta)));
        [starPath addLineToPoint:CGPointMake(pt.x, pt.y)];
    }
   
    return [starPath CGPath];
}

@end
