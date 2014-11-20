//
//  HDProgressView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 11/15/14.
//  Copyright (c) 2014 Evan William Ische. All rights reserved.
//

#import "HDHelper.h"
#import "HDProgressView.h"
#import "UIColor+FlatColors.h"


@implementation HDProgressView{
    NSInteger _remainingTileCount;
}

+ (Class)layerClass
{
    return [CAShapeLayer class];
}

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        CGRect bounds = CGRectMake(0.0f, 0.0f, CGRectGetHeight(self.bounds), CGRectGetHeight(self.bounds));
        
        CAShapeLayer *layer = (CAShapeLayer *)self.layer;
        [layer setPath:[self _navigationPathForBounds:self.bounds]];
        [layer setFillColor:[[UIColor flatCloudsColor] CGColor]];
        [layer setStrokeColor:[[UIColor flatCloudsColor] CGColor]];
        [layer setLineWidth:6.0f];
        
        CAShapeLayer *left = [CAShapeLayer layer];
        [left setPosition:CGPointMake(CGRectGetMidY(self.bounds), CGRectGetMidY(self.bounds))];
        
        CAShapeLayer *right = [CAShapeLayer layer];
        [right setPosition:CGPointMake(CGRectGetWidth(self.bounds) - CGRectGetMidY(self.bounds), CGRectGetMidY(self.bounds))];
        
        for (CAShapeLayer *shape in @[left,right]) {
            [shape setBounds:bounds];
            [shape setPath:[HDHelper hexagonPathForBounds:bounds]];
            [shape setFillColor:[[UIColor flatSilverColor] CGColor]];
            [shape setStrokeColor:[[UIColor flatSilverColor] CGColor]];
            [shape setLineWidth:6];
            [self.layer addSublayer:shape];
        }
    }
    return self;
}

- (CGPathRef)_navigationPathForBounds:(CGRect)bounds
{
    
    const CGFloat kPadding = CGRectGetHeight(bounds) / 8 / 2;
    UIBezierPath *_path = [UIBezierPath bezierPath];
    [_path moveToPoint:CGPointMake(CGRectGetMidX(bounds), CGRectGetHeight(self.bounds))];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(self.bounds))];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(self.bounds) - (CGRectGetHeight(bounds) * .25f))];
    [_path addLineToPoint:CGPointMake(CGRectGetWidth(bounds) - kPadding, CGRectGetHeight(self.bounds) - (CGRectGetHeight(bounds) * .75f))];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(self.bounds) - (CGRectGetHeight(bounds) * .75f))];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(self.bounds) - (CGRectGetHeight(bounds) * .25f))];
    [_path addLineToPoint:CGPointMake(kPadding, CGRectGetHeight(self.bounds))];
    [_path closePath];
    
    return [_path CGPath];
}


@end
