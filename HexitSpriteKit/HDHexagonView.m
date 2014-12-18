//
//  HDHexagonView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 12/17/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

@import QuartzCore;

#import "HDHelper.h"
#import "HDHexagonView.h"
#import "UIColor+FlatColors.h"

@implementation HDHexagonView

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (CAShapeLayer *)hexaLayer
{
    return (CAShapeLayer *)self.layer;
}

- (id)initWithFrame:(CGRect)frame strokeColor:(UIColor *)strokeColor
{
    if (self = [super initWithFrame:frame]) {
        
        [[self hexaLayer] setFillColor:[[UIColor flatMidnightBlueColor] CGColor]];
        [[self hexaLayer] setPath:[HDHelper hexagonPathForBounds:self.bounds]];
        [[self hexaLayer] setStrokeColor:[strokeColor CGColor]];
        [[self hexaLayer] setLineWidth:8.0f];
        
    }
    return self;
}

 - (void)setBackgroundColor:(UIColor *)backgroundColor
{
    NSAssert(NO, @"use setFill and setStroke");
}

@end
