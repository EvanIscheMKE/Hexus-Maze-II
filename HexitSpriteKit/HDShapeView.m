//
//  HDShapeView.m
//  HexitSpriteKit
//
//  Created by Evan Ische on 5/15/15.
//  Copyright (c) 2015 Evan William Ische. All rights reserved.
//

#import "HDShapeView.h"

@implementation HDShapeView

+ (Class)layerClass {
    return [CAShapeLayer class];
}

- (CAShapeLayer *)shapeLayer {
    return (CAShapeLayer *)self.layer;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {
//    [super setBackgroundColor:[UIColor clearColor]];
    self.shapeLayer.strokeColor = backgroundColor.CGColor;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.shapeLayer.strokeEnd = 0.0f;
        self.shapeLayer.path = [self _pathFromBounds:self.bounds].CGPath;
        self.shapeLayer.lineWidth = CGRectGetHeight(self.bounds);
    }
    return self;
}

- (void)animateToPercentage:(CGFloat)percentage {
    
}

- (UIBezierPath *)_pathFromBounds:(CGRect)bounds {
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0.0f, CGRectGetMidY(bounds))];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(bounds),  CGRectGetMidY(bounds))];
    return path;
}

@end
