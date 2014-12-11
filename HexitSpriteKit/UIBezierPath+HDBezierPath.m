//
//  UIBezierPath+HDBezierPath.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/9/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "UIBezierPath+HDBezierPath.h"

static const CGFloat kInset = 70.0f;

@implementation UIBezierPath (HDBezierPath)

+ (UIBezierPath *)randomPathFromBounds:(CGRect)bounds
{
    UIBezierPath *randomPath = [UIBezierPath bezierPath];
    [randomPath moveToPoint:[self randomPoint:bounds]];
    [randomPath addCurveToPoint:[self randomPoint:bounds]
                  controlPoint1:[self randomPoint:bounds]
                  controlPoint2:[self randomPoint:bounds]];
    [randomPath addCurveToPoint:[self randomPoint:bounds]
                  controlPoint1:[self randomPoint:bounds]
                  controlPoint2:[self randomPoint:bounds]];
    [randomPath closePath];
    
    return randomPath;
}

+ (CGPoint)randomPoint:(CGRect)bounds
{
    return CGPointMake(-kInset + arc4random() % (int)(CGRectGetWidth(bounds) + (kInset * 2)),
                       -kInset + arc4random() % (int)(CGRectGetHeight(bounds) + (kInset * 2)));
}

@end
